class_name QuotaBox
extends Node3D

var terrain: Terrain = null;
var interactible : Interactible;

func find_terrain_rec(node: Node3D) -> void :
	var parent: Node3D = node.get_parent();
	if (parent == null) :
		print("QuotaBox::find_terrain_rec() : couldn't find terrain node");
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
	set_tile_as_quota_box();
	
	interactible = Interactible.new(Callable(self, "interact"), Interactible.Action.QUOTA, Callable(self, "uninteract"));
	
	return;

func set_tile_as_quota_box() -> void :
	var coords_2d: Vector2 = Vector2(global_position.x, global_position.z) / 2.0;
	var grid_coords: Vector2i = terrain.construction_grid.get_grid_coords_from_world_coords(global_position);
	if (Vector2(grid_coords) != coords_2d) :
		print("QuotaBox: ", name, " is not placed inside a cell!");
		return;
	terrain.construction_grid.set_tile_as_obstructed(grid_coords);
	terrain.construction_grid.player_base.set_quota_box(grid_coords, self);
	return;
	
func interact() -> void :
	DayNightSystem.spend_on_quota();
	return;
	
func uninteract() -> void:
	DayNightSystem.take_from_quota();
	return;
	
func request_from_quota() -> void:
	DayNightSystem.take_from_quota();
	return;
