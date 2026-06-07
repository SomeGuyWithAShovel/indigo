extends Node
class_name UIManager

enum State {
	DAY,
	NIGHT,
	GAME_OVER,
}

static var instance : UIManager = null;

@export var ui_for_state : Dictionary[State, PackedScene];
@export var building_ui : PackedScene;

var building_ui_node : BuildingUI;
var ui_nodes : Dictionary[State, Control];
var is_build_menu_open := false;

@export var state : State = State.DAY : 
	get = get_state,
	set = set_state;
	
func _ready() -> void:
	instance = self;
	DayNightSystem.on_day_start.connect(func (): set_state(State.DAY));
	DayNightSystem.on_night_start.connect(func (): set_state(State.NIGHT));
	
	for s in ui_for_state.keys():
		ui_nodes[s] = ui_for_state[s].instantiate();
	building_ui_node = building_ui.instantiate();
	set_state(state);
	
func get_state() -> State:
	return state;
	
func close_building_menu() -> void:
	is_build_menu_open = false;
	await building_ui_node.close_animation();
	remove_child(building_ui_node);

func open_building_menu() -> void:	
	if not is_build_menu_open:
		add_child(building_ui_node);
		is_build_menu_open = true;
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_build_menu"):
		if not is_build_menu_open:
			open_building_menu();
		else:
			close_building_menu();
	
func bind_to_build_ui(callable : Callable) -> void:
	assert(callable.get_argument_count() == 1, 
	"Le callable à lier au UI de construction doit prendre un argument (un ModuleId.Of)")
	building_ui_node.on_module_requested.connect(callable);
	building_ui_node.on_module_requested.connect(callable);
	
func set_state(value : State) -> void:
	print("set_state");
	state = value;
	for child in get_children():
		remove_child(child);
	
	add_child(ui_nodes[state]);
