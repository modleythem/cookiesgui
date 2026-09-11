extends TabContainer

const PARAMETER = preload("uid://3uj8it73f1k8")


func _ready() -> void:
	var file = FileAccess.get_file_as_string("/home/callmemo/Projects/cookies/cookieslib/example/test.dough.lua")

	var dough = DoughParser.parse(file)

	for cats in dough.keys():
		if cats == "transform":
			var category := Label.new()
			category.text = "Transform"
			category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			$Inspector/VBoxContainer.add_child(category)
			var params: Dictionary = dough["transform"]
			for param in params.keys():
				var p := PARAMETER.instantiate()
				p.get_node("key").text = param
				p.get_node("value").value = params[param]
				var callable: Callable
				match param:
					"x":
						callable = func (value: float):
							%Dough.position.x = value
							dough[cats].x = value
					"y":
						callable = func (value: float):
							%Dough.position.y = value
							dough[cats].y = value
					"sx":
						callable = func (value: float):
							%Dough.scale.x = value
							dough[cats].sx = value
					"sy":
						callable = func (value: float):
							%Dough.scale.y = value
							dough[cats].sy = value
					"r":
						callable = func (value: float):
							%Dough.rotation = value
							dough[cats].r = value
				callable.call(params[param])
				p.get_node("value").connect("value_changed", callable)
				$Inspector/VBoxContainer.add_child(p)
