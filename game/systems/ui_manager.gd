extends Node
class_name UIManager

enum State {
	DAY,
	NIGHT,
	GAME_OVER,
}

@export var ui_for_state : Dictionary[State, PackedScene];

@export var state : State = State.DAY : 
	get = get_state,
	set = set_state;
	
func _ready() -> void:
	DayNightSystem.on_day_start.connect(func (): set_state(State.DAY));
	DayNightSystem.on_night_start.connect(func (): set_state(State.NIGHT));
	
func get_state() -> State:
	return state;
	
func set_state(value : State) -> void:
	print("set_state");
	state = value;
	for child in get_children():
		remove_child(child);
	var new_ui : Control = ui_for_state[state].instantiate();
	add_child(new_ui);
