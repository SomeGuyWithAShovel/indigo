extends Node
class_name GameOver

signal game_over(message : String);

enum Reason {
	QUOTA_NOT_MET,
};

func as_message(reason : Reason) -> String:
	match reason:
		Reason.QUOTA_NOT_MET:
			return "Not enough cristals. Contract terminated";
	return "[Raison manquante : faut débugger game_over.gd]";

func end_game(reason : Reason) -> void:
	game_over.emit(as_message(reason));
