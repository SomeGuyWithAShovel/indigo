extends PlayerBaseCell
class_name Turret

signal on_shoot(origin: Vector3, direction: Vector3);

@export var damage := 10
@export var shot_cd := 0.5
@export var projectile_scene:PackedScene
var cur_enemie: Array[Monster]
var target:Monster = null
var turretlist: Array[String] = [
	"res://game/module/heavy_turret.tscn",
	"res://game/module/classic_turret.tscn"
]

enum turret_type {
	HEAVY = 0,
	SMALL = 1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer:Timer = get_node("Timer")
	timer.wait_time = shot_cd;
	
	pass # Replace with function body.

func _on_area_3d_body_entered(body: Node3D) -> void:
	var monster = body.owner;
	if monster is Monster:
		cur_enemie.append(monster)
		var timer:Timer = get_node("Timer")
		if timer.is_stopped():
			timer.start();
	
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	var index = cur_enemie.find(body.owner)
	if index != -1 :
		cur_enemie.remove_at(index)
		if cur_enemie.is_empty():
			var timer:Timer = get_node("Timer")
			timer.stop()
			
	pass # Replace with function body.


func shoot() -> void:
	target = getShortestMonster()
	if target == null:
		return
	#si on a un prjectil (pas de type de tour avec plusieur projectile
	
	var origin: Vector3 = global_position + $SpawnPoint.position;
	var direction: Vector3 = (target.global_position - (global_position + $SpawnPoint.position)).normalized();
	if projectile_scene != null:
		var projectile: Projectile = projectile_scene.instantiate();
		self.add_child(projectile);
		projectile.owner = self;
		
		projectile.global_position = origin;
		projectile.direction = direction;
		get_parent().add_child(projectile)
		return
	
	on_shoot.emit(origin, direction);
	
	damage_Monster(target)
	pass

func getShortestMonster() -> Monster:
	var cur_monster:Monster = null;
	var valid_monster:Array[Monster]
	var best_distance = INF
	var turret_postion = position
	for monster in cur_enemie:
		if is_instance_valid(monster):
			
			#division en plusieur variable pour clarete du code
			var cur_Xdistance = (monster.character.position.x-turret_postion.x)**2 
			var cur_Ydistance = (monster.character.position.y-turret_postion.y)**2 
			var cur_Zdistance = (monster.character.position.z-turret_postion.z)**2
			var cur_distance = cur_Xdistance + cur_Ydistance + cur_Zdistance
			if cur_distance<best_distance:
				cur_monster = monster
				best_distance = cur_distance
			valid_monster.append(monster)
	cur_enemie = valid_monster
	if cur_enemie.is_empty():
		$Timer.stop()
	else:
		print("Pas empty")
	return cur_monster
	
	

func damage_Monster(monster: Monster)-> void:
	monster.health_component.hurt(damage)
	pass


func _on_timer_timeout() -> void:
	shoot()
	pass # Replace with function body.

func getTurretScene(type:turret_type) -> PackedScene:
	return load(turretlist[type])
