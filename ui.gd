extends Control

@onready var UnitName = $"MarginContainer/HBoxContainer/UnitStats/MarginContainer/VBoxContainer/UnitName"
@onready var HP = $"MarginContainer/HBoxContainer/UnitStats/MarginContainer/VBoxContainer/GridContainer/HPAmount"
@onready var MOV = $"MarginContainer/HBoxContainer/UnitStats/MarginContainer/VBoxContainer/GridContainer/MOVAmount"

#func _process(delta: float) -> void:
	#if Globals.selected_unit:
		#UnitName.text = Globals.selected_unit.stats.name
		#HP.text = str(Globals.selected_unit.health) + ' / ' + str(Globals.selected_unit.stats.max_health)
		#MOV.text = str(Globals.selected_unit.stats.movement)
