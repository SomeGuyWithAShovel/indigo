extends Node3D

@export var day_music : AudioStream;
@export var night_music : AudioStream;
@export var max_relative_volume : float;

@onready var game_music : AudioStreamPlayer = $GameMusic;
@onready var light : Light3D = $DirectionalLight3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayNightSystem.on_day_start.connect(set_day);
	DayNightSystem.on_night_start.connect(set_night);
	set_day();
	game_music.volume_db = max_relative_volume;
	game_music.finished.connect(func(): play_music(game_music.stream));
	
var music_tween : Tween = null;
	
func set_day() -> void:
	set_daylight();
	if game_music.stream == night_music or music_tween == null:
		music_tween = create_tween();
		music_tween.tween_property(game_music, "volume_db", -60.0, 3.0);
		music_tween.finished.connect(func (): play_music(day_music));
	
func set_night() -> void:
	set_nightlight();
	if game_music.stream == day_music or music_tween == null:
		music_tween = create_tween();
		music_tween.tween_property(game_music, "volume_db", -60.0, 1.0);
		music_tween.finished.connect(func (): play_music(night_music));
	
func play_music(stream : AudioStream) -> void:
	game_music.stream = stream;
	game_music.play();
	music_tween = create_tween()
	music_tween.tween_property(game_music, "volume_db", max_relative_volume, 3.0);
	
func set_daylight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.WHITE, 1.0);
	
func set_nightlight() -> void:
	var tween := create_tween().set_parallel(true);
	tween.tween_property(light, "light_color", Color.DARK_CYAN, 1.0);
