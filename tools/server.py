#!/usr/bin/env python3
"""Local dev server for the audio editor. Serves HTML and saves .wav files to assets/sfx/."""
import http.server, os, json

PORT     = 8765
HERE     = os.path.dirname(os.path.abspath(__file__))
SFX_DIR  = os.path.join(HERE, '..', 'assets', 'sfx')

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=HERE, **kwargs)

    def do_GET(self):
        if self.path == '/files':
            os.makedirs(SFX_DIR, exist_ok=True)
            files = [f for f in os.listdir(SFX_DIR) if f.endswith('.wav')]
            self._cors()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(files).encode())
        elif self.path.startswith('/sfx/'):
            filename = os.path.basename(self.path[5:])
            path = os.path.join(SFX_DIR, filename)
            if os.path.exists(path):
                with open(path, 'rb') as f:
                    data = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'audio/wav')
                self.send_header('Content-Length', str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_response(404); self.end_headers()
        else:
            super().do_GET()

    def do_OPTIONS(self):
        self._cors()
        self.end_headers()

    def do_POST(self):
        if self.path != '/save':
            self.send_response(404); self.end_headers(); return

        filename = os.path.basename(self.headers.get('X-Filename', 'sound.wav'))
        if not filename.endswith('.wav'):
            filename += '.wav'

        size = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(size)

        os.makedirs(SFX_DIR, exist_ok=True)
        dest = os.path.join(SFX_DIR, filename)
        with open(dest, 'wb') as f:
            f.write(data)

        self._cors()
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'ok': True, 'saved': dest}).encode())

    def _cors(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, X-Filename')

    def log_message(self, *_):
        pass  # stay quiet

if __name__ == '__main__':
    print(f'Audio editor → http://localhost:{PORT}/audio_editor.html')
    print(f'Saving files to: {os.path.abspath(SFX_DIR)}')
    with http.server.HTTPServer(('127.0.0.1', PORT), Handler) as s:
        s.serve_forever()
