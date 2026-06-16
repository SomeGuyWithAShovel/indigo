extends Node3D
class_name Unprojector;

@export var unprojected : Control;
@export var camera : Camera3D = null;

@export_group("Parameters")
@export var min_scale : float = 0.2;
@export var max_scale : float = 1.0;
@export var inverse_distance_effect : float = 100.0;

@onready var timer : Timer = $Timer;

func _ready() -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d();
	timer.timeout.connect(unproject);

func unproject() -> void:
	var screen_pos : Vector2 = camera.unproject_position(global_position);
	unprojected.global_position = screen_pos;
	var distance_to_cam = global_position.distance_squared_to(camera.global_position);
	unprojected.scale = Vector2.ONE * clamp(max_scale - distance_to_cam/inverse_distance_effect, min_scale, max_scale);
