class_name PlayerCharacter
extends Node3D

@export_group("Movement parameters")
@export var direction_switch_lag : float = 0.01;
@export var max_speed : float = 10.0;
@export var acceleration : float = 10.0;
@export var desceleration : float = 10.0;
@onready var gravity : Vector3 = ProjectSettings.get_setting(&"physics/3d/default_gravity_vector")

@onready var player: Player = $"..";

@onready var character : CharacterBody3D = $".";
@onready var health : HealthComponent = $"../HealthComponent";

var previous_input_direction := Vector3(0, 0, 0);
var current_input_direction := Vector3(0, 0, 0);
var time_since_direction_change := 0.0;
var acceleration_weight := 0.0;
var camera : Camera3D;

func _ready() -> void:
	camera = player.camera;
	assert(player != null);
	assert(camera != null);
	assert(character != null);
	assert(health != null);
	
	health.died.connect(kill);
	DayNightSystem.on_day_start.connect(func () :
		health.reset();	
	);

func kill(_health : HealthComponent) -> void:
	visible = false;
	character.set_collision_layer_value(2, false);
	await get_tree().create_timer(1.0).timeout;
	position = Vector3(0, 10, 0);
	character.set_collision_layer_value(2, true);
	health.reset();
	var crystal:PlayerResource = player.crystals
	var amount_to_remove = floori(crystal.get_amount() / 3.0); #On garde le int car crystal est un int
	#Securite au cas ou meme si je vois pas de raison mtn
	if (crystal.has_amount(amount_to_remove)):
		crystal.remove(amount_to_remove)
	
	visible = true;

func get_input_direction() -> Vector3:
	var horizontal_axis : float = Input.get_axis(&"move_left", &"move_right");
	var vertical_axis : float = Input.get_axis(&"move_forwards", &"move_backwards");
	# Repère "Minecraft" : Y = 0
	var input_direction := Vector3(horizontal_axis, 0, vertical_axis).normalized();
	return input_direction;

func get_move_direction() -> Vector3:
	var weight := time_since_direction_change/direction_switch_lag;
	if previous_input_direction.is_zero_approx():
		weight = 1.0;
	var direction := previous_input_direction.lerp(current_input_direction, weight);
	return direction;
	
func get_move_speed(input_direction : Vector3, delta : float) -> float:
	var speed : float;
	if input_direction.is_zero_approx():
		acceleration_weight += delta*desceleration;
	else:
		acceleration_weight += delta*acceleration;
	acceleration_weight = clamp(acceleration_weight, 0.0, 1.0);
	
	speed = lerpf(0.0, max_speed, acceleration_weight);
	
	return speed;

func _input(_event: InputEvent) -> void :
	return;

func _physics_process(_delta: float) -> void:
	if health.get_health() == 0:
		return;
	
	var input_direction := get_input_direction();
	if not input_direction.is_equal_approx(current_input_direction):
		previous_input_direction = current_input_direction;
		current_input_direction = input_direction;
		# Si on tourne "un peu" vers la gauche ou la droite, on veut pas perdre toute notre vitesse
		# Si on tourne à plus d'un angle droit, on repart de 0
		time_since_direction_change = 0.0;
		if not current_input_direction.is_zero_approx():
			acceleration_weight = max(0.0, current_input_direction.dot(previous_input_direction));
			pass;
		pass;
	
	time_since_direction_change = clampf(time_since_direction_change + _delta, 0.0, direction_switch_lag);
	var direction := get_move_direction();
	var speed := get_move_speed(input_direction, _delta);
	if (!direction.is_zero_approx()):
		$space_man_model.play_forward();
		$space_man_model.look_at(global_position - direction)
		print($space_man_model.position)
	else:
		$space_man_model.play_idle();
	
	character.velocity = speed * direction;
	character.velocity += _delta * gravity * 100.0;
	character.move_and_slide();
	# On veut récupérer la position depuis le Player, pas le PlayerCharacter
	# CharacterBody3D ne peut pas déplacer autre chose qu'un Collider malheureusement...
	player.global_position = character.global_position;
	character.position = Vector3.ZERO;
	return;
