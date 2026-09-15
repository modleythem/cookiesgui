extends MarginContainer

const PARAMETER = preload("res://gui/parameter.tscn")

var path: String
var parameters: Dictionary = { }

func _ready() -> void:
	var file: String = FileAccess.get_file_as_string(path)
	update(file)


func update(code: String):
	parameters = DoughParser.parse(code)

	for cats in parameters.keys():
		if cats == "transform":
			var category := Label.new()
			category.text = "Transform"
			category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			$HSplitContainer/Editor/Inspector/VBoxContainer.add_child(category)
			var params: Dictionary = parameters["transform"]
			for param in params.keys():
				var p := PARAMETER.instantiate()
				p.get_node("key").text = param
				p.get_node("value").value = params[param]
				var callable: Callable
				match param:
					"x":
						callable = func (value: float):
							%Dough.position.x = value
							parameters[cats].x = value
					"y":
						callable = func (value: float):
							%Dough.position.y = value
							parameters[cats].y = value
					"sx":
						callable = func (value: float):
							%Dough.scale.x = value
							parameters[cats].sx = value
					"sy":
						callable = func (value: float):
							%Dough.scale.y = value
							parameters[cats].sy = value
					"r":
						callable = func (value: float):
							%Dough.rotation = value
							parameters[cats].r = value
				callable.call(params[param])
				p.get_node("value").value_changed.connect(callable)
				$HSplitContainer/Editor/Inspector/VBoxContainer.add_child(p)
