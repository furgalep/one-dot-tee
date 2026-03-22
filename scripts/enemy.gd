extends CharacterBody2D

const SPEED       = 55.0
const EnemyDeath  = preload("res://scripts/enemy_death.gd")

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
	rect_shape.size = Vector2(14, 26)
	col.shape = rect_shape
	add_child(col)

	# Damage area (hurts player on contact)
	damage_area = Area2D.new()
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2
	var da_col = CollisionShape2D.new()
	var da_rect = RectangleShape2D.new()
	da_rect.size = Vector2(14, 26)
	da_col.shape = da_rect
	damage_area.add_child(da_col)
	add_child(damage_area)
	damage_area.body_entered.connect(_on_damage_body_entered)

	patrol_timer = randf_range(1.0, 2.5)
	velocity.x = facing * SPEED * speed_mult

func _draw() -> void:
	var green := Color(0.22, 0.62, 0.15) if not is_hurt else Color(0.6, 1.0, 0.5)
	var dark  := Color(0.10, 0.30, 0.06)
	var face  := Color(0.04, 0.07, 0.03)

	# Legs — 4 legs spread wide (wider than body)
	draw_rect(Rect2(-10, 4, 5, 9), green)   # far left
	draw_rect(Rect2( -4, 4, 4, 9), green)   # near left
	draw_rect(Rect2(  1, 4, 4, 9), green)   # near right
	draw_rect(Rect2(  6, 4, 5, 9), green)   # far right

	# Body — narrow
	draw_rect(Rect2(-5, -10, 10, 16), green)
	draw_rect(Rect2(-5,   0, 10,  2), dark)  # waist shadow

	# Head — wider than body
	draw_rect(Rect2(-8, -26, 16, 18), green)

	# Eyes (classic creeper — two dark squares)
	draw_rect(Rect2(-6, -24, 4, 4), face)
	draw_rect(Rect2( 2, -24, 4, 4), face)

	# Mouth (creeper frown: top bar + two lower side blocks)
	draw_rect(Rect2(-4, -18, 8, 2), face)   # top bar
	draw_rect(Rect2(-6, -16, 4, 4), face)   # lower left
	draw_rect(Rect2( 2, -16, 4, 4), face)   # lower right

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0.0:
			is_hurt = false

	# Patrol — flip at walls or when floor ends ahead
	patrol_timer -= delta
	if patrol_timer <= 0.0 or is_on_wall() or (is_on_floor() and not _has_floor_ahead()):
		facing = -facing
		velocity.x = facing * SPEED * speed_mult
		patrol_timer = randf_range(1.5, 3.0)

	move_and_slide()
	queue_redraw()

# Raycast slightly ahead and below to detect platform edge
func _has_floor_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var start := global_position + Vector2(facing * 10, 5)
	var end   := global_position + Vector2(facing * 10, 32)
	var query := PhysicsRayQueryParameters2D.create(start, end, 1)
	query.exclude = [self]
	return not space.intersect_ray(query).is_empty()

func take_hit(knockback: Vector2) -> void:
	health -= 1
	velocity = knockback
	is_hurt = true
	hurt_timer = 0.25
	if health <= 0:
		_die()

func _die() -> void:
	_play_sfx("enemy_defeated")
	collision_layer = 0
	damage_area.monitoring = false
	set_physics_process(false)

	# Particle burst at death position
	var effect := EnemyDeath.new()
	effect.global_position = global_position
	get_parent().add_child(effect)

	# Flash white → topple and shrink away
	var tween := create_tween()
	tween.tween_callback(func(): is_hurt = true;  queue_redraw())
	tween.tween_interval(0.07)
	tween.tween_callback(func(): is_hurt = false; queue_redraw())
	tween.tween_interval(0.07)
	tween.tween_callback(func(): is_hurt = true;  queue_redraw())
	tween.tween_interval(0.07)
	tween.tween_callback(func(): is_hurt = false; queue_redraw())
	tween.tween_property(self, "rotation", deg_to_rad(90.0), 0.28) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.05, 0.05), 0.28)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.22)
	tween.tween_callback(queue_free)

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
