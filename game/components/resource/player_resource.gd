class_name PlayerResource # Resource = crystals, action points, ...  and Resource = godot::Resource class
extends Resource

# Represents a type of resource the player has : an int value >= 0 that can be incremented or decremented
# emits a signal when the amout of the resource changes,
# has some methods to interact with the amount in a controlled way, ...

signal amount_changed(new_amount: int, delta: int);

# @export var name: String;
# @export var sprite: Texture2D = null;
@export var _amount: int = 0;

func get_amount() -> int :
	return _amount;

func has_amount(amount: int) -> bool :
	return (_amount >= amount);

func add(amount: int) -> void :
	assert(amount >= 0);
	_amount += amount;
	
	amount_changed.emit(_amount, amount);
	return;

func remove(amount: int) -> void :
	assert(has_amount(amount));
	_amount -= amount;
	
	amount_changed.emit(_amount, -amount);
	return;

func remove_with_check(amount: int) -> bool :
	if not has_amount(amount):
		return false;
	remove(amount);
	return true;

func override_amount(new_amount: int) -> void :
	var delta: int = new_amount - _amount;
	_amount = new_amount;
	amount_changed.emit(_amount, delta);
	return;
