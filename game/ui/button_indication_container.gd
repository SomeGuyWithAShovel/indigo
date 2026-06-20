extends Control
class_name ButtonIndicationContainer

@onready var container : Control = $HBoxContainer;
@onready var unprojector : Unprojector = $Unprojector;
var camera : Camera3D;

const BUTTON_INDICATION_SCENE = preload("res://game/ui/ButtonIndication.tscn");

func _ready() -> void:
	unprojector.camera = camera;

# key physique sur le clavier QWERTY
func add_indication(key : Key, action : Interactible.Action) -> void:
	var button_indication : ButtonIndication = BUTTON_INDICATION_SCENE.instantiate();
	container.add_child(button_indication);
	button_indication.key = key;
	button_indication.action = action;
	
func remove_all_indications() -> void:
	for c in container.get_children():
		container.remove_child(c);
		c.queue_free();
