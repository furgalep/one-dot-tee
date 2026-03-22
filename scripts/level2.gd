extends Node2D

const Enemy = preload("res://scenes/enemy/enemy.tscn")
const Goal = preload("res://scenes/goal/goal.tscn")
const WinAnim = preload("res://scenes/win_anim/win_anim.tscn")
const CastleBg = preload("res://scripts/castle_bg.gd")

func _ready() -> void:
	# Background stone wall (red-tinted for level 2)
	var bg := CastleBg.new()
	bg.z_index = -10
	add_child(bg)

	# Floor + walls
	_platform(640, 716, 1280, 32, false)
	_platform(-16, 400, 32, 820, false)
	_platform(1296, 400, 32, 820, false)

	# Platforms — tighter horizontal spacing, same ~70px vertical gap
	# Row 1  y=640
	_platform(150, 640, 160, 20)
	_platform(480, 640, 140, 20)
	_platform(800, 640, 160, 20)
	_platform(1100, 640, 140, 20)
	# Row 2  y=565
	_platform(300, 565, 140, 20)
	_platform(640, 565, 160, 20)
	_platform(980, 565, 140, 20)
	# Row 3  y=490
	_platform(120, 490, 140, 20)
	_platform(440, 490, 140, 20)
	_platform(780, 490, 140, 20)
	_platform(1080, 490, 140, 20)
	# Row 4  y=415
	_platform(270, 415, 140, 20)
	_platform(600, 415, 140, 20)
	_platform(930, 415, 140, 20)
	# Row 5  y=340
	_platform(100, 340, 140, 20)
	_platform(420, 340, 120, 20)
	_platform(730, 340, 140, 20)
	_platform(1050, 340, 120, 20)
	# Row 6  y=265
	_platform(260, 265, 140, 20)
	_platform(580, 265, 120, 20)
	_platform(880, 265, 140, 20)
	# Row 7  y=190
	_platform(130, 190, 140, 20)
	_platform(450, 190, 120, 20)
	_platform(780, 190, 140, 20)
	# Goal platform  y=115
	_platform(640, 115, 200, 20)

	# Enemies — more of them, 1.6x faster
	_spawn_enemy(150, 600, 1.6)
	_spawn_enemy(480, 600, 1.6)
	_spawn_enemy(800, 600, 1.6)
	_spawn_enemy(300, 525, 1.6)
	_spawn_enemy(640, 525, 1.6)
	_spawn_enemy(440, 450, 1.6)
	_spawn_enemy(1080, 450, 1.6)
	_spawn_enemy(600, 375, 1.6)
	_spawn_enemy(730, 300, 1.6)
	_spawn_enemy(580, 225, 1.6)
	_spawn_enemy(450, 150, 1.6)

	# Goal
	var goal := Goal.instantiate()
	goal.position = Vector2(640, 75)
	add_child(goal)

	# HUD
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	var hp_label := Label.new()
	hp_label.name = "HealthLabel"
	hp_label.position = Vector2(12, 12)
	hp_label.text = "HP  ■■■■■■"
	var lvl_label := Label.new()
	lvl_label.position = Vector2(560, 12)
	lvl_label.text = "LEVEL 2"
	hud.add_child(hp_label)
	hud.add_child(lvl_label)
	add_child(hud)

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
	anim.next_level = "res://scenes/main/main.tscn"  # loop back to level 1
	add_child(anim)

const CastlePlatform = preload("res://scripts/castle_platform.gd")

func _platform(cx: float, cy: float, w: float, h: float, show_battlements: bool = true) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(cx, cy)
	body.collision_layer = 1
	body.collision_mask = 0

	var c := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	c.shape = rect
	body.add_child(c)

	var vis := CastlePlatform.new()
	vis.w = w
	vis.h = h
	vis.battlements = show_battlements
	# Slightly warmer stone tone for level 2
	vis._stone  = Color(0.48, 0.40, 0.35)
	vis._dark   = Color(0.26, 0.20, 0.18)
	vis._light  = Color(0.62, 0.54, 0.48)
	vis._shadow = Color(0.16, 0.12, 0.10)
	body.add_child(vis)

	add_child(body)

func _spawn_enemy(x: float, y: float, spd: float = 1.0) -> void:
	var e := Enemy.instantiate()
	e.position = Vector2(x, y)
	e.speed_mult = spd
	add_child(e)
