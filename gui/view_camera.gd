extends Camera2D

var zoom_amount: float =  1.0:
	set(v):
		zoom_amount = v
		zoom = Vector2(v, v)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			position -= event.relative / zoom

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_amount = max(zoom_amount - .05, .5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_amount = min(zoom_amount + .05, 3)
