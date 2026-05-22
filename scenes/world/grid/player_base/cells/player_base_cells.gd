class_name PlayerBaseCells

# need to be a separate class that isn't in the scenes as a script, to be able to preload these scenes
# should probably be a Resource stored somewhere, instead of billions of static preload and static arrays of data

static var scene_array: Array[PackedScene] = [
	preload("res://scenes/world/grid/player_base/cells/basic_cells/standalone.tscn"),
	preload("res://scenes/world/grid/player_base/cells/basic_cells/dead_end.tscn"),
	preload("res://scenes/world/grid/player_base/cells/basic_cells/turn.tscn"),
	preload("res://scenes/world/grid/player_base/cells/basic_cells/straight.tscn"),
	preload("res://scenes/world/grid/player_base/cells/basic_cells/t_junction.tscn"),
	preload("res://scenes/world/grid/player_base/cells/basic_cells/4_way.tscn")
];

static var crystal_costs: Array[int] = [
	
];
