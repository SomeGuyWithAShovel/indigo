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

@export_group("Indicator management")
@export var indicator_scene : PackedScene;

@export_group("Dependencies")
@export var nav : NavMesh;

@onready var spawn_timer : Timer = $SpawnTimer;
@onready var check_distance_timer : Timer = $CheckDistanceTimer;

# Ordonné par ordre décroissant de force
var monster_types : Array[Monster];
var wave_spawn_points : Array[WaveSpawnPoint];

var camera : Camera3D;

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
var indicators : Dictionary[Monster, PositionIndicator] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_wave_strength = initial_wave_strength;
	for candidate in instantiatable_monsters:
		var monster : Monster = candidate.instantiate();
		monster.default_target = default_monster_target;
		assert(monster is Monster, "PackedScene n'a pas le type Monster !");
		monster_types.append(monster);
		
	monster_types.sort_custom(func (m1 : Monster, m2 : Monster): return m1.strength > m2.strength);
	spawn_timer.timeout.connect(spawn_next_enemy);
	check_distance_timer.timeout.connect(handle_indicators);
	DayNightSystem.on_day_start.connect(generate_waves);
	DayNightSystem.on_night_start.connect(start_waves);
	DayNightSystem.on_day_start.connect(stop_distance_timer);
	DayNightSystem.on_night_start.connect(start_distance_timer);
	camera = get_viewport().get_camera_3d();
	assert(camera != null, "Wave generator n'a pas de caméra à sa disposition");
	generate_waves();

func start_distance_timer() -> void : check_distance_timer.start();
func stop_distance_timer() -> void : check_distance_timer.stop();

func spawn_interval_after(monster : Monster) -> float:
	# Plus le monstre est fort, plus on veut de délai après son spawn
	return log(monster.strength + 1);

func generate_waves() -> void:
	
	if not left_to_spawn.is_empty(): return;
	
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
	# On ne veut pas qu'un ennemi ait un mauvais pathfinding
	# Donc, on attend la fin du calcul de la navmesh
	if not nav.calc_finished:
		await nav.nav_region.bake_finished;
	var next_enemy : MonsterSpawn = left_to_spawn.pop_back();
	var in_tree := next_enemy.kind.duplicate();
	next_enemy.spawn_point.add_child(in_tree);
	in_tree.health_component.died.connect(monster_killed);
	
	ennemies_spawned.append(in_tree);
	handle_indicators();
		
	if len(left_to_spawn) > 0:
		spawn_timer.start(left_to_spawn[0].after_time);

func monster_killed(health : HealthComponent) -> void:
	var monster : Monster = health.get_parent();
	ennemies_spawned.erase(monster);
	indicators.erase(monster);
	if ennemies_spawned.is_empty():
		DayNightSystem.start_day(Globals.player);
	
func start_waves() -> void:
	spawn_timer.start(time_before_wave_start);
	
func handle_indicators() -> void:
	for monster in ennemies_spawned:
		var screen_pos = camera.unproject_position(monster.global_position);
		var on_screen := get_viewport().get_visible_rect().has_point(screen_pos);
		if monster in indicators and on_screen:
			UIManager.instance.remove_child(indicators[monster]);
			indicators[monster].queue_free();
			indicators.erase(monster);
		elif monster not in indicators and not on_screen:
			var indicator : PositionIndicator = indicator_scene.instantiate();
			indicator.world_camera = camera;
			indicators[monster] = indicator;
			UIManager.instance.add_child(indicator);
			indicator.follow = monster;	
