class_name MiningCell
extends Node3D

var crystal_tile: CrystalTile;

func _enter_tree() -> void :
	assert(crystal_tile != null);
	return;

func mining_operation() -> int :
	return crystal_tile.crystal_amount_per_operation;
