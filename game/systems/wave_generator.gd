class_name WaveGenerator
extends Node

@export_group("Wave Generation Parameters")
@export var initial_wave_strength : int = 2;
@export var wave_strengh_increment : int = 2;
@export var time_before_wave_start : float = 1.0;
var current_wave_strength : int = 0;

@export_group("Monsters spawnable")
@export var instantiatable_monsters : Array[PackedScene];
@export var default_monster_target : Node3D;

@onready var spawn_timer : Timer = $SpawnTimer;

# Ordonné par ordre décroissant de force
var monster_types : Array[Monster];

var wave_spawn_points : Array[WaveSpawnPoint];

class MonsterSpawn:
	var kind : Monster;
	var spawn_point : WaveSpawnPoint;
	var after_time : float;
	
	func _init(monster : Monster, at : WaveSpawnPoint, time : float) -> void:
		self.kind = monster;
		self.spawn_point = at;
		self.after_time = time;

var left_to_spawn : Array[MonsterSpawn] = [];
var ennemies_spawned : Array[Monster] = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_wave_strength = initial_wave_strength;
	for candidate in instantiatable_monsters:
		var monster : Monster = candidate.instantiate();
		monster.default_target = default_monster_target;
		assert(monster is Monster, "PackedScene n'a pas le type Monster !");
		monster_types.append(monster);
		
	monster_types.sort_custom(func (m1 : Monster, m2 : Monster): return m1.strength > m2.strength);
	spawn_timer.timeout.connect(spawn_next_enemy, CONNECT_PERSIST);
	DayNightSystem.on_day_start.connect(generate_waves);
	DayNightSystem.on_night_start.connect(start_waves);

func spawn_interval_after(monster : Monster) -> float:
	# Plus le monstre est fort, plus on veut de délai après son spawn
	return log(monster.strength + 1);

func generate_waves() -> void:
	var wave_strength_left := current_wave_strength;
	print("Wave strength : ", wave_strength_left);
	assert(len(wave_spawn_points) > 0, "Il faut au moins un point de spawn");
	assert(len(monster_types) > 0, "Il faut au moins un monstre à faire apparaître");
	while wave_strength_left > 0:
		var first_valid := monster_types.find_custom(func (m : Monster):
			return m.strength < current_wave_strength;
		);
		var picked_monster : Monster = monster_types.slice(first_valid).pick_random();
		
		var spawn_point : WaveSpawnPoint = wave_spawn_points.pick_random();
		var spawn_interval := spawn_interval_after(picked_monster);
		
		left_to_spawn.push_front(MonsterSpawn.new(picked_monster, spawn_point, spawn_interval));
		
		wave_strength_left -= picked_monster.strength;
	current_wave_strength += wave_strengh_increment;
	
func spawn_next_enemy() -> void:
	var next_enemy : MonsterSpawn = left_to_spawn.pop_back();
	var in_tree := next_enemy.kind.duplicate();
	next_enemy.spawn_point.add_child(in_tree);
	in_tree.health_component.died.connect(monster_killed);
	print("Spawned enemy");
	
	ennemies_spawned.append(in_tree);
	
	if len(left_to_spawn) > 0:
		spawn_timer.start(left_to_spawn[0].after_time);

func monster_killed(health : HealthComponent) -> void:
	var monster : Monster = health.get_parent();
	ennemies_spawned.erase(monster);
	if ennemies_spawned.is_empty():
		DayNightSystem.start_day(Player.instance);
	
func start_waves() -> void:
	spawn_timer.start(time_before_wave_start);
