class_name PlayerCharacter
extends Node3D

@export var direction_switch_lag : float = 0.01;
@export var max_speed : float = 10.0;
@export var acceleration : float = 10.0;
@export var desceleration : float = 10.0;
@onready var gravity : Vector3 = ProjectSettings.get_setting(&"physics/3d/default_gravity_vector")

@export_group("Extern References")
@export var player: Player = null;

@onready var camera : Camera3D = $"Camera3D";
@onready var raycast: RayCast3D = $Camera3D/RayCast3D;
@onready var character : CharacterBody3D = $".";
@onready var health : HealthComponent = $HealthComponent;

var is_mouse_captured: bool = true;
var last_point_targeted: Vector2i = Vector2i.ZERO;

var previous_input_direction := Vector3(0, 0, 0);
var current_input_direction := Vector3(0, 0, 0);
var time_since_direction_change := 0.0;
var acceleration_weight := 0.0;

func _ready() -> void:
	health.died.connect(kill);
	$Label.text = str(health.get_health())
	health.health_changed.connect(func (_a, h): $Label.text = str(h));
	toggle_mouse_captured();

func kill(_health : HealthComponent) -> void:
	visible = false;
	character.set_collision_layer_value(2, false);
	await get_tree().create_timer(1.0).timeout;
	position = Vector3(0, 10, 0);
	character.set_collision_layer_value(2, true);
	health.reset();
	visible = true;

func get_input_direction() -> Vector3:
	var horizontal_axis : float = Input.get_axis(&"ui_left", &"ui_right");
	var vertical_axis : float = Input.get_axis(&"ui_up", &"ui_down");
	# Repère "Minecraft" : Y = 0
	var input_direction := Vector3(horizontal_axis, 0, vertical_axis).normalized();
	return input_direction;

func get_move_direction() -> Vector3:
	var weight := time_since_direction_change/direction_switch_lag;
	if previous_input_direction.is_zero_approx():
		weight = 1.0;
	var direction := previous_input_direction.lerp(current_input_direction, weight);
	return direction;
	
func get_move_speed(input_direction : Vector3, delta : float) -> float:
	var speed : float;
	if input_direction.is_zero_approx():
		acceleration_weight += delta*desceleration;
	else:
		acceleration_weight += delta*acceleration;
	acceleration_weight = clamp(acceleration_weight, 0.0, 1.0);
	
	speed = lerpf(0.0, max_speed, acceleration_weight);
	
	return speed;

func _physics_process(delta: float) -> void:
	update_raycast();
	if health.get_health() == 0:
		return;
	
	if Input.is_action_just_pressed(&"ui_cancel"): # DEBUG
		health.hurt(10);
	
	var input_direction := get_input_direction();
	if not input_direction.is_equal_approx(current_input_direction):
		previous_input_direction = current_input_direction;
		current_input_direction = input_direction;
		# Si on tourne "un peu" vers la gauche ou la droite, on veut pas perdre toute notre vitesse
		# Si on tourne à plus d'un angle droit, on repart de 0
		time_since_direction_change = 0.0;
		if not current_input_direction.is_zero_approx():
			acceleration_weight = max(0.0, current_input_direction.dot(previous_input_direction));
		
	time_since_direction_change = clampf(time_since_direction_change + delta, 0.0, direction_switch_lag);
	var direction := get_move_direction();
	var speed := get_move_speed(input_direction, delta);
		
	character.velocity = speed*direction;
	character.velocity += delta*gravity*100.0;
	character.move_and_slide();

func set_mouse_captured(capture: bool) -> void :
	if (capture == true) :
		is_mouse_captured = true;
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	else :
		is_mouse_captured = false;
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		
	if (Input.is_action_just_pressed("left_click")) :
		try_construct();
		pass;
	return;

func toggle_mouse_captured() -> void :
	set_mouse_captured(!is_mouse_captured);
	return; 

func _input(_event: InputEvent) -> void :
	if Input.is_action_just_pressed("toggle_cursor") :
		toggle_mouse_captured();
		return;
	if (is_mouse_captured == false) && (Input.is_action_just_pressed("left_click")) :
		set_mouse_captured(true);
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
