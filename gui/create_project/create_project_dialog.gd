extends AcceptDialog

func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	const CreateProjectDialog = preload("res://gui/create_project/open_folder_dialog.tscn")

	var dialog: FileDialog = CreateProjectDialog.instantiate()
	add_child(dialog)
	dialog.visible = true
	$MarginContainer/VBoxContainer/HBoxContainer/LineEdit.text = await dialog.dir_selected
