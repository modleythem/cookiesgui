extends Node
class_name DoughSerializer

const INDENT: String = "    "
static var indent_level: int = 0
static var buffer: String = "return {\n"


static func serialize(dough: Dictionary) -> String:
	serialize_table(dough)
	indent_level = 0
	var buf = buffer
	buffer = "return {\n"
	return buf

static func serialize_table(tbl: Dictionary) -> void:
	indent_level += 1

	for item in tbl.keys():
		match typeof(item):
			TYPE_STRING:
				var i = tbl[item]
				if i != null:
					if typeof(i) == TYPE_DICTIONARY:
						add_line(str(item, " = {"))
						serialize_table(i)
						continue
					else:
						add_line(str(item, " = ", i, ","))
				else:
					push_error()
			TYPE_INT:
				var i = tbl[item]
				if i != null:
					if typeof(i) == TYPE_DICTIONARY:
						add_line("{")
						serialize_table(i)
						continue
					else:
						add_line(str(i, ","))
				else:
					add_line(str(tbl))

	indent_level -= 1
	add_line("}" if indent_level == 0 else "},")

static func add_line(line: String) -> void:
	for i in range(indent_level):
		buffer += INDENT
	buffer += line
	buffer += "\n"
