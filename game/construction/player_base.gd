class_name PlayerBase
extends Node3D

# handles everything that the player can build (its base)

@export var construction_grid: ConstructionGrid = null;
@export var player: Player = null;

@export var mining_operations_per_day : int = 5;

@onready var night_timer : Timer = $Timer;

func _enter_tree() -> void :
	assert(construction_grid != null);
	assert(player != null);
	return;
	
func _ready() -> void:
	DayNightSystem.on_day_start.connect(day_mining);
	DayNightSystem.on_night_start.connect(night_mining);

func day_mining() -> void:
	night_timer.stop();
	
func night_mining() -> void:
	night_timer.start();
	for _i in range(mining_operations_per_day):
		do_all_mining_operations();

var quota_box_cell: Dictionary[Vector2i, QuotaBox]; # only a single tuple, probably

func get_quota_box_coords() -> Vector2i :
	return quota_box_cell.keys()[0];

func set_quota_box(coords: Vector2i, quota_box: QuotaBox) -> void :
	assert(quota_box != null);
	quota_box_cell[coords] = quota_box;
	print("PlayerBase: QuotaBox \"%s\" placed at (%d,%d)" % [quota_box.name, coords.x, coords.y]);
	return;

var base_cells: Dictionary[Vector2i, PlayerBaseCell];
var turret_cells: Dictionary[Vector2i, Turret];
var mining_cells: Dictionary[Vector2i, MiningCell];

func has_base_cell(coords: Vector2i) -> bool :
	return base_cells.has(coords);

func has_mining_cell(coords: Vector2i) -> bool :
	return mining_cells.has(coords);

func has_turret_cell(coords: Vector2i) -> bool :
	return turret_cells.has(coords);

func has_any_cell(coords: Vector2i) -> bool :
	return (has_base_cell(coords) || has_mining_cell(coords) || has_turret_cell(coords));

var base_cells_dir: Dictionary[Vector2i, Dir.Enum];

func raw_set_base_cell_at(coords: Vector2i, dir: Dir.Enum, _extra: int) -> void :
	if (has_base_cell(coords)) :
		print("destroying ", coords);
		base_cells[coords].name = "CellBeingRemoved";
		base_cells[coords].queue_free();
		base_cells[coords] = null;
		pass;
	
	var new_node = Dir.create_cell_node_from_packed_scene_array(PlayerBaseCells.base_scene_array, self, dir);
	var new_cell = new_node as PlayerBaseCell;
	assert(new_cell != null);
	
	new_cell.name = "Cell(%d,%d)" % [coords.x, coords.y];
	new_cell.position = construction_grid.get_world_coords_from_grid_coords(coords);
	
	base_cells[coords] = new_cell;
	base_cells_dir[coords] = dir;
	new_cell.health.died.connect(on_base_broke);
	return;

func raw_set_base_cell_at_with_neighbours(coords: Vector2i, _extra: int) -> void :
	
	var neighbour_coords : Array[Vector2i] = [
		(coords + Vector2i(  1,  0)),
		(coords + Vector2i(  0, -1)),
		(coords + Vector2i( -1,  0)),
		(coords + Vector2i(  0,  1)),
	];
	
	var new_cell_dir : Dir.Enum = Dir.Enum.None;
	
	for i: int in range(4) :
		
		if (has_base_cell(neighbour_coords[i])) :
			
			var neighbour_curr_dir: Dir.Enum = base_cells_dir[neighbour_coords[i]];
			var neighbour_new_dir: Dir.Enum = Dir.add_dirs(neighbour_curr_dir, Dir.opposite_from_int[i]);
			
			if (neighbour_new_dir != neighbour_curr_dir) :
				# this is here that we would check for things like : is the neighbour allowed to change shape ?
				# even if the current cell is free, maybe there is something in the neighbour cell that wasn't colliding
				# with the neighbour, but that would collide with the neighbour if it changed shape
				# or other things like that
				if (true) :
					
					# the new cell we create should be connected to that neighbour
					new_cell_dir = Dir.add_dirs(new_cell_dir, Dir.from_int[i]);
					
					# also, we should update the neighbour so it connects to this new cell
					raw_set_base_cell_at(neighbour_coords[i], neighbour_new_dir, 0);
				pass;
			pass;
		pass;
	
	raw_set_base_cell_at(coords, new_cell_dir, _extra);
	
	return;
	
