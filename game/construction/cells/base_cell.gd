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
@onready var collision : CollisionObject3D = $CollisionWalls;

@export var moduleslots_array:Array[PlayerBaseModuleSlot] = [];
@export var meshinstance_array:Array[MeshInstance3D] = [];

var buildingstatus:BuildingState = BuildingState.Alive

var building_type:cell_type = cell_type.BASE_CELL

enum BuildingState{
	Alive,
	Destroyed
}

static var destroyed_material:Material = load("res://assets/Material/construction_destroyed.tres")

func _ready() -> void:
	health.died.connect(on_cell_death);

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
