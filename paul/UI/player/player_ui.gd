class_name PlayerUI
extends Control

@onready var player: Player = $"..";

func _ready() -> void :
	assert(player != null);
	return;

func on_player_base_cell_selected() -> void :
	print("on_player_base_cell_selected");
	return;

func on_player_base_module_selected() -> void :
	print("on_player_base_module_selected");
	return;
