extends RefCounted
class_name Interactible

enum Action {
	NONE,
	MINE,
	REPAIR,
	QUOTA,
	UNDO,
}

var interact : Callable;
var uninteract : Callable;
var action := Action.NONE;
var _uninteractible := true;

func _init(_interact : Callable, _action : Action, _uninteract : Callable = Callable()) -> void:
	interact = _interact;
	if not _uninteract.is_null():
		uninteract = _uninteract  
		_uninteractible = true;
	else:
		uninteract = Callable(self, "unimplemented");
		_uninteractible = false;
	action = _action;
	
func is_uninteractible() -> bool:
	return _uninteractible;
	
func unimplemeneted() -> void:
	assert(false, "Uninteract appelé alors que sa valeur n'a pas été changée");
