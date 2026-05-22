class_name Dir

# a bit hard to explain, I think it's easier to just read the code (the enum, its comments, the methods, ...)

enum Enum {
	None = 0,
	# anti-clock-wise / trigonometric
	E = 0b0001,
	N = 0b0010,
	W = 0b0100,
	S = 0b1000,
	# Could do swizzling like in GLSL (EN = E | N, WSN = W | S | N, ...) (except we can't declare both WSN and NWS for instance) 
}

const from_int          : Array[Dir.Enum] = [Dir.Enum.E, Dir.Enum.N, Dir.Enum.W, Dir.Enum.S];
const opposite_from_int : Array[Dir.Enum] = [Dir.Enum.W, Dir.Enum.S, Dir.Enum.E, Dir.Enum.N];
const int_to_str        : Array[String  ] = ["East"    , "North"   , "West"    , "South"   ];

static func has_dir(e: Dir.Enum, dir: Dir.Enum) -> bool :
	assert((dir == Enum.E) or (dir == Enum.N) or (dir == Enum.W) or (dir == Enum.S));
	return (((e as int) & (dir as int)) != 0);

static func add_dirs(e: Dir.Enum, dir: Dir.Enum) -> Dir.Enum :
	assert((dir == Enum.E) or (dir == Enum.N) or (dir == Enum.W) or (dir == Enum.S));
	return (((e as int) | (dir as int)) as Dir.Enum);

# NEED TO BE IN THIS ORDER !
# [standalone, deadend, turn, straight, tjunc, 4way]
# these arrays are indexed by that : scene_id_from_dir[3] = 2 means that :
# 3 => 0b0011 => Dir.E + Dir.N => scene L (turn) => 2 (because turn is index 2 in the commented array just before this line)
const scene_id_from_dir : Array[int] = [0, 1, 1, 2, 1, 3, 2, 4, 1, 2, 3, 4, 2, 4, 4, 5]; # o c L I T + 
const nb_rota_from_dir  : Array[int] = [0, 0, 1, 0, 2, 0, 1, 0, 3, 3, 1, 3, 2, 2, 1, 0]; # | or - : same scene but different rotation (same with L, ...)

# usable by anything that has a direction and is aligned on the grid,
# as long as scene_array follows the order of scene_id_from_dir and nb_rota_from_dir
static func create_cell_node_from_packed_scene_array(scene_array: Array[PackedScene], parent: Node, dir: Dir.Enum) -> Node3D :
	
	var scene_array_id : int = Dir.scene_id_from_dir[dir as int];
	var nb_rotations   : int = Dir.nb_rota_from_dir [dir as int];
	
	var new_cell: Node3D = scene_array[scene_array_id].instantiate() as Node3D;
	parent.add_child(new_cell);
	new_cell.owner = parent;
	
	if (nb_rotations > 0) :
		new_cell.rotate_y((PI/2) * nb_rotations);
		pass;
	
	return new_cell;
