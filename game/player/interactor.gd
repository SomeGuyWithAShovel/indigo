extends Node3D

@export var time_between_checks = 0.2;

var interactibles : Array[Node3D];
var interaction_target : Node3D = null;
var timer : Timer;

func _ready() -> void:
	timer = Timer.new();
	timer.timeout.connect(decide_interaction_target);
	add_child(timer);
	timer.one_shot = false;
	timer.start(time_between_checks);

func _input(event):
	if event.is_action_pressed(&"interact") and interaction_target != null:
		interaction_target.interact();

func decide_interaction_target() -> void:
	var pos : Vector3 = (get_parent() as Node3D).global_position;
	var min_distance_squared : float = INF;
	interaction_target = null;
	for candidate in interactibles:
		var d := pos.distance_squared_to(candidate.global_position);
		if d < min_distance_squared:
			min_distance_squared = d;
			interaction_target = candidate;

func entered(node : Node3D) -> void:
	print("Entered");
	var node_parent : Node3D = node.get_parent();
	assert(node_parent.has_method("interact"), 
		"Area3D found by interactor on interact layer but whose parent script does not implement an interact method");;
		
	if node_parent is Node3D: # Vérification de type
		interactibles.push_back(node_parent);
		
func exited(node : Node3D) -> void:
	print("Exited");
	interactibles.erase(node.get_parent());
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	entered(area);

func _on_area_3d_area_exited(area: Area3D) -> void:
	exited(area);

func _on_area_3d_body_entered(body: Node3D) -> void:
	entered(body);

func _on_area_3d_body_exited(body: Node3D) -> void:
	exited(body);
