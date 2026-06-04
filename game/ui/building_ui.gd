extends Control
class_name BuildingUI

signal on_module_requested(id : ModuleId.Of)

func on_button_pressed(id : ModuleId.Of) -> void:
	# Vérifications dans les ressouces du joueur
	on_module_requested.emit(id);


func _turret_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TURRET);


func _missile_launcher_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.MISSILE_LAUNCHER);


func _tube_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TUBE);
