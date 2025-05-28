extends Sprite2D

@onready var Board: GameBoard = $".."

var mouse_position: Vector2 = Vector2.ZERO
var current_map: Vector2i = Vector2i.ZERO

func _process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	current_map = Board.global_to_map(mouse_position)
	if Board.is_map_in_bounds(current_map):
		position = Board.to_local(Board.map_to_global(current_map))
		show()
	else:
		hide()
