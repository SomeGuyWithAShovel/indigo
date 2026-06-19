class_name Player
extends Node3D

# handles the "abstract" Player
# not the in-world character, but everything player related (including the in-world character)

@export_group("Internal References")
@export var construction: PlayerConstruction = null;
@export var camera: Camera3D = null;
@export var character: PlayerCharacter = null;
@export var player_damaged_sound: AudioStreamPlayer = null;

@export_group("Player Resources")
@export var crystals : PlayerResource = null;
@export var action_points : PlayerResource = null;

@export_group("Mouse Raycasts")
@export var mouse_raycast_length: float = 100.0;
@export var nodes_to_exclude: Array[CollisionObject3D] = [];
var last_mouse_pos_clicked: Vector2 = Vector2.ZERO;
var mouse_clicked: bool = false;
var selected_construction_type: ModuleId.Of = ModuleId.Of.NONE;

var ghost_building:Node3D
var ghost_label:Label3D
var blue_material:Material = load("res://assets/Material/construction_blue.tres")
var red_material:Material = load("res://assets/Material/construction_red.tres")

func _enter_tree() -> void :
	
	assert(camera != null); 
	SeeThroughSystem.instance.normal_camera = camera;
	assert(construction != null);
	assert(character != null);
	
	assert(crystals != null);
	assert(action_points != null);
	
	assert(player_damaged_sound != null);
	return;

func _ready() -> void :
	DayNightSystem.on_night_start.connect(on_night_start);
	ghost_label = Label3D.new()
	ghost_label.text = "temp"
	ghost_label.font_size = 50
	ghost_label.position = Vector3(0, 2, 0)
	ghost_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return;

func _unhandled_input(_event: InputEvent) -> void :
	var btn_event = _event as InputEventMouseButton;
	if ((btn_event != null) && (btn_event.button_index == 1) && (btn_event.pressed)) :
		last_mouse_pos_clicked = btn_event.position;
		mouse_clicked = true; # we need to do the raycast in _physics_process(), but we need to know when in _input()
		print("PLAYER UNHANDLED INPUT"); # why does it triggers, even if we hit a UI element ???????????????????????
		pass;
	return;

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		last_mouse_pos_clicked = get_viewport().get_mouse_position();
		if UIManager.instance.is_build_menu_open: 
			try_build.call_deferred();
	if (ghost_building != null):
		update_ghost()
	return;


func on_night_start() -> void :
	set_selected_construction_type(ModuleId.Of.NONE);
	return;

func update_ghost():
	#Securite au cas ou
	if (selected_construction_type == ModuleId.Of.NONE):
		return 
	if (ghost_building == null):
		return
	var mouse_pos:Vector2 = get_viewport().get_mouse_position();
	var raycast_result = do_mouse_raycast_at(mouse_pos)
	if (raycast_result == null) :
		return;
	var collided : Node3D = raycast_result["collider"] as Node3D;
	if (collided == null) :
		return;
	var collided_parent = collided.get_parent();
	if (collided_parent == null) :
		return;
	var collided_grid: ConstructionGrid = collided_parent as ConstructionGrid;
	if (collided_grid == null) :
		return;
	var raycast_position: Vector3 = raycast_result["position"];
	var cell_coord: Vector2 = collided_grid.get_grid_coords_from_world_coords(raycast_position);
	
	#On ne modifie que la position.
	var construction_result:PlayerConstruction.Construction_Result =  construction.check_construct_cell(collided_grid, cell_coord, selected_construction_type);
	print(construction_result)
	#On peut creer sans desactiver car le "pouvoir" des batiment, c'est la nuit
	
	update_ghost_position(cell_coord,collided_grid)
	
	#Changement du label de la raison de pourquoi on peut pas pas ordre de priorite
	match construction_result:
		PlayerConstruction.Construction_Result.NeedNearTube:
			ghost_label.text = "Ce batiments doit être construit à côté de ta base"
		PlayerConstruction.Construction_Result.InvalidPlacement:
			ghost_label.text = "Emplacements Invalide"
		PlayerConstruction.Construction_Result.NoSlotAvaible:
			ghost_label.text = "Pas de module de porte disponible dans ce batiments"
		PlayerConstruction.Construction_Result.NoCrystal:
			ghost_label.text = "Pas assez de cristal"
		PlayerConstruction.Construction_Result.Other,PlayerConstruction.Construction_Result.Possible:
			ghost_label.text = ""
	
	if (!(construction_result == PlayerConstruction.Construction_Result.Possible)):
		color_building(red_material)
		#TODO Affichage de la raison
	else:
		color_building(blue_material)

	
	return;

func color_building(material:Material):
	if (selected_construction_type != ModuleId.Of.HATCH):
		var ghost_cell = ghost_building as PlayerBaseCell
		#On rajoute a tous ses meshInstance du bleu
		for i:MeshInstance3D in ghost_cell.meshinstance_array:
			i.material_overlay = material
	#Different pour le module (herite pas de player base cell)
	elif (selected_construction_type == ModuleId.Of.HATCH):
		var ghost_cell = ghost_building as PlayerBaseModule
		#On rajoute a tous ses meshInstance du bleu
		for i:MeshInstance3D in ghost_cell.meshinstance_array:
			i.material_overlay = material

