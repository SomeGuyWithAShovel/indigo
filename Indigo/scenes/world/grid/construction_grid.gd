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
