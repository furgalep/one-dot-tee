extends Area2D

var t := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # player layer
	body_entered.connect(_on_body_entered)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	add_child(shape)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var pulse := (sin(t * 3.0) + 1.0) / 2.0
	# Outer glow
	draw_circle(Vector2.ZERO, 16.0 + pulse * 5.0, Color(0.4, 1.0, 0.5, 0.3))
	# Main orb
	draw_circle(Vector2.ZERO, 14.0, Color(0.3 + pulse * 0.3, 0.95, 0.4))
	# Core
	draw_circle(Vector2.ZERO, 6.0, Color(0.9, 1.0, 0.8))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().on_win()
