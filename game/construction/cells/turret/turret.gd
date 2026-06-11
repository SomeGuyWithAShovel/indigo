extends PlayerBaseCell
class_name Turret

signal on_shoot(origin: Vector3, direction: Vector3);

@export var damage := 10
@export var shot_cd := 0.5
@export var projectile_scene: PackedScene = null;

@export var spawn_point: Node3D = null;
@export var shoot_timer: Timer = null;

func _enter_tree() -> void :
	assert(spawn_point != null);
	
	assert(shoot_timer != null);
	shoot_timer.wait_time = shot_cd;
	print("shot_cd = ", shoot_timer.wait_time);
	return;


var turretlist: Array[String] = [
	"res://game/module/heavy_turret.tscn",
	"res://game/module/classic_turret.tscn"
];

enum turret_type {
	HEAVY = 0,
	SMALL = 1
};

func getTurretScene(type: turret_type) -> PackedScene :
	return load(turretlist[type])



var cur_enemie: Array[Monster]
var target: Monster = null


func _on_area_3d_body_entered(body: Node3D) -> void :
	var monster: Monster = body.owner as Monster;
	if (monster == null) :
		return;
		
	cur_enemie.append(monster);
	if shoot_timer.is_stopped() :
		shoot_timer.start();
		pass;
	return;


func _on_area_3d_body_exited(body: Node3D) -> void :
	var monster: Monster = body.owner as Monster;
	if (monster == null) :
		return;
		
	var index = cur_enemie.find(monster);
	if index == -1 :
		return;
	
	cur_enemie.remove_at(index)
	if cur_enemie.is_empty() :
		shoot_timer.stop()
		pass;
	return;


func shoot() -> void:
	target = getShortestMonster();
	if (target == null):
		return;
	
	var origin: Vector3 = spawn_point.global_position;
	var direction: Vector3 = (target.global_position - origin).normalized();
	
	if (projectile_scene != null) :
		var projectile: Projectile = projectile_scene.instantiate();
		var projectile_parent: Node = get_parent();
		
		projectile_parent.add_child(projectile);
		projectile.owner = projectile_parent;
		
		projectile.global_position = origin;
		projectile.direction = direction;
		pass;
	
	on_shoot.emit(origin, direction);
	
	if (projectile_scene == null) :
		damage_Monster(target)
		pass;
	return;

func getShortestMonster() -> Monster:
	var curr_monster: Monster = null;
	var valid_monster: Array[Monster]
	var best_distance = INF
	var turret_postion = position
	for monster in cur_enemie:
		if is_instance_valid(monster):
			
			# division en plusieurs variables pour clareté du code
			var curr_Xdistance = (monster.character.position.x - turret_postion.x) ** 2;
			var curr_Ydistance = (monster.character.position.y - turret_postion.y) ** 2;
			var curr_Zdistance = (monster.character.position.z - turret_postion.z) ** 2;
			
			var curr_distance = curr_Xdistance + curr_Ydistance + curr_Zdistance
			if (curr_distance < best_distance) :
				curr_monster = monster;
				best_distance = curr_distance;
				pass;
			valid_monster.append(monster);
			pass;
		pass;
	
	cur_enemie = valid_monster;
	if cur_enemie.is_empty():
		shoot_timer.stop();
	else:
		# print("Pas empty")
		pass;
	return curr_monster;

func damage_Monster(monster: Monster)-> void:
	monster.health_component.hurt(damage);
	pass

func _on_timer_timeout() -> void:
	shoot();
	return;
