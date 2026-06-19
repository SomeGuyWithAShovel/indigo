class_name PlayerConstruction
extends Node

@export var player: Player = null;
@export var construction_sound: AudioStreamPlayer = null;

signal on_cell_constructed(construction_grid: ConstructionGrid, coords: Vector2i, construction_type: ModuleId.Of);

enum Construction_Result{
	Possible,
	NoCrystal,
	NoActionP,
	InvalidPlacement,
	NeedNearTube,
	NoSlotAvaible,
	Other
}

func _enter_tree() -> void :
	assert(player != null);
	assert(construction_sound != null);
	return;

func check_construct_cell(construction_grid: ConstructionGrid, coords: Vector2i, construction_type: ModuleId.Of) -> Construction_Result :
	var callables: Dictionary[ModuleId.Of, Callable] = {
		ModuleId.Of.TURRET : check_construct_turret,
		ModuleId.Of.MISSILE_LAUNCHER : check_construct_turret,
		ModuleId.Of.TUBE : check_build_base_cell,
		ModuleId.Of.AUTO_MINER : check_build_mining_cell ,
		ModuleId.Of.HATCH: check_build_door,
	};
	
	var return_value: Construction_Result = Construction_Result.Other;
	if (callables.has(construction_type) == false) :
		print("check_construct_cell() : type ", construction_type, " is not implemented");
		return Construction_Result.Other;
	if (construction_type_is_turret(construction_type)) :
		return_value = callables[construction_type as int].call(construction_grid, coords, construction_type);
		pass;
	else:
		return_value = callables[construction_type as int].call(construction_grid, coords);
	return return_value;



func try_construct_cell(construction_grid: ConstructionGrid, coords: Vector2i, construction_type: ModuleId.Of) -> bool :
	var callables: Dictionary[ModuleId.Of, Callable] = {
		ModuleId.Of.TURRET : try_construct_turret,
		ModuleId.Of.MISSILE_LAUNCHER : try_construct_turret,
		ModuleId.Of.TUBE : try_build_base_cell,
		ModuleId.Of.AUTO_MINER : try_build_mining_cell ,
		ModuleId.Of.HATCH: try_build_door,
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
	
	if (return_value == true) : 
		on_cell_constructed.emit(construction_grid, coords, construction_type);
	return return_value;

static func construction_type_is_turret(construction_type: ModuleId.Of) -> bool :
	const turret_types: Array[ModuleId.Of] = [
		ModuleId.Of.TURRET, 
		ModuleId.Of.MISSILE_LAUNCHER
	];
	return turret_types.has(construction_type);

func check_construct_turret(_construction_grid: ConstructionGrid, _coords: Vector2i, _turret_type: ModuleId.Of) -> Construction_Result :
	if (_construction_grid.is_terrain_ok_to_build(_coords) == false) :
		return Construction_Result.InvalidPlacement;
	
	if (_construction_grid.can_build_turret(_coords) == false) :
		return Construction_Result.InvalidPlacement;
		
	#Different cout de tourelle
	var turret_type:PlayerBaseCells.cell_type = PlayerBaseCells.cell_type.CLASSIC_TURRET;
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	
	if _turret_type == ModuleId.Of.MISSILE_LAUNCHER:
		turret_type = PlayerBaseCells.cell_type.MISSILE_LAUNCHER
	
	var turret_cell_cost: int = PlayerBaseCells.crystal_costs[turret_type];
	var turret_AP_cost:int = PlayerBaseCells.action_costs[turret_type]
	
	
	if (crystals.has_amount(turret_cell_cost) == false) :
		return Construction_Result.NoCrystal;
	if (action_points.has_amount(turret_AP_cost) == false) :
		return Construction_Result.NoActionP;
	
	if (_construction_grid.player_base.has_any_cell(_coords)) :
		return Construction_Result.InvalidPlacement;;
	return Construction_Result.Possible

func check_build_base_cell(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	if (construction_grid.is_terrain_ok_to_build(coords) == false) :
		return Construction_Result.InvalidPlacement;
	
	if (construction_grid.can_build_base(coords) == false) :
		return Construction_Result.InvalidPlacement;
	
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var base_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.BASE_CELL];
	var base_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.BASE_CELL];
	if (crystals.has_amount(base_cell_cost) == false) :
		return Construction_Result.NoCrystal;
	
	if (action_points.has_amount(base_action_points_cost) == false) :
		return Construction_Result.NoActionP;
	
	if (construction_grid.player_base.has_any_cell(coords)) :
		return Construction_Result.InvalidPlacement;;
	return Construction_Result.Possible

func check_build_module_in_slot(module: PlayerBaseModules.Enum, slot: PlayerBaseModuleSlot) -> bool :
	var module_placed: bool = slot.check_module(module);
	return module_placed;

