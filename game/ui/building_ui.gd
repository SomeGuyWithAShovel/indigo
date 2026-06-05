extends Control
class_name BuildingUI

@onready var turret_button : BuildingUIButton = $PanelContainer/VBoxContainer/Turret;
@onready var missile_launcher_button : BuildingUIButton = $PanelContainer/VBoxContainer/MissileLauncher;
@onready var tube_button : BuildingUIButton = $PanelContainer/VBoxContainer/Tube;
@onready var hatch_button : BuildingUIButton = $PanelContainer/VBoxContainer/Hatch;

signal on_module_requested(id : ModuleId.Of)

func _ready() -> void:
	setup_prices();
	
func _enter_tree() -> void:
	var transition : Tween = get_tree().create_tween();
	var start_pos := position.x;
	position.x += 200;
	transition.tween_property(self, "position:x", start_pos, 0.2);
	
func setup_prices() -> void:
	# TODO
	pass;

func on_button_pressed(id : ModuleId.Of) -> void:
	# Vérifications dans les ressouces du joueur
	on_module_requested.emit(id);


func _turret_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TURRET);


func _missile_launcher_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.MISSILE_LAUNCHER);


func _tube_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TUBE);


func _hatch_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.HATCH);
