class_name Player
extends Node3D

# handles the "abstract" Player
# not the in-world character, but everything player related (including the in-world character)

@onready var resources: PlayerResources = $PlayerResources;
@onready var construction: PlayerConstruction = $PlayerConstruction;
@onready var character: PlayerCharacter = $CharacterBody3D;

@export_group("Extern References")
@export var construction_grid: ConstructionGrid = null;

# J'en ai besoin pour le day-night -Matéu
static var instance : Player = null;

func _ready() -> void :
	assert(resources != null);
	assert(character != null);
	assert(construction_grid != null);
	assert(construction != null);
	construction.construction_grid = construction_grid;
	
	instance = self;
	
	return;
