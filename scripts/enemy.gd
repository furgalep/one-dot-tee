extends CharacterBody2D

const SPEED = 55.0

var speed_mult := 1.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing := 1.0
var health := 3
var is_hurt := false
var hurt_timer := 0.0
var patrol_timer := 0.0
var damage_area: Area2D

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	# Collision shape
	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(14, 20)
	col.shape = rect_shape
	add_child(col)

	# Damage area (hurts player on contact)
	damage_area = Area2D.new()
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2  # player layer
	var da_col = CollisionShape2D.new()
	var da_rect = RectangleShape2D.new()
	da_rect.size = Vector2(14, 20)
	da_col.shape = da_rect
	damage_area.add_child(da_col)
	add_child(damage_area)
	damage_area.body_entered.connect(_on_damage_body_entered)

	patrol_timer = randf_range(1.0, 2.5)
	velocity.x = facing * SPEED * speed_mult

func _draw() -> void:
	var col = Color(0.85, 0.15, 0.15) if not is_hurt else Color(1.0, 0.7, 0.7)
	# Body
	draw_rect(Rect2(-7, -10, 14, 10), col)
	# Head
	draw_rect(Rect2(-6, -20, 12, 12), col)
	# Eye
	draw_rect(Rect2(facing * 2.0, -17.0, 4, 4), Color(0.1, 0.0, 0.0))
	# Spikes on top
	draw_rect(Rect2(-5, -23, 4, 4), col)
	draw_rect(Rect2(1, -23, 4, 4), col)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0.0:
			is_hurt = false

	# Patrol
	patrol_timer -= delta
	if patrol_timer <= 0.0 or is_on_wall():
		facing = -facing
		velocity.x = facing * SPEED * speed_mult
		patrol_timer = randf_range(1.5, 3.0)

	move_and_slide()
	queue_redraw()

func take_hit(knockback: Vector2) -> void:
	health -= 1
	velocity = knockback
	is_hurt = true
	hurt_timer = 0.25
	if health <= 0:
		_play_sfx("enemy_defeated")
		queue_free()

func _play_sfx(sfx_name: String) -> void:
	var path := "res://assets/sfx/%s.wav" % sfx_name
	if ResourceLoader.exists(path):
		var p := AudioStreamPlayer.new()
		p.stream = load(path)
		p.autoplay = true
		get_tree().root.add_child(p)
		p.finished.connect(p.queue_free)

func _on_damage_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
