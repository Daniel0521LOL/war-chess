extends Node

@onready var Board: GameBoard = $"../GameBoard"
@onready var Units: AllUnits = $"../AllUnits"

var unit_move_range: Array = []
var unit_attack_range: Array = []
var player_input_on: bool = true
var current_active_group: Globals.UnitGroups = 0
var turn_count: int = 0



func _next_group() -> void:
	for i in Units.get_units_in_group(current_active_group):
		i.end_turn()
	
	# "on exit" functions
	match current_active_group:
		Globals.UnitGroups.PLAYER:
			player_input_on = false
		Globals.UnitGroups.ENEMY:
			pass
			
	current_active_group += 1
	
	# "on enter" functions
	match current_active_group:
		Globals.UnitGroups.PLAYER:
			player_input_on = true
		Globals.UnitGroups.ENEMY:
			pass
		Globals.UnitGroups.UNIT_GROUP_LEN:
			current_active_group = 0
			player_input_on = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		print("Enter detected. Next turn.")
		deselect_unit()
		_next_group()
		print("Current active group enum: ", current_active_group)
	if Globals.selected_unit:
		if event.is_action_pressed("cycle") and Globals.selected_unit.action_availible and not Globals.selected_unit.move_availible:
			Globals.selected_unit.change_weapon()
			select_unit(Globals.selected_unit)
	if event is InputEventMouseButton and player_input_on and event.is_pressed():
		var clicked_global_position = get_viewport().canvas_transform.affine_inverse() * event.position
		print(clicked_global_position, Board.global_to_map(clicked_global_position))
		var clicked_map = Board.global_to_map(clicked_global_position)
		if not Board.is_map_in_bounds(clicked_map):
			return
		var unit_on_tile = Units.find_unit_on_map(clicked_map)
		if Globals.selected_unit:
			if Globals.selected_unit.move_availible and clicked_map in unit_move_range:
				await command_selected_unit_to_map(clicked_map)
				select_unit(Globals.selected_unit) # Refresh tile highlights
			elif Globals.selected_unit.action_availible and clicked_map in unit_attack_range:
				selected_unit_attack_at_map(clicked_map)
				deselect_unit()
			else:
				deselect_unit()
				if unit_on_tile:
					select_unit(unit_on_tile)
		else:
			if unit_on_tile:
				select_unit(unit_on_tile)

func select_unit(unit: Unit):
	Globals.selected_unit = unit
	if Globals.selected_unit.move_availible:
		unit_move_range = Board.get_unit_move_range(Globals.selected_unit)
		Board.clear_highlight()
		Board.set_highlight_at_map_points(unit_move_range, 1)
	elif Globals.selected_unit.action_availible:
		unit_attack_range = unit.get_attackable_maps()
		var new_attack_range = []
		for i in unit_attack_range:
			if Board.is_map_in_bounds(i):
				new_attack_range.append(i)
		unit_attack_range = new_attack_range
		Board.clear_highlight()
		Board.set_highlight_at_map_points(unit_attack_range, 2)

func deselect_unit():
	if not Globals.selected_unit:
		return
	Globals.selected_unit.deselect_unit()
	Globals.selected_unit = null
	unit_attack_range = []
	unit_move_range = []
	Board.clear_highlight()

func selected_unit_attack_at_map(map: Vector2i):
	if not Globals.selected_unit:
		return
	player_input_on = false
	var damage_instance = await Globals.selected_unit.do_attack()
	player_input_on = true
	#Globals.selected_unit.get_node("AnimatedSprite").animation_finished.connect(
		#func():
			#var target_unit = Units.find_unit_on_map(map)
			#if target_unit:
				#target_unit.take_damage(damage_instance)
	#)
	var target_unit = Units.find_unit_on_map(map)
	if target_unit:
		target_unit.take_damage(damage_instance)

func command_selected_unit_to_map(map: Vector2i):
	Board.clear_highlight()
	if Globals.selected_unit.move_to_map(map):
		player_input_on = false
		await Globals.selected_unit.finished_moving
		player_input_on = true
