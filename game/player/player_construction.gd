class_name PlayerConstruction
extends Node

@export var player: Player = null;

func _enter_tree() -> void :
	assert(player != null);
	return;

func try_construct_cell(construction_grid: ConstructionGrid, coords: Vector2i, construction_type: ModuleId.Of) -> bool :
	var callables: Dictionary[ModuleId.Of, Callable] = {
		ModuleId.Of.TURRET : try_construct_turret,
		ModuleId.Of.MISSILE_LAUNCHER : try_construct_turret,
		ModuleId.Of.TUBE : try_build_base_cell,
		ModuleId.Of.AUTO_MINER : try_build_mining_cell ,
	};
	
	var return_value: bool = false;
	if (callables.has(construction_type) == false) :
		print("try_construct_cell() : type ", construction_type, " is not implemented");
		return false;
	if (construction_type_is_turret(construction_type)) :
		return_value = callables[construction_type as int].call(construction_grid, coords, construction_type);
		pass;
	else:
		return_value = callables[construction_type as int].call(construction_grid, coords);
	return return_value;

static func construction_type_is_turret(construction_type: ModuleId.Of) -> bool :
	const turret_types: Array[ModuleId.Of] = [
		ModuleId.Of.TURRET, 
		ModuleId.Of.MISSILE_LAUNCHER
	];
	return turret_types.has(construction_type);

func try_construct_turret(_construction_grid: ConstructionGrid, _coords: Vector2i, _turret_type: ModuleId.Of) -> bool :
	# TODO
	print("try_construct_turret() : not yet implemented");
	return false;

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
