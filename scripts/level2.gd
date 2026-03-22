extends Node2D

const Boss    = preload("res://scenes/boss/boss.tscn")
const WinAnim = preload("res://scenes/win_anim/win_anim.tscn")
const CastleBg       = preload("res://scripts/castle_bg.gd")
const CastlePlatform = preload("res://scripts/castle_platform.gd")

var _boss_bar: ColorRect

func _ready() -> void:
	var bg := CastleBg.new()
	bg.z_index = -10
	add_child(bg)

	# Arena floor + walls
	_platform(640, 708, 1280, 32, false)
	_platform(-16,  354,   32, 724, false)
	_platform(1296, 354,   32, 724, false)

	# Two pillars the player can hide behind
	_platform(300, 574, 44, 220, false)
	_platform(980, 574, 44, 220, false)

	# Boss entrance ledge (decorative top edge)
	_platform(640,  30, 1280, 20, true)

	# Spawn boss
	var boss := Boss.instantiate()
	boss.name = "Boss"
	boss.position = Vector2(1050, 660)
	add_child(boss)

	# HUD
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	# Player HP
	var hp := Label.new()
	hp.name = "HealthLabel"
	hp.position = Vector2(12, 12)
	hp.text = "HP  ■■■■■■"
	hud.add_child(hp)

	# Boss name
	var name_lbl := Label.new()
	name_lbl.text = "☠  DARK KNIGHT"
	name_lbl.position = Vector2(460, 12)
	hud.add_child(name_lbl)

	# Boss health bar background
	var bar_bg := ColorRect.new()
	bar_bg.size     = Vector2(400, 16)
	bar_bg.position = Vector2(440, 36)
	bar_bg.color    = Color(0.2, 0.05, 0.05)
	hud.add_child(bar_bg)

	# Boss health bar fill
	_boss_bar = ColorRect.new()
	_boss_bar.size     = Vector2(400, 16)
	_boss_bar.position = Vector2(440, 36)
	_boss_bar.color    = Color(0.85, 0.1, 0.1)
	hud.add_child(_boss_bar)

func _process(_delta: float) -> void:
	var player = get_node_or_null("Player")
	if player:
		var hp := ""
		for i in player.max_health:
			hp += "■" if i < player.health else "□"
		$HUD/HealthLabel.text = "HP  " + hp

	var boss = get_node_or_null("Boss")
	if _boss_bar:
		if boss:
			_boss_bar.size.x = 400.0 * boss.health / boss.max_health
		else:
			_boss_bar.size.x = 0.0

func on_win() -> void:
	get_tree().paused = true
	var anim := WinAnim.instantiate()
	anim.next_level = "res://scenes/splash/splash.tscn"
	add_child(anim)

func _platform(cx: float, cy: float, w: float, h: float, battlements: bool = true) -> void:
	var body := StaticBody2D.new()
	body.position      = Vector2(cx, cy)
	body.collision_layer = 1
	body.collision_mask  = 0

	var col  := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	col.shape = rect
	body.add_child(col)

	var vis := CastlePlatform.new()
	vis.w           = w
	vis.h           = h
	vis.battlements = battlements
	vis._stone  = Color(0.48, 0.40, 0.35)
	vis._dark   = Color(0.26, 0.20, 0.18)
	vis._light  = Color(0.62, 0.54, 0.48)
	vis._shadow = Color(0.16, 0.12, 0.10)
	body.add_child(vis)

	add_child(body)
