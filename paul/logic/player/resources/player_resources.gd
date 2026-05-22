class_name PlayerResources
extends Node

# handles all the resources the player has

@export var crystals : PlayerResource = null;

func _enter_tree() -> void :
	assert(crystals != null);
	return;

func _exit_tree() -> void :
	crystals = null;
	return;
