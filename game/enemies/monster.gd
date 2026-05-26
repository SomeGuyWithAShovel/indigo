class_name Monster
extends Node3D

@export_category("Movement")
@export var default_target : Node3D;
@export var speed : float;

@export_group("Damage")
@export var attack_damage : int;
@export var attack_rampup : float;
@export var attack_cooldown : float;

@onready var health_component : HealthComponent = $HealthComponent;
@onready var gravity : Vector3 = ProjectSettings.get_setting(&"physics/3d/default_gravity_vector")
@onready var character : CharacterBody3D = $Monster;
@onready var navigation : NavigationAgent3D = $Monster/NavigationAgent3D;
var in_sight : Array[Node3D];
var in_attack_range : Array[Node3D];

func _ready() -> void:
	health_component.died.connect(on_monster_death);
	navigation.max_speed = speed;
	
func on_monster_death(_from : HealthComponent) -> void:
	set_physics_process(false);
	character.visible = false;
	await get_tree().create_timer(1.0).timeout;
	queue_free();
	get_tree().reload_current_scene();
	
func _physics_process(_delta: float) -> void:
	global_position = character.global_position;
	character.position = Vector3.ZERO;
	
func _on_entered_sight(body: Node3D) -> void:
	# Parent parce qu'on veut la node complète et on suppose que
	# le collider est situé sur un enfant
	in_sight.push_back(body.get_parent());

func _on_exited_sight(body: Node3D) -> void:
	# voir _on_entered_sight pour get_parent()
	in_sight.erase(body.get_parent());

func _on_entered_attack_range(body: Node3D) -> void:
	# Parent parce qu'on veut la node complète et on suppose que
	# le collider est situé sur un enfant
	in_attack_range.push_back(body.get_parent());

func _on_exited_attack_range(body: Node3D) -> void:
	# voir _on_exited_attack_range pour get_parent()dz
	in_attack_range.erase(body.get_parent());
