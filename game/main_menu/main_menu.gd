class_name MainMenu
extends Node

@export var game_scene: PackedScene = null;

func _enter_tree() -> void :
	assert(game_scene != null);
	return;

func pre_start_game() -> void :
	Globals.init_globals();
	return;

func start_game() -> void :
	var parent: Node = get_parent();
	assert(parent != null);
	
	pre_start_game();
	
	var game: Node = game_scene.instantiate();
	assert(game != null);
	
	parent.add_child(game);
	game.owner = parent;
	
	remove_menu();
	return;

func remove_menu() -> void :
	queue_free();
	return;


func _on_btn_start_pressed() -> void :
	start_game();
	return;


func _on_btn_quit_pressed() -> void :
	get_tree().quit();
	return;
