class_name PlayerConstruction
extends Node

@export var player: Player = null;
@export var construction_grid: ConstructionGrid = null;

func _enter_tree() -> void :
	assert(player != null);
	assert(construction_grid != null);
	return;

func try_build_base_cell(coords: Vector2i) -> bool :
	const base_cell_cost: int = 500;
	var crystals: PlayerResource = player.resources.crystals;
	if (crystals.has_amount(base_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [base_cell_cost, crystals.get_amount()]);
		return false;
	
	var set_result: bool = construction_grid.player_base.try_set_cell_at(coords);
	if (set_result == false) :
		return false;
	
	crystals.remove(base_cell_cost);
	print("spent %d crystals (%d remaining)" % [base_cell_cost, crystals.get_amount()]);
	return true;

func try_build_module_in_slot(module: PlayerBaseModules.Enum, slot: PlayerBaseModuleSlot) -> bool :
	var module_placed: bool = slot._raw_place_module(module);
	return module_placed;
