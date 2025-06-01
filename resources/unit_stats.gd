extends Resource
class_name UnitStats

@export var name: String
@export var max_health: int = 5
@export var attack_range: Array[Vector2i] = []
@export var attack_damage: int = 2
@export var attack_type: Globals.DamageType
@export var animations: SpriteFrames
