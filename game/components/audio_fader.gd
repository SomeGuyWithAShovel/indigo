extends Node
class_name AudioFader

@export var _audio_player : AudioStreamPlayer;
@export var fade_in_length = 1.0;
@export var fade_out_length = 1.0;
@export var silence_length = 1.0;

var stream : AudioStream :
	get:
		return _audio_player.stream;
	set(value):
		_audio_player.stream = value;
		reset_audio_player();

const INAUDIBLE_VOLUME_DB := -60.0;

const DEBUG_START_AT := 0.0;

var music_tween : Tween;
var audio_length : float;
var initial_volume_db : float;

func _ready() -> void:
	initial_volume_db = _audio_player.volume_db;
	if _audio_player.stream:
		reset_audio_player();

func reset_audio_player() -> void:
	audio_length = _audio_player.stream.get_length() - DEBUG_START_AT;
	play_music();

func play_music() -> void:
	music_tween = create_tween();
	music_tween.tween_property(_audio_player, "volume_db", initial_volume_db, fade_in_length).from(INAUDIBLE_VOLUME_DB);
	music_tween.tween_property(_audio_player, "volume_db", initial_volume_db, audio_length - fade_in_length - fade_out_length);
	music_tween.tween_property(_audio_player, "volume_db", INAUDIBLE_VOLUME_DB, fade_out_length).set_ease(Tween.EASE_IN);
	music_tween.tween_property(_audio_player, "volume_db", INAUDIBLE_VOLUME_DB, silence_length);
	music_tween.finished.connect(play_music);
	_audio_player.play.call_deferred();
	await get_tree().process_frame;
	_audio_player.seek.call_deferred(DEBUG_START_AT);
	
