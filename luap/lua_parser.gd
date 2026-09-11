extends Node
class_name DoughParser

enum TKTYPE {
	RETURN,

	OPENCBR,
	CLOSECBR,
	OPENSBR,
	CLOSESBR,

	NAME,

	EQ,
	COMMA,

	NUMBER,
	BOOLEAN,
	STRING,
	NIL,

	EOF
}

class Token extends RefCounted:
	var type: TKTYPE
	var line: int
	var pos: int
	var value: Variant

	func _init(_type: TKTYPE, _line: int, _pos: int, _value: Variant = null) -> void:
		type = _type
		line = _line
		pos = _pos
		value = _value

	func _to_string() -> String:
		var v: String
		match type:
			TKTYPE.RETURN:
				v = "return"
			TKTYPE.OPENCBR:
				v = "{"
			TKTYPE.CLOSECBR:
				v = "}"
			TKTYPE.NAME:
				v = value as String
			TKTYPE.EQ:
				v = "="
			TKTYPE.COMMA:
				v = ","
			TKTYPE.NUMBER:
				v = str(value as float)
			TKTYPE.BOOLEAN:
				v = str(value as bool)
			TKTYPE.STRING:
				v = value as String
			TKTYPE.NIL:
				v = "nil"
			TKTYPE.EOF:
				v = ""

		return v



static var tokens: Array[Token]
static var current: int

static func parse(code: String) -> Dictionary:
	lexer(code)
	expect(TKTYPE.RETURN)
	
	var dough = parse_value()
	assert(typeof(dough) == TYPE_DICTIONARY)

	return dough

static func parse_value() -> Variant:
	var token := eat()

	match token.type:
		TKTYPE.OPENCBR:
			return parse_table()
		TKTYPE.BOOLEAN:
			return token.value as bool
		TKTYPE.NUMBER:
			return token.value as float
		TKTYPE.STRING:
			return token.value as String
		TKTYPE.NIL:
			return "nil"
		_:
			push_error("unexpected token")
			return

static func parse_table() -> Dictionary:
	var table := {}
	var count := 0

	while (tokens[current].type != TKTYPE.CLOSECBR):
		var id := tokens[current]
		if id.type == TKTYPE.NAME:
			eat()
			expect(TKTYPE.EQ)
			var value = parse_value()
			table[id.value as String] = value
		elif id.type == TKTYPE.OPENSBR:
			eat()
			var key = parse_value()
			expect(TKTYPE.CLOSESBR)
			expect(TKTYPE.EQ)
			var value = parse_value()
			table[key] = value
		else:
			count += 1
			table[count] = parse_value()

		if tokens[current].type != TKTYPE.CLOSECBR:
			expect(TKTYPE.COMMA)


	current += 1 # skip }

	return table


static func eat() -> Token:
	var tk = tokens[current]
	current += 1
	return tk

static func expect(type: TKTYPE) -> Token:
	var tk = eat()
	assert(tk.type == type, "expected " + TKTYPE.keys()[type] + ", got " + TKTYPE.keys()[tk.type])
	return tk



static func lexer(code: String) -> void:
	var lines: PackedStringArray = code.split("\n")
	tokens = []

	var l: int = 0
	while l < lines.size():
		var chars: PackedStringArray = lines[l].split("")
		var c: int = 0
		while c < chars.size():
			var ch := chars[c]

			# number
			if ch.is_valid_float():
				var pos: int = c
				var buffer: String = ch
				while c + 1 < chars.size() and (buffer + chars[c + 1]).is_valid_float():
					c += 1
					buffer += chars[c]
					if c >= chars.size():
						break
				tokens.push_back(Token.new(TKTYPE.NUMBER, l+1, pos+1, buffer.to_float()))

			# string
			elif ch == '"':
				var pos = c
				var buffer: String = ch
				c += 1
				while (chars[c] != '"'):
					buffer += chars[c]
					c += 1
					if c >= chars.size():
						printerr("unclosed string")
						break
				buffer += '"'
				tokens.push_back(Token.new(TKTYPE.STRING, l+1, pos+1, buffer))
			elif ch == "'":
				var pos = c
				var buffer: String = ch
				c += 1
				while (chars[c] != "'"):
					buffer += chars[c]
					c += 1
					if c >= chars.size():
						printerr("unclosed string")
						break
				buffer += "'"
				tokens.push_back(Token.new(TKTYPE.STRING, l+1, pos+1, buffer))

			# special
			elif ch == "{":
				tokens.push_back(Token.new(TKTYPE.OPENCBR, l+1, c+1))
			elif ch == "}":
				tokens.push_back(Token.new(TKTYPE.CLOSECBR, l+1, c+1))
			elif ch == "[":
				tokens.push_back(Token.new(TKTYPE.OPENSBR, l+1, c+1))
			elif ch == "]":
				tokens.push_back(Token.new(TKTYPE.CLOSESBR, l+1, c+1))
			elif ch == "=":
				tokens.push_back(Token.new(TKTYPE.EQ, l+1, c+1))
			elif ch == ",":
				tokens.push_back(Token.new(TKTYPE.COMMA, l+1, c+1))

			# comments
			elif ch == "-":
				if chars[c] + chars[c + 1] == "--":
					while c < chars.size():
						c += 1
					break
				push_error("wrong character")

			# indentifiers/keywords
			elif chars[c].is_valid_ascii_identifier():
				var pos: int = c
				var buffer: String = ch
				while c + 1 < chars.size() and (buffer + chars[c + 1]).is_valid_ascii_identifier():
					c += 1
					buffer += chars[c]
					if c >= chars.size():
						break
				match buffer:
					"return":
						tokens.push_back(Token.new(TKTYPE.RETURN, l+1, pos+1))
					"true":
						tokens.push_back(Token.new(TKTYPE.BOOLEAN, l+1, pos+1, true))
					"false":
						tokens.push_back(Token.new(TKTYPE.BOOLEAN, l+1, pos+1, false))
					"nil":
						tokens.push_back(Token.new(TKTYPE.NIL, l+1, pos+1, null))
					_:
						tokens.push_back(Token.new(TKTYPE.NAME, l+1, pos+1, buffer))

			# indentation/empty
			elif ch == " " || ch == "\t" || ch == "\r":
				while chars[c] == " " || chars[c] == "\t":
					c += 1
					if c >= chars.size():
						break
				continue

			c += 1

		l += 1

	tokens.push_back(Token.new(TKTYPE.EOF, l, lines[l - 1].length()))
