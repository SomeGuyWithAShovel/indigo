class_name PlayerBaseCells

# need to be a separate class that isn't in the scenes as a script, to be able to preload these scenes
# should probably be a Resource stored somewhere, instead of billions of static preload and static arrays of data

static var base_scene_array: Array[PackedScene] = [
	preload("res://game/construction/cells/basic_cell_list/standalone.tscn"),
	preload("res://game/construction/cells/basic_cell_list/dead_end.tscn"),
	preload("res://game/construction/cells/basic_cell_list/turn.tscn"),
	preload("res://game/construction/cells/basic_cell_list/straight.tscn"),
	preload("res://game/construction/cells/basic_cell_list/t_junction.tscn"),
	preload("res://game/construction/cells/basic_cell_list/4_way.tscn")
];

static var mining_scene: PackedScene = preload("res://game/construction/cells/mining_cell.tscn");

static var turret_scene_array: Array[PackedScene] = [
	preload("res://game/construction/cells/turret/classic_turret.tscn"),
	preload("res://game/construction/cells/turret/heavy_turret.tscn")
];

static var crystal_costs: Array[int] = [
	
];
