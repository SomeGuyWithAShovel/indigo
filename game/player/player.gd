class_name Player
extends Node3D

# handles the "abstract" Player
# not the in-world character, but everything player related (including the in-world character)

@export_group("Internal References")
@export var construction: PlayerConstruction = null;
@export var camera: Camera3D = null;
@export var character: PlayerCharacter = null;

@export_group("Player Resources")
@export var crystals : PlayerResource = null;
@export var action_points : PlayerResource = null;

@export_group("Mouse Raycasts")
@export var mouse_raycast_length: float = 100.0;
@export var nodes_to_exclude: Array[CollisionObject3D] = [];
var last_mouse_pos_clicked: Vector2 = Vector2.ZERO;
var mouse_clicked: bool = false;
var selected_construction_type: ModuleId.Of = ModuleId.Of.NONE;

# J'en ai besoin pour le day-night -Matéu
static var instance : Player = null;
func _enter_tree() -> void :
	instance = self;
	
	assert(camera != null); SeeThroughSystem.instance.normal_camera = camera;
	assert(construction != null);
	assert(character != null);
	
	assert(crystals != null);
	assert(action_points != null);
	return;

func _unhandled_input(_event: InputEvent) -> void :
	var btn_event = _event as InputEventMouseButton;
	if ((btn_event != null) && (btn_event.button_index == 1) && (btn_event.pressed)) :
		last_mouse_pos_clicked = btn_event.position;
		mouse_clicked = true; # we need to do the raycast in _physics_process(), but we need to know when in _input()
		print("PLAYER UNHANDLED INPUT"); # why does it triggers, even if we hit a UI element ???????????????????????
		pass;
	return;

func _process(_delta: float) -> void:
	if (mouse_clicked == true):
		mouse_clicked = false;
		if UIManager.instance.is_build_menu_open: 
			try_build.call_deferred();
	return;

func try_build() -> void:
	var is_open = UIManager.instance.is_build_menu_open;
	if is_open:
		var raycast_result := do_mouse_raycast_at(last_mouse_pos_clicked);
		if (raycast_result) :
			raycast_on_construction_grid(raycast_result);
			return;
		return;
	return;

func set_selected_construction_type(construction_type: ModuleId.Of) -> void :
	selected_construction_type = construction_type;
	print("selected construction_type ", selected_construction_type);
	return;

func do_mouse_raycast_at(mouse_pos: Vector2) -> Dictionary :
	# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	
	var space_state = get_world_3d().direct_space_state
	
	var raycast_from = camera.project_ray_origin(mouse_pos)
	var raycast_to = raycast_from + camera.project_ray_normal(mouse_pos) * mouse_raycast_length;
	
	var raycast_query = PhysicsRayQueryParameters3D.create(raycast_from, raycast_to)
	raycast_query.collide_with_areas = true;
	
	raycast_query.collision_mask = (1 << 5); # 6th collision layer (should be Grid)
	
	# can't do : raycast_query.exclude.push_back() : raycast_query.exclude returns a COPY, so we would push_back to a rvalue
	var excluded_objects : Array[RID] = raycast_query.exclude;
	for collision_object in nodes_to_exclude :
		excluded_objects.push_back(collision_object);
		pass;
	raycast_query.exclude = excluded_objects;
	
	return space_state.intersect_ray(raycast_query);

func raycast_on_construction_grid(raycast_result: Dictionary) -> void :
	if (raycast_result == null) :
		return;
	var collided : Node3D = raycast_result["collider"] as Node3D;
	if (collided == null) :
		return;
	var collided_parent = collided.get_parent();
	if (collided_parent == null) :
		return;
	var collided_grid: ConstructionGrid = collided_parent as ConstructionGrid;
	if (collided_grid == null) :
		return;
	
	var raycast_position: Vector3 = raycast_result["position"];
	var cell_coord: Vector2 = collided_grid.get_grid_coords_from_world_coords(raycast_position);
	
	if ((selected_construction_type != ModuleId.Of.NONE) && 
		(collided_grid.is_terrain_ok_to_build(cell_coord)) ) :
		
		construction.try_construct_cell(collided_grid, cell_coord, selected_construction_type);
		pass;
	return;
