extends Node2D

# Draws a tiled stone wall behind the level
const W := 1380.0
const H := 900.0

func _draw() -> void:
	# Base fill
	draw_rect(Rect2(-50, -200, W + 100, H + 300), Color(0.10, 0.09, 0.12))

	# Stone blocks
	var stone := Color(0.17, 0.15, 0.18)
	var bw := 64.0
	var bh := 32.0
	var row := 0
	var y := -192.0
	while y < H + 64:
		var off := (row % 2) * (bw * 0.5)
		var x := -48.0
		while x < W:
			draw_rect(Rect2(x + off, y, bw - 3, bh - 3), stone)
			x += bw
		y += bh
		row += 1

	# Vertical pillar strips every 160px for depth
	var pillar_col := Color(0.13, 0.11, 0.14)
	var x := 0.0
	while x <= W:
		draw_rect(Rect2(x - 6, -200, 12, H + 400), pillar_col)
		x += 160.0

	# Ambient top darkness (ceiling)
	draw_rect(Rect2(-50, -200, W + 100, 100), Color(0.05, 0.04, 0.07))
