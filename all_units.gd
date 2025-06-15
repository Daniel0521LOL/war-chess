extends Node2D
class_name AllUnits

var unit_log : Dictionary[Globals.UnitGroups, Array] = {
	Globals.UnitGroups.PLAYER: [],
	Globals.UnitGroups.ENEMY: []
}

func _ready() -> void:
	initiate_unit_log()

func initiate_unit_log() -> void:
	for i in get_children():
		unit_log[i.unit_group].append(i)

func get_units_in_group(group: Globals.UnitGroups) -> Array:
	return unit_log[group]

func find_unit_on_map(map_point: Vector2i) -> Unit:
	for i in get_children():
		#print(i, i.current_map)
		if i.current_map == map_point:
			return i
	return null

func get_occupied_maps() -> Array[Vector2i]:
	var occupied_maps: Array[Vector2i] = []
	for i in get_children():
		occupied_maps.append(i.current_map)
	return occupied_maps

func get_occupied_maps_by_unit_group(group: Globals.UnitGroups) -> Array[Vector2i]:
	var occupied_maps: Array[Vector2i] = []
	for i in unit_log[group]:
		occupied_maps.append(i.current_map)
	return occupied_maps
