class_name Unit
extends Node2D

signal finished_moving

enum States { IDLE, MOVING }
var state = States.IDLE

@onready var game_board: GameBoard = $"../../GameBoard"

@export var start_map: Vector2i = Vector2i(0, 0)
@export var unit_group: Globals.UnitGroups = 0
@export var stats: UnitStats
@onready var health: int = stats.max_health

var current_map: Vector2i
var path = PackedVector2Array()

var move_availible = true
var action_availible = true

var speed = 200

var selected: bool = false
@onready var current_weapon: Weapon = stats.primary_weapon

func _ready() -> void:
	$AnimatedSprite.sprite_frames = stats.animations
	change_state(States.IDLE)
	set_position_to_map(start_map)
	print(current_map)
	$HealthDisplay.text = str(health) + "/" + str(stats.max_health)

	#path = game_board.find_path(current_map, Vector2i(6, 2))
	#change_state(States.MOVING)

func _process(delta: float) -> void:
	match state:
		States.IDLE:
			pass
		States.MOVING:
			var arrived = step_toward(path[0], delta)
			if arrived:
				if path.size() == 1:
					change_state(States.IDLE)
					#current_map = game_board.global_to_map(path[0])
					print(current_map)
				path.remove_at(0)

func move_to_map(target_map: Vector2i) -> bool:
	if move_availible:
		path = game_board.find_path(current_map, target_map)
		path.remove_at(0)
		change_state(States.MOVING)
		current_map = target_map
		move_availible = false
		return true
	return false

func change_state(_new_state: States) -> void:
	match state:
		States.IDLE:
			pass
		States.MOVING:
			emit_signal("finished_moving")
	state = _new_state
	match state:
		States.IDLE:
			$AnimatedSprite.play("idle")
		States.MOVING:
			$AnimatedSprite.play("moving")

func change_weapon() -> void:
	if current_weapon == stats.primary_weapon:
		current_weapon = stats.secondary_weapon
	else:
		current_weapon = stats.primary_weapon

func select_unit() -> void:
	selected = true

func deselect_unit() -> void:
	selected = false

func get_attackable_maps() -> Array[Vector2i]:
	var attackable_maps: Array[Vector2i] = current_weapon.range.duplicate()
	for i in range(0, len(attackable_maps)):
		attackable_maps[i] += current_map
	return attackable_maps

func do_attack() -> DamageInstance:
	var damage_instance = DamageInstance.new()
	damage_instance.amount = current_weapon.damage
	damage_instance.type = current_weapon.attack_type
	action_availible = false
	$AnimatedSprite.play("attack")
	await $AnimatedSprite.animation_finished
	$AnimatedSprite.play("idle")
	return damage_instance

func take_damage(damage_instance: DamageInstance) -> void:
	health -= damage_instance.amount
	$HealthDisplay.text = str(health) + "/" + str(stats.max_health)
	print(health, "/", stats.max_health)
	if health <= 0:
		queue_free()

func step_toward(_target_position: Vector2, delta: float) -> bool:
	position = position.move_toward(_target_position, speed * delta)
	return position == _target_position

func set_position_to_map(target_map: Vector2i) -> void:
	current_map = target_map
	position = game_board.map_to_global(target_map)

func end_turn() -> void:
	move_availible = true
	action_availible = true

func is_moving() -> bool:
	if state == States.MOVING:
		return true
	return false
