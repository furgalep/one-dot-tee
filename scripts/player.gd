extends CharacterBody2D

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	# Arrow keys + gamepad (left stick + d-pad)
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# WASD
	if Input.is_physical_key_pressed(KEY_A): dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D): dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W): dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S): dir.y += 1.0

	if dir.length() > 0:
		dir = dir.normalized()

	velocity = dir * SPEED
	move_and_slide()
