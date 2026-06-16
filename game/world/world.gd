extends Node3D

@onready var light : Light3D = $DirectionalLight3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayNightSystem.on_day_start.connect(set_daylight);
	DayNightSystem.on_night_start.connect(set_nightlight);
	
func set_daylight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.WHITE, 1.0);
	
func set_nightlight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.DARK_CYAN, 1.0);
