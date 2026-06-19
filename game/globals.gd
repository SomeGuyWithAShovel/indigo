extends Node

signal globals_setup();

var player: Player = null;
var is_setup:bool = false;

func _ready() -> void :
	# init_globals(); # main_menu.gd::pre_start_game();
	return;

func init_globals() -> void :
	GameOverSystem.game_over.connect(reset_state, CONNECT_ONE_SHOT);
	get_tree().scene_changed.connect(_ready, CONNECT_ONE_SHOT);
	regenerate_globals.call_deferred();
	return;

func reset_state(_s) -> void :
	is_setup = false;
	if (player != null) :
		player.queue_free();
		player = null;
		pass;
	return;
	
func regenerate_globals() -> void :
	var players = get_tree().current_scene.find_children("*", "Player");
	assert(len(players) == 1);
	player = players[0];
	is_setup = true;
	globals_setup.emit();
	return;