func on_base_broke(health : HealthComponent) -> void:
	var base : PlayerBaseCell = health.get_parent();
	
	var base_pos := base.global_position;
	var coords = construction_grid.get_grid_coords_from_world_coords(base_pos);
	var neighbour_coords : Array[Vector2i] = [
		(coords + Vector2i(  1,  0)),
		(coords + Vector2i(  0, -1)),
		(coords + Vector2i( -1,  0)),
		(coords + Vector2i(  0,  1)),
	];
	if coords in base_cells_dir:
		base_cells_dir.erase(coords);
		for i in range(len(neighbour_coords)):
			var coord = neighbour_coords[i];
			if has_base_cell(coord):
				var neighbour_new_dir = Dir.remove_dirs(base_cells_dir[coord], Dir.opposite_from_int[i]);
				raw_set_base_cell_at(neighbour_coords[i], neighbour_new_dir, 0);
	self.remove_child(base);
	base_cells.erase(coords);
	mining_cells.erase(coords);
	turret_cells.erase(coords);
	base.queue_free();
	

func raw_set_mining_cell_at(coords: Vector2i) -> void :
	var new_node = PlayerBaseCells.mining_scene.instantiate();
	var new_cell = new_node as MiningCell;
	assert(new_cell != null);
	
	new_cell.name = "MiningCell(%d,%d)" % [coords.x, coords.y];
	new_cell.position = construction_grid.get_world_coords_from_grid_coords(coords);
	new_cell.crystal_tile = construction_grid.crystal_tiles[coords];
	# all this before doing add_child(), so new_cell._enter_tree() fires after initializations
	
	self.add_child(new_cell);
	new_cell.owner = self;
	new_cell.health.died.connect(on_base_broke);
	
	mining_cells[coords] = new_cell;
	return;

func raw_set_turret_cell_at(coords: Vector2i, turret_type:ModuleId.Of) -> void :
	if (turret_type == ModuleId.Of.MISSILE_LAUNCHER):
		var new_node = PlayerBaseCells.turret_scene_array[1].instantiate();
		var new_cell = new_node as Heavy_Turret;
		assert(new_cell != null);
		
		new_cell.name = "TurretCell(%d,%d)" % [coords.x, coords.y];
		new_cell.position = construction_grid.get_world_coords_from_grid_coords(coords);
		
		# all this before doing add_child(), so new_cell._enter_tree() fires after initializations
		
		self.add_child(new_cell);
		new_cell.owner = self;
		turret_cells[coords] = new_cell;
		new_cell.health.died.connect(on_base_broke);
		
	if (turret_type == ModuleId.Of.TURRET):
		var new_node = PlayerBaseCells.turret_scene_array[0].instantiate();
		var new_cell = new_node as Classic_Turret;
		assert(new_cell != null);
		
		new_cell.name = "TurretCell(%d,%d)" % [coords.x, coords.y];
		new_cell.position = construction_grid.get_world_coords_from_grid_coords(coords);
		
		# all this before doing add_child(), so new_cell._enter_tree() fires after initializations
		
		self.add_child(new_cell);
		new_cell.owner = self;
		new_cell.health.died.connect(on_base_broke);
		turret_cells[coords] = new_cell;
	return;

func try_set_base_cell_at(coords: Vector2i) -> bool :
	if (has_any_cell(coords)) :
		print("try_set_base_cell_at(", coords, ") : already a cell here");
		return false;
	print("try_set_base_cell_at(", coords, ")");
	raw_set_base_cell_at_with_neighbours(coords, 0);
	return true;

func try_set_mining_cell_at(coords: Vector2i) -> bool :
	if (has_any_cell(coords)) :
		print("try_set_mining_cell_at(", coords, ") : already a cell here");
		return false;
	print("try_set_mining_cell_at(", coords, ")");
	raw_set_mining_cell_at(coords);
	return true;

func try_set_turret_cell_at(coords: Vector2i, turret_type:ModuleId.Of) -> bool :
	if (has_any_cell(coords)) :
		print("try_set_turret_cell_at(", coords, ") : already a cell here");
		return false;
	print("try_set_turret_cell_at(", coords, ")");
	raw_set_turret_cell_at(coords,turret_type);
	return true;

func do_all_mining_operations() -> void :
	var new_crystals: int = 0;
	for mining_cell_coord in mining_cells :
		new_crystals += mining_cells[mining_cell_coord].mining_operation();
		pass;
	player.crystals.add(new_crystals);
	return;

func _on_timer_timeout() -> void:
	do_all_mining_operations();
	return;