func check_build_mining_cell(construction_grid: ConstructionGrid, coords: Vector2i) -> Construction_Result :
	if (construction_grid.is_terrain_ok_to_build(coords) == false) :
		return Construction_Result.InvalidPlacement;
	
	if (construction_grid.can_build_miner(coords) == false) :
		return Construction_Result.InvalidPlacement;
		
	var has_neighbor_base : bool = [
		(coords + Vector2i(  1,  0)),
		(coords + Vector2i(  0, -1)),
		(coords + Vector2i( -1,  0)),
		(coords + Vector2i(  0,  1)),
	].any(construction_grid.player_base.has_base_cell);
	if not has_neighbor_base:
		return Construction_Result.NeedNearTube;
		
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var mining_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.AUTO_MINER];
	var mining_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.AUTO_MINER];
	if (crystals.has_amount(mining_cell_cost) == false) :
		return Construction_Result.NoCrystal;
	
	if (action_points.has_amount(mining_action_points_cost) == false) :
		return Construction_Result.NoActionP;
	
	if (construction_grid.player_base.has_any_cell(coords)) :
		return Construction_Result.InvalidPlacement;;
	return Construction_Result.Possible

func check_build_door(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	#Verification que la cellule a un module
	var cell_to_construct:PlayerBaseCell = construction_grid.player_base.base_cells.get(coords)
	if cell_to_construct == null:
		return Construction_Result.InvalidPlacement
	if !cell_to_construct.hasModuleAvaibleSlot():
		return Construction_Result.NoSlotAvaible
	
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var door_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.DOOR];
	var door_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.DOOR];
	if (crystals.has_amount(door_cell_cost) == false) :
		return Construction_Result.NoCrystal;
	
	if (action_points.has_amount(door_action_points_cost) == false) :
		return Construction_Result.NoActionP;
	
	
	#On prends la premiere car pas le temps
	#TODO voir quelle moduleslot le player q cliquer plutot que seulement la cellule de grid
	#pour avoir plusieur module slote dans une cell
	var module_slot:PlayerBaseModuleSlot = cell_to_construct.moduleslots_array[0]
	var set_result: bool = check_build_module_in_slot(PlayerBaseModules.Enum.Door,module_slot);
	if (set_result == false) :
		return Construction_Result.Other;
	
	return Construction_Result.Possible;








