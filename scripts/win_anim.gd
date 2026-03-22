extends CanvasLayer

const ParticlesNode = preload("res://scripts/particles_node.gd")

var next_level := "res://scenes/level2/level2.tscn"
var _pnode: Node2D

func _ready() -> void:
	layer = 10
	process_mode = PROCESS_MODE_ALWAYS
	_pnode = ParticlesNode.new()
	_pnode.process_mode = PROCESS_MODE_ALWAYS
	add_child(_pnode)
	_play()

func _process(delta: float) -> void:
	_pnode.update(delta)

func _play() -> void:
	# Win sound
	var win_path := "res://assets/sfx/win.wav"
	if ResourceLoader.exists(win_path):
		var p := AudioStreamPlayer.new()
		p.stream = load(win_path)
		p.process_mode = PROCESS_MODE_ALWAYS
		add_child(p)
		p.play()

	# Flash
	var flash := ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1.0, 0.95, 0.3, 0.95)
	flash.process_mode = PROCESS_MODE_ALWAYS
	add_child(flash)
	var ft := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	ft.tween_property(flash, "color:a", 0.0, 0.5)
	ft.tween_callback(flash.queue_free)

	# YOU WIN label
	var label := Label.new()
	label.text = "YOU WIN!"
	label.add_theme_font_size_override("font_size", 80)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(640, 310)
	label.pivot_offset = Vector2(0, 40)
	label.scale = Vector2.ZERO
	label.process_mode = PROCESS_MODE_ALWAYS
	add_child(label)
	# Centre horizontally after adding (size is now known next frame, approximate here)
	label.position.x = 640 - 320

	var lt := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	lt.set_ease(Tween.EASE_OUT)
	lt.set_trans(Tween.TRANS_ELASTIC)
	lt.tween_property(label, "scale", Vector2.ONE, 1.0)

	# Gold colour pulse
	var ct := create_tween().set_loops().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	ct.tween_property(label, "modulate", Color(1.0, 0.85, 0.1), 0.4)
	ct.tween_property(label, "modulate", Color(1.0, 1.0, 1.0), 0.4)

	# Particle bursts in waves
	_burst(35)
	await _wait(0.35)
	_burst(25)
	await _wait(0.35)
	_burst(25)
	await _wait(0.35)
	_burst(20)

	# Fade to black then load next level
	await _wait(0.9)
	var fade := ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.color = Color(0.0, 0.0, 0.0, 0.0)
	fade.process_mode = PROCESS_MODE_ALWAYS
	add_child(fade)
	var fade_t := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_t.tween_property(fade, "color:a", 1.0, 0.5)
	await _wait(0.55)
	get_tree().paused = false
	get_tree().change_scene_to_file(next_level)

func _burst(count: int) -> void:
	var center := Vector2(640, 330)
	for i in count:
		var angle := randf() * TAU
		var speed := randf_range(60.0, 380.0)
		_pnode.particles.append({
			"pos": center + Vector2(randf_range(-30, 30), randf_range(-30, 30)),
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"col": Color(randf(), randf_range(0.4, 1.0), randf_range(0.1, 1.0)),
			"size": randf_range(5.0, 16.0),
			"life": 1.0,
			"max_life": randf_range(0.7, 1.8),
		})

func _wait(t: float) -> Signal:
	return get_tree().create_timer(t, false, false, true).timeout
