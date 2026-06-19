extends Node3D

@export var camera : Camera3D;
@export var time_between_checks = 0.2;
@export var button_indication_container_scene : PackedScene;
var indication_container : ButtonIndicationContainer;

var reparable : Array[Node3D];

var cur_target_repair:PlayerBaseCell;
var cur_reapair_cost:int = 0;

signal interaction_target_changed(old : Node3D, new : Node3D);

var interaction_target : Node3D = null :
	get:
		return interaction_target;
	set(value):
		if value != interaction_target:
			interaction_target_changed.emit(interaction_target, value);
			interaction_target = value;
			
var timer : Timer;

func _ready() -> void:
	timer = Timer.new();
	timer.timeout.connect(decide_interaction_target);
	add_child(timer);
	timer.one_shot = false;
	timer.start(time_between_checks);
	interaction_target_changed.connect(on_interaction_target_change);
	
	indication_container = button_indication_container_scene.instantiate() as ButtonIndicationContainer;
	assert(indication_container != null);
	assert(camera != null);
	indication_container.camera = camera;

func _input(event):
	if interaction_target == null: return;
	if event.is_action_pressed(&"repair"):
		start_repair()

func decide_interaction_target() -> void:
	var pos : Vector3 = (get_parent() as Node3D).global_position;
	var min_distance_squared : float = INF;
	var new_interaction_target : Node3D = null;
	for candidate in reparable:
		var d := pos.distance_squared_to(candidate.global_position);
		if d < min_distance_squared:
			min_distance_squared = d;
			new_interaction_target = candidate;
	interaction_target = new_interaction_target;

func on_interaction_target_change(old : Node3D, new : Node3D) -> void:
	if old != null:
		UIManager.instance.remove_child(indication_container);
		indication_container.remove_all_indications();
	if new != null:
		#var new_interactible := new.interactible as Interactible;
		UIManager.instance.add_child(indication_container);
		indication_container.unprojector.global_position = new.global_position;
		# Pour que le unprojector puisse ticker une fois,
		# on veut pas afficher l'indicateur avant qu'il soit placé au bon endroit
		await get_tree().process_frame; 
		setup_indication();

func setup_indication() -> void:
	indication_container.add_indication(KEY_R, Interactible.Action.REPAIR);

func entered(node : Node3D) -> void:
	var node_parent : Node3D = node.get_parent();
	
	reparable.append(node_parent);
		
func exited(node : Node3D) -> void:
	if cur_target_repair != null:
		if cur_target_repair == node.get_parent():
			repair_interupted()
	reparable.erase(node.get_parent());

func start_repair():
	#Verification des cristaux
	cur_target_repair = interaction_target;
	var type:PlayerBaseCell.cell_type = cur_target_repair.building_type
	var crystals: PlayerResource = $"../..".crystals;
	var base_cell_cost: float = PlayerBaseCells.crystal_costs[type];
	if cur_target_repair.buildingstatus == PlayerBaseCell.BuildingState.Destroyed:
		base_cell_cost = base_cell_cost*0.8
	else:
		var health_ratio = float(cur_target_repair.health._current_health)/cur_target_repair.health.max_health
		base_cell_cost = base_cell_cost*0.5*health_ratio
	
	cur_reapair_cost = ceil(base_cell_cost)
	
	if (crystals.has_amount(cur_reapair_cost) == false) :
		#TODO Spawn du pop UP !
		cur_target_repair = null
		cur_reapair_cost = 0
		return
	indication_container.remove_all_indications()
	
	$Timer.start()
	pass

func repair_interupted():
	setup_indication()
	$Timer.stop()
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	entered(area)

func _on_area_3d_area_exited(area: Area3D) -> void:
	exited(area)


func _on_area_3d_body_entered(body: Node3D) -> void:
	entered(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	exited(body)


func _on_fnished_repair() -> void:
	cur_target_repair.restore_building()
	#On retire les cristaux
	var crystals: PlayerResource = $"../..".crystals;
	crystals.remove(cur_reapair_cost)
	
	
