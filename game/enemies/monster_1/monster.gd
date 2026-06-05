class_name Monster
extends Node3D

# Pour le wave manager, pas touche
var index : int;

@export_group("Power")
# Pour la génération de vagues
@export var strength : int = 1;

@export_group("Movement")
@export var default_target : Node3D;
@export var speed : float;

@export_group("Damage")
@export var attack_damage : int;

@onready var health_component : HealthComponent = $HealthComponent;
@onready var gravity : Vector3 = ProjectSettings.get_setting(&"physics/3d/default_gravity_vector")
@onready var character : CharacterBody3D = $Monster;
@onready var navigation : NavigationAgent3D = $Monster/NavigationAgent3D;
@onready var animations : Monster1Animations = $Monster/MonsterAnimation;
@onready var viewport : SubViewport = $Viewport;
@onready var camera : Camera3D = $Viewport/Camera3D;
var initial_camera_transform : Transform3D;

var in_sight : Array[Node3D];
var in_attack_range : Array[Node3D];

func _ready() -> void:
	health_component.died.connect(on_monster_death);
	health_component.health_changed.connect(on_monster_hit);
	navigation.max_speed = speed;
	initial_camera_transform = camera.transform;
	
func on_monster_death(_from : HealthComponent) -> void:
	set_physics_process(false);
	character.visible = false;
	queue_free();
	
func on_monster_hit(_from : HealthComponent, _new_hp: int) -> void:
	animations.start_hurt();
	
func _physics_process(_delta: float) -> void:
	character.move_and_slide();
	if not character.velocity.is_zero_approx():
		character.look_at(character.global_position + character.velocity, Vector3.UP, true);
	global_position = character.global_position;
	camera.transform = initial_camera_transform;
	camera.position += character.global_position;
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
