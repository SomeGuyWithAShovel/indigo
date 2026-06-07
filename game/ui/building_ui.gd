extends Control
class_name BuildingUI

@onready var turret_button : BuildingUIButton = $PanelContainer/VBoxContainer/Turret;
@onready var missile_launcher_button : BuildingUIButton = $PanelContainer/VBoxContainer/MissileLauncher;
@onready var tube_button : BuildingUIButton = $PanelContainer/VBoxContainer/Tube;
@onready var hatch_button : BuildingUIButton = $PanelContainer/VBoxContainer/Hatch;
@onready var miner_button : BuildingUIButton = $PanelContainer/VBoxContainer/Miner;

var start_pos : Vector2 = Vector2.INF;

signal on_module_requested(id : ModuleId.Of)

func _ready() -> void:
	setup_prices();
	
func _enter_tree() -> void:
	if start_pos.is_equal_approx(Vector2.INF): 
		start_pos = position;
	position = start_pos;
	var transition : Tween = get_tree().create_tween();
	position.y += 200;
	transition.tween_property(self, "position:y", start_pos.y, 0.2);
	
func close_animation() -> void:
	var transition : Tween = get_tree().create_tween();
	transition.tween_property(self, "position:y", position.y + 100.0, 0.05);
	await transition.finished;
	
func setup_prices() -> void:
	# TODO Récupérer les vrais prix ici 
	# (déplacer ce dictionnaire là où il est utile me semble le mieux)
	var crystal_prices : Dictionary[ModuleId.Of, int] = {
		ModuleId.Of.TURRET:           5,
		ModuleId.Of.MISSILE_LAUNCHER: 8,
		ModuleId.Of.TUBE:             1,
		ModuleId.Of.HATCH:            3,
		ModuleId.Of.AUTO_MINER:       10,
	}
	
	var action_point_prices : Dictionary[ModuleId.Of, int] = {
		ModuleId.Of.TURRET:           30,
		ModuleId.Of.MISSILE_LAUNCHER: 50,
		ModuleId.Of.TUBE:             5,
		ModuleId.Of.HATCH:            10,
		ModuleId.Of.AUTO_MINER:       20,
	}
	
	turret_button.set_prices(crystal_prices[ModuleId.Of.TURRET], action_point_prices[ModuleId.Of.TURRET]);
	missile_launcher_button.set_prices(crystal_prices[ModuleId.Of.MISSILE_LAUNCHER], action_point_prices[ModuleId.Of.MISSILE_LAUNCHER]);
	miner_button.set_prices(crystal_prices[ModuleId.Of.AUTO_MINER], action_point_prices[ModuleId.Of.AUTO_MINER]);
	hatch_button.set_prices(crystal_prices[ModuleId.Of.HATCH], action_point_prices[ModuleId.Of.HATCH]);
	tube_button.set_prices(crystal_prices[ModuleId.Of.TUBE], action_point_prices[ModuleId.Of.TUBE]);

func on_button_down() -> void:
	Player.instance.set_selected_construction_type(ModuleId.Of.NONE);

func on_button_pressed(id : ModuleId.Of) -> void :
	# Vérifications dans les ressouces du joueur
	Player.instance.set_selected_construction_type(id);
	on_module_requested.emit(id);

func _turret_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TURRET);

func _missile_launcher_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.MISSILE_LAUNCHER);

func _tube_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.TUBE);

func _hatch_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.HATCH);

func _miner_button_pressed() -> void:
	on_button_pressed(ModuleId.Of.AUTO_MINER);
