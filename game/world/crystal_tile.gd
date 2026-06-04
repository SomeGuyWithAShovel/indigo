class_name CrystalTile
extends Node3D

var terrain: Terrain = null;

func find_terrain_rec(node: Node3D) -> void :
	var parent: Node3D = node.get_parent();
	if (parent == null) :
		print("CrystalTile::find_terrain_rec() : couldn't find terrain node");
		assert(false);
		return;
	var found_terrain: Terrain = parent as Terrain;
	if (found_terrain != null) :
		terrain = found_terrain;
		return;
	find_terrain_rec(parent);
	return;

func _enter_tree() -> void :
	find_terrain_rec(self);
	assert(terrain != null);
	set_tile_as_crystals();
	return;

func set_tile_as_crystals() -> void :
	var coords_2d: Vector2 = Vector2(global_position.x, global_position.z) / 2.0;
	var grid_coords: Vector2i = terrain.construction_grid.get_grid_coords_from_world_coords(global_position);
	if (Vector2(grid_coords) != coords_2d) :
		print("CrystalTile: ", name, " is not placed inside a cell!");
		return;
	terrain.construction_grid.set_tile_as_crystal_tile(grid_coords);
	return;
