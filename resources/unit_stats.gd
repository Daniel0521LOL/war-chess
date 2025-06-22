@icon("res://assets/icons/swordwoman.svg")
extends Resource
class_name UnitStats

@export var name: String
@export var max_health: int = 5
@export var movement: int = 3
@export var animations: SpriteFrames
@export var weapons: Array[Weapon]