func try_construct_turret(_construction_grid: ConstructionGrid, _coords: Vector2i, _turret_type: ModuleId.Of) -> bool :
	if (_construction_grid.is_terrain_ok_to_build(_coords) == false) :
		print("trying to build base cell in a cell where the terrain is blocking construction");
		return false;
	
	if (_construction_grid.can_build_turret(_coords) == false) :
		print("trying to build base cell in a cell where we can't build base cells");
		return false;
		
	#Different cout de tourelle
	var turret_type:PlayerBaseCells.cell_type = PlayerBaseCells.cell_type.CLASSIC_TURRET;
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	
	if _turret_type == ModuleId.Of.MISSILE_LAUNCHER:
		turret_type = PlayerBaseCells.cell_type.MISSILE_LAUNCHER
	
	var turret_cell_cost: int = PlayerBaseCells.crystal_costs[turret_type];
	var turret_AP_cost:int = PlayerBaseCells.action_costs[turret_type]
	
	
	if (crystals.has_amount(turret_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [turret_cell_cost, crystals.get_amount()]);
		return false;
	if (action_points.has_amount(turret_AP_cost) == false) :
		print("not enough action points (need %d, have %d)" % [turret_AP_cost, action_points.get_amount()]);
		return false;
	
	var set_result: bool = _construction_grid.player_base.try_set_turret_cell_at(_coords,_turret_type);
	if (set_result == false) :
		return false;
	
	crystals.remove(turret_cell_cost);
	action_points.remove(turret_AP_cost);
	print("spent %d crystals (%d remaining)" % [turret_cell_cost, crystals.get_amount()]);
	print("spent %d action points (%d remaining)" % [turret_AP_cost, action_points.get_amount()]);
	return true;

func check_if_base_is_neighbour(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	var possible_neighbours_coords: Array[Vector2i] = [
		coords + Vector2i( 1, 0),
		coords + Vector2i( 0, 1),
		coords + Vector2i(-1, 0),
		coords + Vector2i( 0,-1),
	];
	var quota_box_coords: Vector2i = construction_grid.player_base.get_quota_box_coords();
	for neighbour_coords in possible_neighbours_coords :
		if (construction_grid.player_base.has_base_cell(neighbour_coords) ||
			neighbour_coords == quota_box_coords ) :
			return true;
		# else : 
			# check next coordinates
			# pass;
		pass;
	# was false for all neighbours
	
	return false;

func try_build_base_cell(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	if (construction_grid.is_terrain_ok_to_build(coords) == false) :
		print("trying to build base cell in a cell where the terrain is blocking construction");
		return false;
	
	if (construction_grid.can_build_base(coords) == false) :
		print("trying to build base cell in a cell where we can't build base cells");
		return false;
	
	if (check_if_base_is_neighbour(construction_grid, coords) == false) :
		print("trying to build base cell in a cell without adjacent base");
		return false;
	
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var base_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.BASE_CELL];
	var base_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.BASE_CELL];
	if (crystals.has_amount(base_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [base_cell_cost, crystals.get_amount()]);
		return false;
	
	if (action_points.has_amount(base_action_points_cost) == false) :
		print("not action points (need %d, have %d)" % [base_action_points_cost, action_points.get_amount()]);
		return false;
	
	var set_result: bool = construction_grid.player_base.try_set_base_cell_at(coords);
	if (set_result == false) :
		return false;
	
	crystals.remove(base_cell_cost);
	action_points.remove(base_action_points_cost)
	print("spent %d crystals (%d remaining)" % [base_cell_cost, crystals.get_amount()]);
	print("spent %d action points (%d remaining)" % [base_action_points_cost, action_points.get_amount()]);
	
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
		
	var has_neighbor_base : bool = [
		(coords + Vector2i(  1,  0)),
		(coords + Vector2i(  0, -1)),
		(coords + Vector2i( -1,  0)),
		(coords + Vector2i(  0,  1)),
	].any(construction_grid.player_base.has_base_cell);
	if not has_neighbor_base:
		print("No adjacent base cell");
		return false;
		
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var mining_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.AUTO_MINER];
	var mining_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.AUTO_MINER];
	if (crystals.has_amount(mining_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [mining_cell_cost, crystals.get_amount()]);
		return false;
	
	if (action_points.has_amount(mining_action_points_cost) == false) :
		print("not action points (need %d, have %d)" % [mining_action_points_cost, action_points.get_amount()]);
		return false;
	
	var set_result: bool = construction_grid.player_base.try_set_mining_cell_at(coords);
	if (set_result == false) :
		return false;
	
	crystals.remove(mining_cell_cost);
	action_points.remove(mining_action_points_cost);
	print("spent %d crystals (%d remaining)" % [mining_cell_cost, crystals.get_amount()]);
	print("spent %d action points (%d remaining)" % [mining_action_points_cost, action_points.get_amount()]);
	
	return true;

func try_build_door(construction_grid: ConstructionGrid, coords: Vector2i) -> bool :
	#Verification que la cellule a un module
	var cell_to_construct:PlayerBaseCell = construction_grid.player_base.base_cells.get(coords)
	if cell_to_construct == null:
		print("No base cell here")
		return false
	if !cell_to_construct.hasModuleAvaibleSlot():
		print("No module slot avaible ine this base cell")
		print(cell_to_construct.moduleslots_array)
		return false
	
	var crystals: PlayerResource = player.crystals;
	var action_points:PlayerResource = player.action_points;
	var door_cell_cost: int = PlayerBaseCells.crystal_costs[PlayerBaseCells.cell_type.DOOR];
	var door_action_points_cost: int = PlayerBaseCells.action_costs[PlayerBaseCells.cell_type.DOOR];
	if (crystals.has_amount(door_cell_cost) == false) :
		print("not enough crystals (need %d, have %d)" % [door_cell_cost, crystals.get_amount()]);
		return false;
	
	if (action_points.has_amount(door_action_points_cost) == false) :
		print("not action points (need %d, have %d)" % [door_action_points_cost, action_points.get_amount()]);
		return false;
	
	
	#On prends la premiere car pas le temps
	#TODO voir quelle moduleslot le player q cliquer plutot que seulement la cellule de grid
	#pour avoir plusieur module slote dans une cell
	var module_slot:PlayerBaseModuleSlot = cell_to_construct.moduleslots_array[0]
	var set_result: bool = try_build_module_in_slot(PlayerBaseModules.Enum.Door,module_slot);
	if (set_result == false) :
		return false;
	
	crystals.remove(door_cell_cost);
	action_points.remove(door_action_points_cost);
	print("spent %d crystals (%d remaining)" % [door_cell_cost, crystals.get_amount()]);
	print("spent %d action points (%d remaining)" % [door_action_points_cost, action_points.get_amount()]);
	
	return true;


func _on_cell_constructed(
	_construction_grid: ConstructionGrid,
	_coords: Vector2i,
	_construction_type: ModuleId.Of
) -> void :
	construction_sound.play();
	return;
