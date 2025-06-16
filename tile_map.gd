class_name GameBoard
extends Node2D

const CELL_SIZE = Vector2i(32, 32)

@onready var Main: TileMapLayer = $Main
@onready var Highlight: TileMapLayer = $Highlight
@onready var Units: AllUnits = $'../AllUnits'

var _astar = AStarGrid2D.new()
var solid_maps: Array[Vector2i] = []

func _ready() -> void:
	_astar.region = Rect2i(0, 0, 11, 5)
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	#print(global_to_map(Vector2(270, 200)))
	for n in range(_astar.region.position[0], _astar.region.position[0] + _astar.region.size[0]):
		for m in range(_astar.region.position[1], _astar.region.position[1] + _astar.region.size[1]):
			if Main.get_cell_atlas_coords(Vector2i(n, m)) != Vector2i(0, 0):
				solid_maps.append(Vector2i(n, m))
			

func redraw_astar_grid(additional_remove_maps: Array[Vector2i]) -> void:
	_astar.fill_solid_region(_astar.region, false)
	for i in solid_maps + additional_remove_maps:
		print(i)
		_astar.set_point_solid(i)
	

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

func is_map_moveable(map_point: Vector2i, flying: bool = false) -> bool:
	if flying:
		return true
	if not _astar.is_point_solid(map_point):
		return true
	return false

func clear_highlight() -> void:
	Highlight.clear()

func set_highlight_at_map_points(map_points: Array, type: int = 1) -> void:
	if type not in [1, 2]:
		print("Set highlight type invalid!")
		return
	for i in map_points:
		Highlight.set_cell(i, 3, Vector2i(type, 0))

func get_unit_move_range(unit: Unit) -> Array:
	redraw_astar_grid(Units.get_occupied_maps_by_unit_group(1 - unit.unit_group))
	var unit_move_range = _flood_fill(unit.current_map, unit.stats.movement)
	var new_move_range = []
	var occupied_maps = Units.get_occupied_maps()
	for i in unit_move_range:
		if not i in occupied_maps:
			new_move_range.append(i)
	unit_move_range = new_move_range
	return unit_move_range

func _flood_fill(start_map: Vector2i, max_range: int) -> Array:
	var output_array := []
	var stack := [[start_map, max_range+1]]
	while not stack.is_empty():
		var i = stack.pop_front()
		print(i, is_map_moveable(i[0]))
		if i[1] == 0:
			continue
		
		output_array.append(i[0])
		
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var potential_new_map = i[0] + d
			if potential_new_map in output_array:
				continue
			if not is_map_in_bounds(potential_new_map) or not is_map_moveable(potential_new_map):
				continue
			stack.append([potential_new_map, i[1] - 1])
	return output_array

#func _flood_fill(start_map: Vector2i, max_range: int) -> Array:
	#var output_array := []
	#var stack := [start_map]
	#while not stack.is_empty():
		#var i = stack.pop_back()
		#print(i, is_map_moveable(i))
		#if i in stack:
			#continue
			#
		#var difference: Vector2 = (i - start_map).abs()
		#var distance := int(difference.x + difference.y)
		#if distance > max_range:
			#continue
		#
		#output_array.append(i)
		#
		#for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			#var potential_new_map = i + d
			#if potential_new_map in output_array:
				#continue
			#if not is_map_in_bounds(potential_new_map) or not is_map_moveable(potential_new_map):
				#continue
			#stack.append(potential_new_map)
	#return output_array
