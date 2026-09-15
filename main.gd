extends Control

func _ready() -> void:
	DisplayServer.window_set_min_size(Vector2i(640, 480))


func _on_file_index_pressed(index: int) -> void:
	match index:
		0: # create project
			create_project()
		1: # load project
			load_project()
		2: # open file
			open_dough_file()
		3: # save
			save_dough_file()

func create_project():
	pass # todo

func load_project():
	pass # todo

func open_dough_file():
	const DOUGH_FILE_DIALOG = preload("res://gui/dough_file_dialog.tscn")

	var dialog: FileDialog = DOUGH_FILE_DIALOG.instantiate()
	add_child(dialog)
	dialog.visible = true

	var filepath: String = await dialog.file_selected
	dialog.queue_free()

	if Globals.opened_files.has(filepath):
		return

	const DOUGH_FILE_TAB = preload("res://gui/dough_file_tab.tscn")
	var tab: Control = DOUGH_FILE_TAB.instantiate()
	tab.path = filepath
	tab.name = filepath.get_file().get_basename().get_basename()
	%Tabs.add_child(tab)

func save_dough_file():
	pass
