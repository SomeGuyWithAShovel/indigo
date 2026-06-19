class_name ConstructionGrid
extends Node3D

# handles the grid on which things can be built

@export var cell_size: float = 2.0;
@export var player_base: PlayerBase = null;
@export var terrain: Terrain = null;

func _enter_tree() -> void :
	assert(player_base != null);
	assert(terrain != null);
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
	if Globals.player:
		# so it follows the player (and with its shader, we don't need to snap it to grid coords) 
		global_position.x = Globals.player.global_position.x;
		global_position.z = Globals.player.global_position.z;
	return;

func is_terrain_ok_to_build(_grid_coords: Vector2i) -> bool :
	return true;

# still need to check is_terrain_ok_to_build() manually !
func can_build_base(_grid_coords: Vector2i) -> bool :
	return crystal_tiles.has(_grid_coords as Vector2) == false and not obstructed_tile.has(_grid_coords);

func can_build_turret(_grid_coords: Vector2i) -> bool :
	return crystal_tiles.has(_grid_coords as Vector2) == false and not obstructed_tile.has(_grid_coords);

# still need to check is_terrain_ok_to_build() manually !
func can_build_miner(_grid_coords: Vector2i) -> bool :
	return crystal_tiles.has(_grid_coords as Vector2) and not obstructed_tile.has(_grid_coords);



var crystal_tiles: Dictionary[Vector2i, CrystalTile];
var obstructed_tile : Array[Vector2i];

func set_tile_as_crystal_tile(grid_coords: Vector2i, crystal_tile: CrystalTile) :
	assert(crystal_tile != null);
	if crystal_tiles.has(grid_coords) : 
		print("ConstructionGrid::add_crystal_tile(%d;%d) : already set as crystal tile" % 
			[grid_coords.x, grid_coords.y]
		);
		return;
	crystal_tiles[grid_coords] = crystal_tile;
	return;

func set_tile_as_obstructed(grid_coords : Vector2i) -> void:
	if obstructed_tile.has(grid_coords):
		print("ConstructionGrid::set_tile_as_obstructed(%d;%d) : already set as obstructed tile" % 
			[grid_coords.x, grid_coords.y]
		);
		return;
	obstructed_tile.append(grid_coords);
	return;

# not tested
func remove_tile_from_crystal_tiles(grid_coords: Vector2i) :
	if (crystal_tiles.has(grid_coords)) :
		crystal_tiles.erase(grid_coords);
		pass;
	return;

func getDir_from_cell(coord:Vector2i)->Dir.Enum:
	var value = player_base.base_cells_dir.get(coord)
	if value == null:
		return Dir.Enum.None
	return value
	
