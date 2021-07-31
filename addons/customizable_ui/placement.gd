#  1/3  1/3   1/3
# +--------------+
# |   | Top  |   | 1/3
# | L +------+ R |
# | e |Middle| i | 1/3
# | f |      | g |
# | t +------+ h |
# |   |Bottom| t | 1/3
# +--------------+

var left : bool
var right : bool
var top : bool
var bottom : bool
var vertical : bool
var horizontal : bool
var middle : bool
var first : bool
var index : int
var _position : Vector2

func _init(x : int, y : int) -> void:
	_position = Vector2(x, y)
	if _position == Vector2.ZERO:
		middle = true
	else:
		horizontal = abs(x)
		vertical = not horizontal
	top = _position == Vector2.UP
	bottom = _position == Vector2.DOWN
	left = _position == Vector2.LEFT
	right = _position == Vector2.RIGHT
	first = left or top
	index = 0 if first else 1
