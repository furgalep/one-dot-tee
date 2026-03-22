extends Node2D

const Enemy = preload("res://scenes/enemy/enemy.tscn")
const Goal = preload("res://scenes/goal/goal.tscn")
const WinAnim = preload("res://scenes/win_anim/win_anim.tscn")

func _ready() -> void:
	# Floor + walls
	_platform(640, 716, 1280, 32)
	_platform(-16, 400, 32, 820)
	_platform(1296, 400, 32, 820)

	# Platforms — each row ~70-75px above the last (jump height ~90px)
	# Row 1  y=640
	_platform(190, 640, 200, 20)
	_platform(640, 640, 180, 20)
	_platform(1060, 640, 200, 20)
	# Row 2  y=565
	_platform(400, 565, 180, 20)
	_platform(860, 565, 180, 20)
	# Row 3  y=490
	_platform(160, 490, 200, 20)
	_platform(560, 490, 160, 20)
	_platform(970, 490, 180, 20)
	# Row 4  y=415
	_platform(340, 415, 180, 20)
	_platform(760, 415, 200, 20)
	# Row 5  y=340
	_platform(140, 340, 180, 20)
	_platform(530, 340, 160, 20)
	_platform(920, 340, 180, 20)
	# Row 6  y=265
	_platform(330, 265, 180, 20)
	_platform(760, 265, 180, 20)
	# Row 7  y=190
	_platform(500, 190, 200, 20)
	_platform(900, 190, 160, 20)
	# Goal platform  y=115
	_platform(640, 115, 220, 20)

	# Enemies
	_spawn_enemy(190, 600)
	_spawn_enemy(640, 600)
	_spawn_enemy(400, 525)
	_spawn_enemy(560, 450)
	_spawn_enemy(760, 375)
	_spawn_enemy(530, 300)
	_spawn_enemy(900, 300)
	_spawn_enemy(500, 150)

	# Goal orb at the top
	var goal := Goal.instantiate()
	goal.position = Vector2(640, 75)
	add_child(goal)

func _process(_delta: float) -> void:
	var player = get_node_or_null("Player")
	if player:
		var hp := ""
		for i in player.max_health:
			hp += "■" if i < player.health else "□"
		$HUD/HealthLabel.text = "HP  " + hp

func on_win() -> void:
	get_tree().paused = true
	var anim := WinAnim.instantiate()
	anim.next_level = "res://scenes/level2/level2.tscn"
	add_child(anim)

func _platform(cx: float, cy: float, w: float, h: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(cx, cy)
	body.collision_layer = 1
	body.collision_mask = 0

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	col.shape = rect
	body.add_child(col)

	var vis := ColorRect.new()
	vis.size = Vector2(w, h)
	vis.position = Vector2(-w / 2.0, -h / 2.0)
	vis.color = Color(0.22, 0.15, 0.35)
	body.add_child(vis)

	add_child(body)

func _spawn_enemy(x: float, y: float) -> void:
	var e := Enemy.instantiate()
	e.position = Vector2(x, y)
	add_child(e)
