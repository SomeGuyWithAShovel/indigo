class_name SeeThroughSystem
extends Node

# This node centralizes everything needed to allow to see through some meshes.
# It must not be inside normal_viewport nor see_through_viewport.

@export var normal_viewport: SubViewport = null; # MUST CONTAIN THE CAMERA
@export var see_through_viewport: SubViewport = null;
@export var ui_viewport : SubViewport = null;
var main_viewport: Viewport = null;
var main_window: Window = null;

@export var normal_camera: Camera3D = null;
@export var see_through_camera: Camera3D = null;

@export var canvas_item: Control = null;
var shader_material: ShaderMaterial = null;
@export var shader_param_target: StringName = "Target_Pos_PX";
@export var shader_param_size: StringName = "Texture_Size";
@export var shader_param_radius: StringName = "Radius";

static var instance: SeeThroughSystem = null; # so the player script can set the normal_camera of this script
func _enter_tree() -> void :
	instance = self;
	main_viewport = get_viewport();
	assert(main_viewport != null);
	assert(normal_viewport != null);
	assert(see_through_viewport != null);
	
	main_window = get_window();
	assert(main_window != null);
	main_window.size_changed.connect(update_viewport_size);
	
	# assert(normal_camera != null); # instead of finding it from here, it is set in the player script.
	assert(see_through_camera != null);
	
	assert(canvas_item != null);
	shader_material = canvas_item.material as ShaderMaterial;
	assert(shader_material != null);
	return;

func _ready() -> void :
	assert(normal_camera != null);
	
	update_viewport_size();
	update_see_through_normalized_radius(0.3); # anything in [0,1]
	return;

# There is many "screen size" variables/parameters spread everywhere.
# This function sets them all with the main_viewport size.

func update_viewport_size() -> void :
	var new_size: Vector2 = main_viewport.get_visible_rect().size;
	print("main_viewport size changed to ", new_size);
	normal_viewport.size = new_size;
	see_through_viewport.size = new_size;
	ui_viewport.size = new_size;
	
	canvas_item.custom_minimum_size = new_size;
	shader_material.set_shader_parameter(shader_param_size, new_size);
	
	shader_material.set_shader_parameter(shader_param_target, (new_size / 2.0));
	return;


# SubViewports don't receive inputs by default.
# (Even if the ControlNode MouseFilter/Focus is set correctly)
# (I checked with the ControlNode but without everything in the subviewport, and it worked)

func _input(_event: InputEvent) -> void :
	ui_viewport.push_input(_event);
	normal_viewport.push_input(_event);
	return;
func _unhandled_input(_event: InputEvent) -> void :
	# normal_viewport.push_unhandled_input(_event);
	# it seems that both _input and _unhandled_input are triggered for a single input
	return;


# If we have this :
# Node3D_A
#  L SubViewport
#     L Camera
# and moves Node3D_A,
# Camera isn't moved, even if it is a child of Node3D_A.
#
# This script is the solution I found to fix this issue.

func _process(_delta: float) -> void :
	see_through_camera.global_transform = normal_camera.global_transform;
	return;


func update_see_through_normalized_radius(new_radius: float) -> void :
	new_radius *= (main_viewport.get_visible_rect().size.y / 2.0);
	shader_material.set_shader_parameter(shader_param_radius, new_radius);
	return;
