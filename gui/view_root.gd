@tool
extends Node2D

func _draw() -> void:
	draw_line(Vector2(-100000, 0), Vector2(100000, 0), Color.ORANGE_RED)
	draw_line(Vector2(0, -100000), Vector2(0, 100000), Color.GREEN_YELLOW)
