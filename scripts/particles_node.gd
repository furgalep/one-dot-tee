extends Node2D

var particles: Array = []

func update(delta: float) -> void:
	if particles.is_empty():
		return
	var alive := []
	for p in particles:
		p.life -= delta / p.max_life
		p.pos += p.vel * delta
		p.vel *= 0.93
		if p.life > 0.0:
			alive.append(p)
	particles = alive
	queue_redraw()

func _draw() -> void:
	for p in particles:
		var c: Color = p.col
		c.a = p.life
		draw_circle(p.pos, p.size * p.life, c)
