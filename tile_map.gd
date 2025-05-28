class_name GameBoard
extends Node2D

const CELL_SIZE = Vector2i(32, 32)

@onready var Main: TileMapLayer = $Main
@onready var Highlight: TileMapLayer = $Highlight

var _astar = AStarGrid2D.new()

func _ready() -> void:
	_astar.region = Rect2i(0, 0, 11, 5)
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	#print(global_to_map(Vector2(270, 200)))
	

func global_to_map(global_point: Vector2) -> Vector2i:
	return Main.local_to_map(Main.to_local(global_point))

func map_to_global(map_point: Vector2i) -> Vector2:
	return Main.to_global(Main.map_to_local(map_point))

func find_path(_start_map: Vector2i, _end_map: Vector2i) -> PackedVector2Array:
	var path = _astar.get_point_path(_start_map, _end_map)
	for i in range(0, path.size()):
		path[i] = to_global(path[i])
	return path

func is_map_in_bounds(map_point: Vector2i) -> bool:
	return _astar.is_in_boundsv(map_point)

func clear_highlight() -> void:
	Highlight.clear()

func set_highlight_at_map_points(map_points: Array, type: int = 1) -> void:
	if type not in [1, 2]:
		print("Set highlight type invalid!")
		return
	for i in map_points:
		Highlight.set_cell(i, 3, Vector2i(type, 0))

func get_unit_move_range(unit: Unit) -> Array:
	return _flood_fill(unit.current_map, unit.movement_range)

func _flood_fill(start_map: Vector2i, max_range: int) -> Array:
	var output_array := []
	var stack := [start_map]
	while not stack.is_empty():
		var i = stack.pop_back()
		if not is_map_in_bounds(i):
			continue
		if i in stack:
			continue
			
		var difference: Vector2 = (i - start_map).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_range:
			continue
		
		output_array.append(i)
		
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var potential_new_map = i + d
			if potential_new_map in output_array:
				continue
			stack.append(potential_new_map)
	return output_array
	
