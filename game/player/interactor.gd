extends Node3D

@export var camera : Camera3D;
@export var time_between_checks = 0.2;
@export var button_indication_container_scene : PackedScene;
var indication_container : ButtonIndicationContainer;

var interactibles : Array[Node3D];

var cur_target_repair:Node3D;
var cur_repair_cost:int = 0;
var bar : TextureProgressBar
var bar_parent : Control

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
	if event.is_action_pressed(&"interact"):
		if (interaction_target.get("interactible") as Interactible).is_interactible():
			interaction_target.interact();
	elif event.is_action_pressed(&"uninteract"):
		if (interaction_target.get("interactible") as Interactible).is_uninteractible():
			interaction_target.uninteract();
	elif event.is_action_pressed(&"repair"):
		if (cur_target_repair == null and (interaction_target.get("interactible") as Interactible).is_repairable()):
			print("IF")
			start_repair()
	elif event.is_action_released(&"repair") and cur_target_repair != null:
		repair_interupted();

func start_repair():
	print("JE START RESTORE")
	#Verification quand on sait que interaction target a une methode repair
	#On verifie si  la cellule peut etre reparer (la cellule gere, mais pour l'instant
	#C'est que si elle est pas full hp
	if (!interaction_target.is_reperable):
		print("FULL HP")
		return
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
	
	cur_repair_cost = ceil(base_cell_cost)
	
	if (crystals.has_amount(cur_repair_cost) == false) :
		#TODO Spawn du pop sur le batiments (rajouter un second timer dans interactor gerant le despawn de ce pop up
		cur_target_repair = null
		cur_repair_cost = 0
		return
	cur_target_repair.repair_bar.setRepairTime($Timer.wait_time)
	$Timer.start()
	cur_target_repair.repair_bar.start_repair()
	pass

func repair_interupted():
	print("INTERUPTED")
	cur_target_repair.repair_bar.Interupt()
	cur_target_repair = null
	$Timer.stop()
	

func decide_interaction_target() -> void:
	var pos : Vector3 = (get_parent() as Node3D).global_position;
	var min_distance_squared : float = INF;
	var new_interaction_target : Node3D = null;
	for candidate in interactibles:
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
		var new_interactible := new.interactible as Interactible;
		UIManager.instance.add_child(indication_container);
		indication_container.unprojector.global_position = new.global_position;
		# Pour que le unprojector puisse ticker une fois,
		# on veut pas afficher l'indicateur avant qu'il soit placé au bon endroit
		await get_tree().process_frame; 
		setup_indication(new_interactible);
	
func setup_indication(new_interactible : Interactible) -> void:
	if new_interactible.is_interactible():
		indication_container.add_indication(KEY_E, new_interactible.action);
	if new_interactible.is_uninteractible():
		indication_container.add_indication(KEY_Q, Interactible.Action.UNDO);
	if new_interactible.is_repairable():#Si la fct repair est presente
		if (interaction_target.is_reperable): #Si la cell se declare pouvant etre reparer
			indication_container.add_indication(KEY_R, Interactible.Action.REPAIR);
	
func entered(node : Node3D) -> void:
	var node_parent : Node3D = node.get_parent();
	var interactible : Interactible = node_parent.get("interactible") as Interactible;
	assert(interactible, 
		"Area3D found by interactor on interact layer but whose parent script does not implement an interact method");;
		
	interactibles.append(node_parent);
		
func exited(node : Node3D) -> void:
	interactibles.erase(node.get_parent());
	if (cur_target_repair == node.get_parent()):
		print("NON")
		repair_interupted()
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	entered(area);

func _on_area_3d_area_exited(area: Area3D) -> void:
	exited(area);

func _on_area_3d_body_entered(body: Node3D) -> void:
	entered(body);

func _on_area_3d_body_exited(body: Node3D) -> void:
	exited(body);


func _on_repair_finished() -> void:
	cur_target_repair.restore_building()
	cur_target_repair.repair_bar.Interupt()
	cur_target_repair = null
	#On reinitalise le interaction_target (Actualiser les bouton afficher)
	on_interaction_target_change(interaction_target,interaction_target)
	#On retire les cristaux
	var crystals: PlayerResource = $"../..".crystals;
	crystals.remove(cur_repair_cost)
	
