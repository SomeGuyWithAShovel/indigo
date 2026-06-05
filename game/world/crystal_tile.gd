class_name CrystalTile
extends Node3D

var terrain: Terrain = null;
@export var crystal_amount_per_operation: int = 20;

const manual_multiplier: int = 5;

signal on_being_manually_mined();

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
	terrain.construction_grid.set_tile_as_crystal_tile(grid_coords, self);
	return;
	
func interact() -> void :
	# if (is_day == false) :
	#	return;
	
	var player: Player = Player.instance; # should probably be a parameter of interact ?
	
	const act_pts_per_interaction: int = 5;
	
	if (player.action_points.remove_with_check(act_pts_per_interaction)) :
		player.crystals.add(crystal_amount_per_operation * manual_multiplier);
		on_being_manually_mined.emit();
		pass;
	return;


func _on_being_manually_mined() -> void :
	# animations, sounds, ...
	return;
