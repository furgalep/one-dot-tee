extends Node2D

const LEVELS = [
	{
		"title": "LEVEL  1",
		"desc":  "Castle Climb",
		"hint":  "Reach the orb at the top",
		"scene": "res://scenes/main/main.tscn",
		"col":   Color(0.20, 0.14, 0.32),
		"bord":  Color(0.55, 0.35, 0.90),
	},
	{
		"title": "LEVEL  2",
		"desc":  "Boss Battle",
		"hint":  "Defeat the Dark Knight",
		"scene": "res://scenes/level2/level2.tscn",
		"col":   Color(0.30, 0.08, 0.08),
		"bord":  Color(0.90, 0.25, 0.25),
	},
]

var _selected    := 0
var _cards       := []
var _borders     := []
var _anim_t      := 0.0

func _ready() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.07, 0.05, 0.10)
	hud.add_child(bg)

	# Stone top banner
	var banner := ColorRect.new()
	banner.size     = Vector2(1280, 180)
	banner.position = Vector2(0, 0)
	banner.color    = Color(0.12, 0.09, 0.16)
	hud.add_child(banner)
	var banner_line := ColorRect.new()
	banner_line.size     = Vector2(1280, 4)
	banner_line.position = Vector2(0, 178)
	banner_line.color    = Color(0.55, 0.35, 0.80)
	hud.add_child(banner_line)

	# Title
	var title := Label.new()
	title.text = "ONE · DOT · TEE"
	title.add_theme_font_size_override("font_size", 62)
	title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.30))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size     = Vector2(1280, 90)
	title.position = Vector2(0, 42)
	hud.add_child(title)

	var tagline := Label.new()
	tagline.text = "select a level"
	tagline.add_theme_font_size_override("font_size", 18)
	tagline.add_theme_color_override("font_color", Color(0.50, 0.44, 0.60))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.size     = Vector2(1280, 30)
	tagline.position = Vector2(0, 138)
	hud.add_child(tagline)

	# Level cards
	var card_w   := 320
	var card_h   := 260
	var spacing  := 60
	var total_w  := card_w * LEVELS.size() + spacing * (LEVELS.size() - 1)
	var start_x  := (1280 - total_w) / 2

	for i in LEVELS.size():
		var lvl := LEVELS[i]
		var cx  := start_x + i * (card_w + spacing)
		var cy  := 250

		# Glow border (shown when selected)
		var border := ColorRect.new()
		border.size     = Vector2(card_w + 8, card_h + 8)
		border.position = Vector2(cx - 4, cy - 4)
		border.color    = lvl.bord
		border.visible  = false
		hud.add_child(border)
		_borders.append(border)

		# Card body
		var card := ColorRect.new()
		card.size     = Vector2(card_w, card_h)
		card.position = Vector2(cx, cy)
		card.color    = lvl.col
		hud.add_child(card)
		_cards.append(card)

		# Level title
		var lbl := Label.new()
		lbl.text = lvl.title
		lbl.add_theme_font_size_override("font_size", 30)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.88, 0.55))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.size     = Vector2(card_w, 50)
		lbl.position = Vector2(0, 50)
		card.add_child(lbl)

		# Description
		var desc := Label.new()
		desc.text = lvl.desc
		desc.add_theme_font_size_override("font_size", 22)
		desc.add_theme_color_override("font_color", Color(0.80, 0.75, 0.85))
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.size     = Vector2(card_w, 40)
		desc.position = Vector2(0, 110)
		card.add_child(desc)

		# Hint
		var hint := Label.new()
		hint.text = lvl.hint
		hint.add_theme_font_size_override("font_size", 15)
		hint.add_theme_color_override("font_color", Color(0.55, 0.50, 0.62))
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.size     = Vector2(card_w, 30)
		hint.position = Vector2(0, 160)
		card.add_child(hint)

	# Controls hint
	var controls := Label.new()
	controls.text = "← →  navigate          SPACE / A  start"
	controls.add_theme_font_size_override("font_size", 17)
	controls.add_theme_color_override("font_color", Color(0.38, 0.34, 0.45))
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.size     = Vector2(1280, 30)
	controls.position = Vector2(0, 610)
	hud.add_child(controls)

	_update_selection()

func _process(delta: float) -> void:
	# Pulse the selected border
	_anim_t += delta * 3.0
	var pulse := (sin(_anim_t) + 1.0) / 2.0
	if _borders.size() > _selected:
		var bord: ColorRect = _borders[_selected]
		var base_col: Color = LEVELS[_selected].bord
		bord.color = base_col.lerp(Color(1.0, 1.0, 1.0), pulse * 0.3)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_selected = max(0, _selected - 1)
		_update_selection()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_selected = min(LEVELS.size() - 1, _selected + 1)
		_update_selection()
	elif event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(LEVELS[_selected].scene)

func _update_selection() -> void:
	for i in _cards.size():
		var card: ColorRect   = _cards[i]
		var border: ColorRect = _borders[i]
		if i == _selected:
			card.position.y = 238
			border.position.y = 234
			border.visible = true
		else:
			card.position.y = 250
			border.position.y = 246
			border.visible = false
