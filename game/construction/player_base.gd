class_name PlayerBase
extends Node3D

# handles everything that the player can build (its base)

@export var construction_grid: ConstructionGrid = null;

func _enter_tree() -> void :
	assert(construction_grid != null);
	return;

var cells: Dictionary[Vector2i, PlayerBaseCell];

func has_cell(coords: Vector2i) -> bool :
	return cells.has(coords);

var cells_dir: Dictionary[Vector2i, Dir.Enum];

func raw_set_cell_at(coords: Vector2i, dir: Dir.Enum, _extra: int) -> void :
	if (has_cell(coords)) :
		print("destroying ", coords);
		cells[coords].name = "CellBeingRemoved";
		cells[coords].queue_free();
		cells[coords] = null;
		pass;
	
	var new_node = Dir.create_cell_node_from_packed_scene_array(PlayerBaseCells.scene_array, self, dir);
	var new_cell = new_node as PlayerBaseCell;
	assert(new_cell != null);
	
	new_cell.name = "Cell(%d,%d)" % [coords.x, coords.y];
	new_cell.position = construction_grid.get_world_coords_from_grid_coords(coords);
	
	cells[coords] = new_cell;
	cells_dir[coords] = dir;
	return;

func raw_set_cell_at_with_neighbours(coords: Vector2i, _extra: int) -> void :
	
	var neighbour_coords : Array[Vector2i] = [
		(coords + Vector2i(  1,  0)),
		(coords + Vector2i(  0, -1)),
		(coords + Vector2i( -1,  0)),
		(coords + Vector2i(  0,  1)),
	];
	
	var new_cell_dir : Dir.Enum = Dir.Enum.None;
	
	for i: int in range(4) :
		
		if (has_cell(neighbour_coords[i])) :
			
			var neighbour_curr_dir: Dir.Enum = cells_dir[neighbour_coords[i]];
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
					raw_set_cell_at(neighbour_coords[i], neighbour_new_dir, 0);
				pass;
			pass;
		pass;
	
	raw_set_cell_at(coords, new_cell_dir, _extra);
	
	return;

func try_set_cell_at(coords: Vector2i) -> bool :
	if (has_cell(coords)) :
		print("set_cell_at(", coords, ") : already a cell here");
		return false;
	print("set_cell_at(", coords, ")");
	raw_set_cell_at_with_neighbours(coords, 0);
	return true;
