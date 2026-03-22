extends Node2D

var _particles := []

func _ready() -> void:
	for i in 20:
		var angle := randf() * TAU
		var speed := randf_range(40.0, 160.0)
		_particles.append({
			"pos":      Vector2.ZERO,
			"vel":      Vector2(cos(angle), sin(angle)) * speed,
			"col":      Color(0.12 + randf() * 0.25, 0.40 + randf() * 0.35, 0.06),
			"size":     randf_range(2.0, 8.0),
			"life":     1.0,
			"max_life": randf_range(0.4, 0.9),
		})

func _process(delta: float) -> void:
	if _particles.is_empty():
		queue_free()
		return
	var alive := []
	for p in _particles:
		p.life -= delta / p.max_life
		p.pos  += p.vel * delta
		p.vel  *= 0.88
		if p.life > 0.0:
			alive.append(p)
	_particles = alive
	queue_redraw()

func _draw() -> void:
	for p in _particles:
		var c: Color = p.col
		c.a = maxf(p.life, 0.0)
		draw_circle(p.pos, p.size * p.life, c)
