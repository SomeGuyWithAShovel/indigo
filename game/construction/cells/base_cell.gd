class_name PlayerBaseCell
extends Node3D

# base class for all cells, so we have a fixed type (like a typedef, not really a class).
# if you want to add something to all cells of any type, 
# prefer adding a Dictionary[Vector2i, YourNewData] into player_base.gd

@onready var health : HealthComponent = $HealthComponent;

@export var moduleslots_array:Array[PlayerBaseModuleSlot] = [];
@export var meshinstance_array:Array[MeshInstance3D] = [];

func hasModuleAvaibleSlot() -> bool:
	return moduleslots_array.size() > 0;
