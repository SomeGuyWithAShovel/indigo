extends Node
class_name UIManager

enum State {
	DAY,
	NIGHT,
	GAME_OVER,
	DAY_UI,
	NIGHT_UI,
}

@export var ui_for_state : Dictionary[State, PackedScene];

var ui_nodes : Dictionary[State, Control];

@export var state : State = State.DAY : 
	get = get_state,
	set = set_state;
	
func _ready() -> void:
	DayNightSystem.on_day_start.connect(func (): set_state(State.DAY));
	DayNightSystem.on_night_start.connect(func (): set_state(State.NIGHT));
	
	for s in ui_for_state.keys():
		ui_nodes[s] = ui_for_state[s].instantiate();
	
func get_state() -> State:
	return state;
	
func bind_to_build_ui(callable : Callable) -> void:
	assert(callable.get_argument_count() == 1, 
	"Le callable à lier au UI de construction doit prendre un argument (un ModuleId.Of)")
	(ui_nodes[State.DAY_UI] as BuildingUI).on_module_requested.connect(callable);
	(ui_nodes[State.NIGHT_UI] as BuildingUI).on_module_requested.connect(callable);
	
func set_state(value : State) -> void:
	print("set_state");
	state = value;
	for child in get_children():
		remove_child(child);
	
	add_child(ui_nodes[state]);
