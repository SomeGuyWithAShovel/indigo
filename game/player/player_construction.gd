class_name PlayerConstruction
extends Node

@export var player: Player = null;

func _enter_tree() -> void :
	assert(player != null);
	return;

func try_build_base_cell(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	if (construction_grid.is_terrain_ok_to_build(coords) == false) :
		print("trying to build base cell in a cell where the terrain is blocking construction");
		return false;
	
	if (construction_grid.can_build_base(coords) == false) :
		print("trying to build base cell in a cell where we can't build base cells");
		return false;
	const base_cell_cost: int = 500;
	var crystals: PlayerResource = player.crystals;
	if (crystals.has_amount(base_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [base_cell_cost, crystals.get_amount()]);
		return false;
	
	var set_result: bool = construction_grid.player_base.try_set_base_cell_at(coords);
	if (set_result == false) :
		return false;
	
	crystals.remove(base_cell_cost);
	print("spent %d crystals (%d remaining)" % [base_cell_cost, crystals.get_amount()]);
	return true;

func try_build_module_in_slot(module: PlayerBaseModules.Enum, slot: PlayerBaseModuleSlot) -> bool :
	var module_placed: bool = slot._raw_place_module(module);
	return module_placed;

func try_build_mining_cell(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	if (construction_grid.is_terrain_ok_to_build(coords) == false) :
		print("trying to build mining cell in a cell where the terrain is blocking construction");
		return false;
	
	if (construction_grid.can_build_miner(coords) == false) :
		print("trying to build mining cell in a cell where we can't build miners");
		return false;
		
	const mining_cell_cost: int = 800;
	var crystals: PlayerResource = player.crystals;
	if (crystals.has_amount(mining_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [mining_cell_cost, crystals.get_amount()]);
		return false;
	
	var set_result: bool = construction_grid.player_base.try_set_mining_cell_at(coords);
	if (set_result == false) :
		return false;
	
	crystals.remove(mining_cell_cost);
	print("spent %d crystals (%d remaining)" % [mining_cell_cost, crystals.get_amount()]);
	return true;
