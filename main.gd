extends Control

func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2i(640, 480))

func _on_panel_resized() -> void:
	$DoughView.size = %ViewPanel.size
