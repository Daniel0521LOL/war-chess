@icon("res://assets/icons/crossbow.svg")
extends Resource
class_name Weapon

@export var name: String = 'None'
@export var range: Array[Vector2i] = []
@export var damage: int = 0
@export var attack_type: Globals.DamageType
