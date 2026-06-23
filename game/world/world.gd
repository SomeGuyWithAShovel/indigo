extends Node3D

@export var day_music : AudioStream;
@export var night_music : AudioStream;

@onready var game_music : AudioFader = $GameMusic/AudioFader;
@onready var light : Light3D = $DirectionalLight3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayNightSystem.on_day_start.connect(set_day);
	DayNightSystem.on_night_start.connect(set_night);
	set_day();
	
var music_tween : Tween = null;
	
func set_day() -> void:
	set_daylight();
	game_music.stream = day_music;
	
func set_night() -> void:
	set_nightlight();
	game_music.stream = night_music;
	
func set_daylight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.WHITE, 1.0);
	
func set_nightlight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.DARK_CYAN, 1.0);
