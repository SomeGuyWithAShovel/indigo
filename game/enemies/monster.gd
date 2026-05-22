class_name Monster
extends Node3D

@export var objective_position : Vector3;
@export var speed : float;

@export_group("Damage")
@export var attack_damage : int;
@export var attack_rampup : float;
@export var attack_cooldown : float;

@onready var health_component : HealthComponent = $HealthComponent;
@onready var gravity : Vector3 = ProjectSettings.get_setting(&"physics/3d/default_gravity_vector")
@onready var character : CharacterBody3D = $".";

var target : Node3D = null;
# Alterne entre les 2 timers pour savoir quand est le temps de recharge et quand est l'attaque
var rampup_timer : Timer;
var cooldown_timer : Timer;

func get_target_position() -> Vector3:
	var res : Vector3;
	if target == null:
		res = objective_position;
	else:
		res = target.global_position;
	return res;

func _ready() -> void:
	rampup_timer = Timer.new();
	rampup_timer.one_shot = true;
	rampup_timer.timeout.connect(hurt_target);
	rampup_timer.timeout.connect(start_cooldown);
	add_child(rampup_timer);
	
	cooldown_timer = Timer.new();
	cooldown_timer.one_shot = true;
	cooldown_timer.timeout.connect(start_rampup);
	add_child(cooldown_timer);
	
	health_component.died.connect(on_monster_death);
	
func on_monster_death(_from : HealthComponent) -> void:
	set_physics_process(false);
	visible = false;
	await get_tree().create_timer(1.0).timeout;
	queue_free();
	get_tree().reload_current_scene();
	
func start_rampup() -> void:
	rampup_timer.start(attack_rampup)

func start_cooldown() -> void:
	cooldown_timer.start(attack_cooldown);	

func hurt_target() -> void:
	assert(target is Player);
	(target as Player).health.hurt(attack_damage);
	
func _physics_process(_delta: float) -> void:
	var direction = get_target_position() - global_position;
	character.velocity = direction.normalized()*speed;
	character.velocity += gravity*100.0;
	character.move_and_slide();

func _on_player_entered_sight(body: Node3D) -> void:
	assert(body is Player);
	print("Player entered monster sight");
	target = body;

func _on_player_exited_sight(body: Node3D) -> void:
	if target == body:
		print("Player exited monster sight")
		target = null;

func _on_player_entered_attack_range(body: Node3D) -> void:
	assert(body is Player);
	print("Player entered monster range");
	rampup_timer.start(attack_rampup);

func _on_player_exited_attack_range(body: Node3D) -> void:
	assert(body is Player);
	print("Player exited monster range");
	rampup_timer.stop();
	if not cooldown_timer.is_stopped():
		cooldown_timer.timeout.disconnect(start_rampup);
		cooldown_timer.timeout.connect(
			func (): cooldown_timer.timeout.connect(start_rampup),
			CONNECT_ONE_SHOT
		);
