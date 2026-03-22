extends Node2D

func _ready() -> void:
	var tween = create_tween()
	tween.tween_method(_set_state, 0.0, 1.0, 0.4)
	tween.tween_callback(queue_free)

func _set_state(t: float) -> void:
	scale = Vector2.ONE * (1.0 + t * 5.0)
	modulate.a = 1.0 - t
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 40.0, Color(1.0, 0.4, 0.1))
