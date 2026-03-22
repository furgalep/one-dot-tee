extends CharacterBody2D

const WALK_SPEED   = 70.0
const CHARGE_SPEED = 320.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing     := -1.0
var health     := 12
var max_health := 12
var is_hurt    := false
var hurt_timer := 0.0
var is_dying   := false
var die_timer  := 0.0
var die_flash  := false

var charge_cooldown := 3.5

enum State { WALK, WINDUP, CHARGE }
var current_state := State.WALK
var state_timer   := 0.0

var damage_area: Area2D

func _ready() -> void:
	collision_layer = 4
	collision_mask  = 1

	var col  := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(30, 48)
	col.shape = rect
	add_child(col)

	damage_area = Area2D.new()
	damage_area.collision_layer = 0
	damage_area.collision_mask  = 2
	var dc  := CollisionShape2D.new()
	var dr  := RectangleShape2D.new()
	dr.size = Vector2(34, 48)
	dc.shape = dr
	damage_area.add_child(dc)
	add_child(damage_area)
	damage_area.body_entered.connect(_on_damage_body_entered)

func _draw() -> void:
	if die_flash:
		return

	var armor  := Color(0.12, 0.08, 0.18) if not is_hurt else Color(1.0, 1.0, 1.0)
	var accent := Color(0.50, 0.08, 0.45) if not is_hurt else Color(1.0, 0.6, 0.6)
	var glow   := Color(0.95, 0.10, 0.10)
	var silver := Color(0.55, 0.55, 0.65)
	var gold   := Color(0.85, 0.70, 0.15)

	# Charge wind-up warning ring
	if current_state == State.WINDUP:
		var t := 1.0 - clamp(state_timer / 0.9, 0.0, 1.0)
		draw_circle(Vector2.ZERO, 40.0 * t, Color(1.0, 0.15, 0.15, 0.45 * t))

	# Legs
	draw_rect(Rect2(-14, 10, 11, 14), armor)
	draw_rect(Rect2(  3, 10, 11, 14), armor)
	draw_rect(Rect2(-15, 19, 13,  5), accent)  # left boot
	draw_rect(Rect2(  2, 19, 13,  5), accent)  # right boot

	# Body
	draw_rect(Rect2(-16, -14, 32, 26), armor)
	draw_rect(Rect2(-16,   4, 32,  4), accent)  # belt
	draw_rect(Rect2( -2, -14,  4, 18), accent)  # chest seam v
	draw_rect(Rect2(-10,  -6, 20,  4), accent)  # chest seam h

	# Shoulder pads
	draw_rect(Rect2(-26, -16, 13, 10), accent)
	draw_rect(Rect2( 13, -16, 13, 10), accent)
	draw_rect(Rect2(-28, -14,  4,  6), gold)
	draw_rect(Rect2( 24, -14,  4,  6), gold)

	# Helmet
	draw_rect(Rect2(-13, -36, 26, 24), armor)
	draw_rect(Rect2(-15, -20, 30,  6), accent)  # brim

	# Horns
	draw_rect(Rect2(-17, -52,  8, 20), accent)
	draw_rect(Rect2(  9, -52,  8, 20), accent)
	draw_rect(Rect2(-15, -56,  6,  6), gold)
	draw_rect(Rect2(  9, -56,  6,  6), gold)

	# Eyes
	draw_rect(Rect2(-10, -32, 8, 6), glow)
	draw_rect(Rect2(  2, -32, 8, 6), glow)
	if not is_hurt:
		draw_circle(Vector2(-6.0, -29.0), 5.0, Color(1.0, 0.2, 0.2, 0.3))
		draw_circle(Vector2( 6.0, -29.0), 5.0, Color(1.0, 0.2, 0.2, 0.3))

	# Sword
	var sw := facing * 22.0
	draw_rect(Rect2(sw,              -42, facing *  8, 58), silver)
	draw_rect(Rect2(sw - facing * 6,  -8, facing * 20,  6), silver)
	draw_rect(Rect2(sw,               -8, facing *  8, 14), Color(0.4, 0.25, 0.08))
	draw_rect(Rect2(sw,                4, facing *  8,  5), gold)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dying:
		die_timer -= delta
		die_flash = int(die_timer * 12) % 2 == 0
		velocity.x = 0
		move_and_slide()
		queue_redraw()
		if die_timer <= 0.0:
			get_parent().on_win()
			queue_free()
		return

	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0.0:
			is_hurt = false

	var player = get_tree().get_first_node_in_group("player")

	match current_state:
		State.WALK:   _do_walk(delta, player)
		State.WINDUP: _do_windup(delta)
		State.CHARGE: _do_charge(delta)

	move_and_slide()
	queue_redraw()

func _do_walk(delta: float, player: Node) -> void:
	charge_cooldown -= delta
	if player:
		var dir := sign(player.global_position.x - global_position.x)
		facing    = dir
		var spd   := WALK_SPEED * (1.5 if health <= max_health / 2 else 1.0)
		velocity.x = dir * spd

	if charge_cooldown <= 0.0 and player:
		facing    = sign(player.global_position.x - global_position.x)
		velocity.x = 0.0
		current_state  = State.WINDUP
		state_timer    = 0.9

func _do_windup(delta: float) -> void:
	state_timer -= delta
	velocity.x   = 0.0
	if state_timer <= 0.0:
		current_state  = State.CHARGE
		state_timer    = 1.1
		charge_cooldown = 2.2 if health <= max_health / 2 else 3.5

func _do_charge(delta: float) -> void:
	state_timer -= delta
	velocity.x   = facing * CHARGE_SPEED
	if state_timer <= 0.0 or is_on_wall():
		velocity.x    = 0.0
		current_state = State.WALK

func take_hit(knockback: Vector2) -> void:
	if is_dying: return
	health    -= 1
	velocity   = knockback * 0.3
	is_hurt    = true
	hurt_timer = 0.18
	if health <= 0:
		is_dying  = true
		die_timer = 1.8
		collision_layer = 0

func _on_damage_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var dmg := 2 if current_state == State.CHARGE else 1
		body.take_damage(dmg)
