class_name Player
extends Node

# handles the "abstract" Player
# not the in-world character, but everything player related (including the in-world character)

@export_group("Local References")
@export var resources: PlayerResources = null;
@export var construction: PlayerConstruction = null;

@export_group("Extern References")
@export var character: PlayerCharacter = null;
@export var construction_grid: ConstructionGrid = null;

func _enter_tree() -> void :
	assert(resources != null);
	assert(character != null);
	assert(construction_grid != null);
	assert(construction != null);
	construction.construction_grid = construction_grid;
	
	return;
