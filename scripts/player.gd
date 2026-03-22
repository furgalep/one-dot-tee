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
	var silver    := Color(0.72, 0.74, 0.80)
	var dk_silver := Color(0.40, 0.42, 0.48)
	var visor_col := Color(0.10, 0.12, 0.22)
	var red       := Color(0.85, 0.15, 0.15)
	var gold      := Color(0.90, 0.75, 0.20)
	var leather   := Color(0.45, 0.30, 0.12)

	# --- Plume ---
	draw_rect(Rect2(-2, -38, 4, 12), red)

	# --- Helmet ---
	draw_rect(Rect2(-7, -30, 14, 18), silver)       # main
	draw_rect(Rect2(-8, -16, 16,  4), dk_silver)    # brim
	draw_rect(Rect2(-5, -28, 10,  8), visor_col)    # visor
	draw_rect(Rect2(-4, -25,  8,  3), Color(0.3, 0.5, 0.9, 0.4))  # eye slit glint

	# --- Shoulder pads ---
	draw_rect(Rect2(-10, -13,  6, 5), dk_silver)
	draw_rect(Rect2(  4, -13,  6, 5), dk_silver)

	# --- Chest plate ---
	draw_rect(Rect2(-7, -12, 14, 14), silver)
	draw_rect(Rect2(-1, -12,  2, 14), dk_silver)    # centre seam
	draw_rect(Rect2(-7,   0, 14,  3), dk_silver)    # belt

	# --- Legs ---
	draw_rect(Rect2(-6,  3,  5,  8), silver)
	draw_rect(Rect2( 1,  3,  5,  8), silver)
	draw_rect(Rect2(-7,  9,  6,  4), dk_silver)     # left boot
	draw_rect(Rect2( 1,  9,  6,  4), dk_silver)     # right boot

	# --- Shield (opposite side from sword) ---
	var sx := -facing * 8.0
	draw_rect(Rect2(sx - 1, -12,  7, 14), red)
	draw_rect(Rect2(sx,     -11,  5, 12), Color(0.55, 0.10, 0.10))
	draw_rect(Rect2(sx + 1,  -6,  3,  3), gold)     # emblem

	# --- Sword ---
	var wx := facing * 8.0
	draw_rect(Rect2(wx,            -5, facing * 4,  3), leather)   # handle
	draw_rect(Rect2(wx - facing,   -9, facing * 3,  9), dk_silver) # guard
	if is_attacking:
		draw_rect(Rect2(wx + facing * 2, -8, facing * 22, 4), silver)  # blade
		draw_rect(Rect2(wx + facing * 22,-7, facing *  4, 2), silver)  # tip
	else:
		draw_rect(Rect2(wx + facing * 2, -8, facing * 10, 4), silver)  # sheathed blade

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
