extends Node
class_name GameOver

signal game_over(message : String);

enum Reason {
	QUOTA_NOT_MET,
	QUOTA_BOX_DESTROYED,
};

func _ready() -> void:
	game_over.connect(reload);

const CONFIRMATION = preload("res://game/ui/confirmation.tscn");
func reload(msg : String) -> void:
	var game_over_menu : Confirmation = CONFIRMATION.instantiate();
	game_over_menu.process_mode = Node.PROCESS_MODE_ALWAYS;
	get_viewport().add_child(game_over_menu);
	game_over_menu.set_text("Game Over\n%s\nRestart ?" % msg);
	if await game_over_menu.is_yes():
		get_tree().reload_current_scene();
		get_tree().paused = false;
	else:
		get_tree().quit();
	get_viewport().remove_child(game_over_menu);
		
func as_message(reason : Reason) -> String:
	match reason:
		Reason.QUOTA_NOT_MET:
			return "Not enough cristals. Contract terminated.";
		Reason.QUOTA_BOX_DESTROYED:
			return "Quota portal down. Contract terminated."
	return "[Raison manquante : faut débugger game_over.gd]";

func end_game(reason : Reason) -> void:
	game_over.emit(as_message(reason));
	get_tree().paused = true;
