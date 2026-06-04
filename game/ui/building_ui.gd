extends Control
class_name BuildingUI

signal on_module_requested(id : ModuleId)

func on_button_pressed(id : ModuleId) -> void:
	# Vérifications dans les ressouces du joueur
	on_module_requested.emit(id);
