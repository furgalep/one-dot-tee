extends Node2D

var w: float = 200.0
var h: float = 20.0
var battlements: bool = true

var _stone  := Color(0.50, 0.47, 0.42)
var _dark   := Color(0.28, 0.26, 0.22)
var _light  := Color(0.65, 0.62, 0.56)
var _shadow := Color(0.18, 0.16, 0.14)

func _draw() -> void:
	var hw := w / 2.0
	var hh := h / 2.0

	# Drop shadow
	draw_rect(Rect2(-hw + 2, hh, w, 4), _shadow)

	# Base stone
	draw_rect(Rect2(-hw, -hh, w, h), _stone)

	# Bottom shadow strip
	draw_rect(Rect2(-hw, hh - 3, w, 3), _dark)

	# Top highlight
	draw_rect(Rect2(-hw, -hh, w, 2), _light)

	# Brick rows — horizontal mortar lines
	var bh := 7.0
	var y := -hh + bh
	while y < hh:
		draw_rect(Rect2(-hw, y - 1, w, 2), _dark)
		y += bh

	# Brick columns — vertical mortar (alternating offset per row)
	var bw := 18.0
	y = -hh
	var row := 0
	while y < hh:
		var off := (row % 2) * (bw * 0.5)
		var x := -hw + off
		while x < hw:
			draw_rect(Rect2(x - 1, y, 2, bh), _dark)
			x += bw
		y += bh
		row += 1

	# Battlements (crenellations on top)
	if battlements:
		var mw := 10.0  # merlon width
		var gw :=  7.0  # gap (crenel) width
		var mh := 10.0  # merlon height
		var x   := -hw + 3.0
		while x + mw <= hw - 2:
			# Merlon body
			draw_rect(Rect2(x, -hh - mh, mw, mh + 2), _stone)
			# Top highlight
			draw_rect(Rect2(x, -hh - mh, mw, 2), _light)
			# Side shadows
			draw_rect(Rect2(x, -hh - mh, 2, mh), _dark)
			draw_rect(Rect2(x + mw - 2, -hh - mh, 2, mh), _dark)
			# Brick line on merlon
			draw_rect(Rect2(x, -hh - mh + 5, mw, 1), _dark)
			x += mw + gw
