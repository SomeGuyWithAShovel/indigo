class_name MiningCell
extends PlayerBaseCell

var crystal_tile: CrystalTile;

var is_ghost = false;

func _enter_tree() -> void :
	if is_ghost:
		return
	assert(crystal_tile != null);
	building_type = cell_type.AUTO_MINER
	return;

func mining_operation() -> int :
	return crystal_tile.crystal_amount_per_operation;
