class_name PlayerBaseCell
extends Node3D

# base class for all cells, so we have a fixed type (like a typedef, not really a class).
# if you want to add something to all cells of any type, 
# prefer adding a Dictionary[Vector2i, YourNewData] into player_base.gd

#Repetition de mosule_id mais en plus propre
enum cell_type {
	NONE = 0,
	BASE_CELL = 1,
	DOOR = 2,
	AUTO_MINER = 3,
	CLASSIC_TURRET = 4,
	MISSILE_LAUNCHER = 5,
}


@onready var health : HealthComponent = $HealthComponent;
var collision : CollisionObject3D;

@export var moduleslots_array:Array[PlayerBaseModuleSlot] = [];
@export var meshinstance_array:Array[MeshInstance3D] = [];

var buildingstatus:BuildingState = BuildingState.Alive

var building_type:cell_type = cell_type.BASE_CELL

var interactible : Interactible;

var is_reperable = false;

enum BuildingState{
	Alive,
	Destroyed
}

static var destroyed_material:Material = load("res://assets/Material/construction_destroyed.tres")

func _ready() -> void:
	interactible = Interactible.new(Callable(), Interactible.Action.NONE, Callable(),Callable(self,&"restore_building"));
	collision = $CollisionWalls;
	health.died.connect(on_cell_death);
	health.health_changed.connect(on_health_changed)
	health.hurt(9999)

func on_health_changed(_from : HealthComponent, new_hp: int) -> void:
	if (new_hp == health.max_health):
		is_reperable = false;
	else:
		is_reperable = true

func on_cell_death(_from : HealthComponent) -> void:
	buildingstatus = BuildingState.Destroyed
	for i:MeshInstance3D in meshinstance_array:
		i.material_overlay = destroyed_material
	
	#Desactivation du layer 7 (base) pour allez vers le 8 (base_destroy)
	var static_body = find_children("*", "StaticBody3D", false);
	assert(not static_body.is_empty());
	static_body[0].set_collision_layer_value(8, true) 
	static_body[0].set_collision_layer_value(7, false)
	deactivate()

func restore_building():
	buildingstatus = BuildingState.Alive
	for i:MeshInstance3D in meshinstance_array:
		i.material_overlay = null
	
	#Desactivation du layer 7 (base) pour allez vers le 8 (base_destroy)
	var static_body = find_children("*", "StaticBody3D", false);
	if static_body.is_empty():
		print("JAI PAS TROUVE PROBLEME")
		return
	else:
		static_body[0].set_collision_layer_value(7, true)
		static_body[0].set_collision_layer_value(8, false)
	health.reset()
	reactivate()

#Fonction pour les enfants pour qu'il puisse desactiver ce qu'il on besoin
func deactivate():
	return

func reactivate():
	return
	
	
func getbuildingState()->BuildingState:
	return buildingstatus

func hasModuleAvaibleSlot() -> bool:
	return moduleslots_array.size() > 0;