func update_ghost_position(new_cell_coord: Vector2,collided_grid:ConstructionGrid):
	var cell_world_coord:Vector3 = collided_grid.get_world_coords_from_grid_coords(new_cell_coord)
	ghost_building.global_position = cell_world_coord
	#Rotation de la porte en fonction du tube
	if (selected_construction_type == ModuleId.Of.HATCH):
		print(collided_grid.getDir_from_cell(new_cell_coord))
		#ghost_building.global_rotation_degrees += Vector3(0,1,0)
		#print(ghost_building.global_rotation)
		match collided_grid.getDir_from_cell(new_cell_coord):
			Dir.Enum.E:
				#Ouest (Les dir sont inverse de 180 ;( )
				ghost_building.global_rotation_degrees = Vector3(0,180,0)
			Dir.Enum.W:
				#Est
				ghost_building.global_rotation_degrees = Vector3(0,0,0)
			Dir.Enum.N:
				#Sud
				ghost_building.global_rotation_degrees = Vector3(0,270,0)
			Dir.Enum.S:
				#Nord
				ghost_building.global_rotation_degrees = Vector3(0,90,0)
	elif ghost_building.global_rotation_degrees != Vector3(0,0,0):
		ghost_building.global_rotation_degrees = Vector3(0,0,0)
	pass


func try_build() -> void:
	var is_open = UIManager.instance.is_build_menu_open;
	if is_open:
		var raycast_result := do_mouse_raycast_at(last_mouse_pos_clicked);
		if (raycast_result) :
			raycast_on_construction_grid(raycast_result);
			return;
		return;
	return;

func set_selected_construction_type(construction_type: ModuleId.Of) -> void :
	selected_construction_type = construction_type;
	print("selected construction_type ", selected_construction_type);
	if (ghost_building != null):
		ghost_building.remove_child(ghost_label)
		ghost_building.queue_free();
		ghost_label.text = ""
		ghost_building = null;
		
		pass;
	match selected_construction_type:
		ModuleId.Of.NONE:
			ghost_building = null
			ghost_label.text = ""
		ModuleId.Of.TUBE:
			ghost_building = PlayerBaseCells.base_scene_array[0].instantiate()
			ghost_building.add_child(ghost_label)
			add_child(ghost_building)
		ModuleId.Of.TURRET:
			ghost_building = PlayerBaseCells.turret_scene_array[0].instantiate()
			ghost_building.add_child(ghost_label)
			add_child(ghost_building)
		ModuleId.Of.MISSILE_LAUNCHER:
			ghost_building = PlayerBaseCells.turret_scene_array[1].instantiate()
			ghost_building.add_child(ghost_label)
			add_child(ghost_building)
		ModuleId.Of.HATCH:
			ghost_building = PlayerBaseModules.scene_array[1].instantiate()
			ghost_building.add_child(ghost_label)
			add_child(ghost_building)
		ModuleId.Of.AUTO_MINER:
			ghost_building = PlayerBaseCells.mining_scene.instantiate()
			ghost_building.is_ghost = true
			ghost_building.add_child(ghost_label)
			add_child(ghost_building)
			
#	var cell = ghost_building as PlayerBaseCell;
#	if cell: cell.collision.collision_layer = 0b1000;
	
	return;

func do_mouse_raycast_at(mouse_pos: Vector2) -> Dictionary :
	# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	
	var space_state = get_world_3d().direct_space_state
	
	var raycast_from = camera.project_ray_origin(mouse_pos)
	var raycast_to = raycast_from + camera.project_ray_normal(mouse_pos) * mouse_raycast_length;
	
	var raycast_query = PhysicsRayQueryParameters3D.create(raycast_from, raycast_to)
	raycast_query.collide_with_areas = true;
	
	raycast_query.collision_mask = (1 << 5); # 6th collision layer (should be Grid)
	
	# can't do : raycast_query.exclude.push_back() : raycast_query.exclude returns a COPY, so we would push_back to a rvalue
	var excluded_objects : Array[RID] = raycast_query.exclude;
	for collision_object in nodes_to_exclude :
		excluded_objects.push_back(collision_object);
		pass;
	raycast_query.exclude = excluded_objects;
	
	return space_state.intersect_ray(raycast_query);

func raycast_on_construction_grid(raycast_result: Dictionary) -> void :
	if (raycast_result == null) :
		return;
	var collided : Node3D = raycast_result["collider"] as Node3D;
	if (collided == null) :
		return;
	var collided_parent = collided.get_parent();
	if (collided_parent == null) :
		return;
	var collided_grid: ConstructionGrid = collided_parent as ConstructionGrid;
	if (collided_grid == null) :
		return;
	
	var raycast_position: Vector3 = raycast_result["position"];
	var cell_coord: Vector2 = collided_grid.get_grid_coords_from_world_coords(raycast_position);
	
	if ((selected_construction_type != ModuleId.Of.NONE) && 
		(collided_grid.is_terrain_ok_to_build(cell_coord)) ) :
		
		construction.try_construct_cell(collided_grid, cell_coord, selected_construction_type);
		pass;
	return;


func _on_damaged(_new_hp: int, _old_hp: int) -> void :
	player_damaged_sound.play();
	return;
