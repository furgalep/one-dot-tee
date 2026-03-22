extends CharacterBody2D

const SPEED = 180.0
const JUMP_VELOCITY = -420.0
const ATTACK_DURATION = 0.18
const INVINCIBLE_DURATION = 0.8

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing := 1.0
var health := 6
var max_health := 6
var is_attacking := false
var attack_timer := 0.0
var is_invincible := false
var invincible_timer := 0.0
var flash := false
var attack_hitbox: Area2D

var _sfx: Dictionary = {}

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1

	# Sound players — drop .wav/.ogg files into res://assets/sfx/ to enable
	for snd in ["jump", "attack", "hit"]:
		var p := AudioStreamPlayer.new()
		p.name = snd
		add_child(p)
		_sfx[snd] = p
		var path := "res://assets/sfx/%s.wav" % snd
		if ResourceLoader.exists(path):
			p.stream = load(path)

	# Collision shape
	var col = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(14, 26)
	col.shape = rect_shape
	add_child(col)

	# Attack hitbox
	attack_hitbox = Area2D.new()
	attack_hitbox.collision_layer = 0
	attack_hitbox.collision_mask = 4  # enemy layer
	attack_hitbox.monitoring = false
	var hb_col = CollisionShape2D.new()
	var hb_rect = RectangleShape2D.new()
	hb_rect.size = Vector2(26, 20)
	hb_col.shape = hb_rect
	attack_hitbox.add_child(hb_col)
	add_child(attack_hitbox)
	attack_hitbox.body_entered.connect(_on_attack_body_entered)

	# Camera
	var cam = Camera2D.new()
	cam.zoom = Vector2(3.0, 3.0)
	add_child(cam)

func _draw() -> void:
	if flash:
		return
	var col = Color(0.3, 0.9, 0.5)
	# Body
	draw_rect(Rect2(-7, -13, 14, 13), col)
	# Head
	draw_rect(Rect2(-6, -25, 12, 14), col)
	# Eye
	draw_rect(Rect2(facing * 2.0, -22.0, 4, 4), Color(0.05, 0.05, 0.15))
	# Sword flash on attack
	if is_attacking:
		draw_rect(Rect2(facing * 10.0, -12.0, facing * 16.0, 6.0), Color(1.0, 0.95, 0.3))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			attack_hitbox.monitoring = false

	# Invincibility flash
	if is_invincible:
		invincible_timer -= delta
		flash = int(invincible_timer * 10) % 2 == 0
		if invincible_timer <= 0.0:
			is_invincible = false
			flash = false

	# Horizontal movement
	var dir := Input.get_axis("ui_left", "ui_right")
	if Input.is_physical_key_pressed(KEY_A): dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D): dir += 1.0
	dir = clamp(dir, -1.0, 1.0)

	if dir != 0.0:
		facing = 1.0 if dir > 0 else -1.0
		attack_hitbox.position.x = facing * 20.0

	velocity.x = dir * SPEED

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_sfx("jump")

	move_and_slide()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if is_attacking:
		return
	var pressed := false
	if event is InputEventKey and not event.echo and event.pressed:
		pressed = event.physical_keycode in [KEY_Z, KEY_X, KEY_J]
	if event is InputEventJoypadButton and event.pressed:
		pressed = event.button_index in [JOY_BUTTON_X, JOY_BUTTON_B]
	if pressed:
		_start_attack()

func _start_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_DURATION
	attack_hitbox.position.x = facing * 20.0
	attack_hitbox.monitoring = true
	_play_sfx("attack")

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	health -= amount
	_play_sfx("hit")
	is_invincible = true
	invincible_timer = INVINCIBLE_DURATION
	flash = true
	if health <= 0:
		get_tree().reload_current_scene()

func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.take_hit(Vector2(facing * 300.0, -150.0))

func _play_sfx(name: String) -> void:
	var p: AudioStreamPlayer = _sfx.get(name)
	if p and p.stream:
		p.play()
