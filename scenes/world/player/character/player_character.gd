class_name PlayerCharacter
extends Node3D

# Handles the character in the world that is controlled by the player

# I did a quick thing, just for debugging and easily test things.
# the movement isn't ideal, the camera + raycast isn't ideal,
# the camera should be a separate scene in our TopDown game (so it can smoothly follow the player)

@export_group("Local References")
@export var cam_pivot: Node3D = null;
@export var raycast: RayCast3D = null;

@export_group("Extern References")
@export var player: Player = null;

@export_group("Movement Parameters")
@export var mov_speed: float = 10;
@export var cam_rotation_speed : float = 0.002;

@export_group("")

func _enter_tree() -> void :
	assert(cam_pivot != null);
	assert(raycast != null);
	assert(player != null);
	return;

var velocity: Vector3 = Vector3.ZERO;
var cam_curr_rotation: Vector3 = Vector3.ZERO;

var is_mouse_captured: bool = true;

var last_point_targeted: Vector2i = Vector2i.ZERO;

func set_mouse_captured(capture: bool) -> void :
	if (capture == true) :
		is_mouse_captured = true;
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	else :
		is_mouse_captured = false;
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	return;

func toggle_mouse_captured() -> void :
	set_mouse_captured(!is_mouse_captured);
	return; 

func _ready() -> void :
	toggle_mouse_captured();
	return;

func _unhandled_input(event: InputEvent) -> void :
	if Input.is_action_just_pressed("toggle_cursor") :
		toggle_mouse_captured();
		return;
	if (is_mouse_captured == false) && (Input.is_action_just_pressed("left_click")) :
		set_mouse_captured(true);
		return;
	
	set_velocity_from_inputs();
	
	var motion = event as InputEventMouseMotion;
	if (motion != null) :
		rotate_camera_from_motion(motion.relative);
		pass;
	
	if (Input.is_action_just_pressed("left_click")) :
		try_construct();
		pass;
	return;

func set_velocity_from_inputs() -> void :
	
	velocity.z = Input.get_axis("move_forwards", "move_backwards");
	velocity.x = Input.get_axis("move_left", "move_right");
	velocity.y = Input.get_axis("move_down", "move_up");
	
	if (velocity.length_squared() > 0.5) :
		velocity = velocity.normalized();
	else :
		velocity = Vector3.ZERO;
	return;

func rotate_camera_from_motion(motion: Vector2) -> void :
	if (cam_pivot == null) :
		return;
	if (is_mouse_captured == false) : 
		return;
	
	cam_curr_rotation.x -= motion.x * cam_rotation_speed;
	cam_curr_rotation.y -= motion.y * cam_rotation_speed;
	cam_pivot.transform.basis = Basis();
	
	cam_pivot.rotate_object_local(Vector3.UP, cam_curr_rotation.x);
	cam_pivot.rotate_object_local(Vector3.RIGHT, cam_curr_rotation.y);
	return;

func _physics_process(delta: float) -> void :
	update_pos_from_velocity(delta);
	update_raycast();
	return;

func update_pos_from_velocity(delta: float) -> void :
	var forward: Vector3 = cam_pivot.basis.x;
	forward.y = 0.0;
	
	var right: Vector3 = cam_pivot.basis.z;
	right.y = 0.0;
	
	var delta_pos: Vector3 = ((forward * velocity.x) + (right * velocity.z));
	delta_pos += Vector3.UP * velocity.y;
	
	
	position += (delta_pos * delta * mov_speed);
	return;

func does_raycast_hits_grid() -> ConstructionGrid :
	if (raycast == null) :
		return null;
	if (raycast.is_colliding() == false) :
		return null;
	
	var area_3D_collided = raycast.get_collider() as Area3D;
	if (area_3D_collided == null) :
		return null;
	
	var grid = area_3D_collided.get_parent() as ConstructionGrid;
	if (grid == null) :
		return null;
	
	return grid;

func update_raycast() -> void :
	var grid : ConstructionGrid = does_raycast_hits_grid();
	if (grid == null) :
		return;
	
	var collision_point_3D : Vector3 = raycast.get_collision_point();
	
	last_point_targeted = player.construction_grid.get_grid_coords_from_world_coords(collision_point_3D);
	
	# print("collided with grid, at ", last_point_targeted);
	
	return;
	
static var idk : int = 0;
func try_construct() -> void :
	var grid : ConstructionGrid = does_raycast_hits_grid();
	if (grid == null) :
		print("raycast does not hit the grid");
		return;
	
	player.construction.try_build_base_cell(last_point_targeted);
	return;
	
	
	
	
	
	
	
	
