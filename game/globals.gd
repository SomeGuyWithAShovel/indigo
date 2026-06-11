extends Node

signal globals_setup();

var player : Player = null;
var is_setup := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameOverSystem.game_over.connect(reset_state, CONNECT_ONE_SHOT);
	get_tree().scene_changed.connect(_ready, CONNECT_ONE_SHOT);
	regenerate_globals.call_deferred();

func reset_state(_s) -> void:
	is_setup = false;
	if player != null:
		player.queue_free();
		player = null;
	
func regenerate_globals() -> void:
	var players = get_tree().current_scene.find_children("*", "Player");
	assert(len(players) == 1);
	player = players[0];
	is_setup = true;
	globals_setup.emit();
