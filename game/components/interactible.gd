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
var repair: Callable
var action := Action.NONE;
var _interactible := true;
var _uninteractible := true;
var _repairable := true;

#Etant donner que des cible peur etre reparer sans avoir dinteraction, on doit prendre en compte
#Des interactible sans _interact
func _init(_interact : Callable, _action : Action, _uninteract : Callable = Callable(), _repair:Callable = Callable()) -> void:
	interact = _interact;
	if _interact.is_null():
		_interactible = false
	if not _uninteract.is_null():
		uninteract = _uninteract  
		_uninteractible = true;
	else:
		uninteract = Callable(self, "unimplemented");
		_uninteractible = false;
	if not _repair.is_null():
		repair = _repair  
		_repairable = true;
	else:
		repair = Callable(self, "repair_unimplemeneted");
		_repairable = false;
	action = _action;

func is_interactible() -> bool:
	return _interactible;
func is_uninteractible() -> bool:
	return _uninteractible;
func is_repairable() -> bool:
	return _repairable;
	
func unimplemeneted() -> void:
	assert(false, "Uninteract appelé alors que sa valeur n'a pas été changée");
func repair_unimplemeneted() -> void:
	assert(false, "Repair appelé alors que sa valeur n'a pas été changée");
