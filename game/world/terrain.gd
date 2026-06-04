class_name Terrain
extends Node3D

@export var construction_grid: ConstructionGrid = null;

func _enter_tree() -> void :
	assert(construction_grid != null);
	return;

func _ready() -> void :
	print("Terrain: CrystalTiles=", construction_grid.crystal_tiles);
	return;
