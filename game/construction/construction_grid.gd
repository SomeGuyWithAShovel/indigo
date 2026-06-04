class_name ConstructionGrid
extends Node3D

# handles the grid on which things can be built

@export var cell_size: float = 2.0;
@export var player_base: PlayerBase = null;

func _enter_tree() -> void :
	assert(player_base != null);
	return;

func get_grid_coords_from_world_coords(world_coords: Vector3) -> Vector2i :
	return Vector2i(
		roundi(world_coords.x / cell_size),
		roundi(world_coords.z / cell_size)
	);

func get_world_coords_from_grid_coords(grid_coords: Vector2i) -> Vector3 :
	return Vector3(
		grid_coords.x * cell_size,
		0.0,
		grid_coords.y * cell_size
	);

func _process(_delta: float) -> void :
	# so it follows the player (and with its shader, we don't need to snap it to grid coords) 
	global_position.x = Player.instance.global_position.x;
	global_position.z = Player.instance.global_position.z;
	return;

func is_terrain_ok_to_build(_grid_coords: Vector2i) -> bool :
	return true;

func can_build_miner(_grid_coords: Vector2i) -> bool :
	return crystal_tiles.has(_grid_coords as Vector2);

var crystal_tiles:PackedVector2Array = PackedVector2Array();

func set_tile_as_crystal_tile(grid_coords: Vector2i) :
	if crystal_tiles.has(grid_coords) : 
		print("ConstructionGrid::add_crystal_tile(%d;%d) : already set as crystal tile" % 
			[grid_coords.x, grid_coords.y]
		);
		return;
	crystal_tiles.push_back(grid_coords as Vector2);
	return;

func remove_tile_from_crystal_tiles(grid_coords: Vector2i) :
	var find_id:= crystal_tiles.find(grid_coords as Vector2); # TODO : sort and bsearch ?
	if (find_id >= 0) :
		crystal_tiles.remove_at(find_id);
		pass;
	return;
