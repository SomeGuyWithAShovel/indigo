extends Node3D

@export var damage := 10
@export var shot_cd := 0.5
var cur_enemie: Array[Monster]
var target:Monster = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer:Timer = get_node("Timer")
	timer.wait_time = shot_cd;
	print("test")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Rentreer")
	if body is Monster:
		cur_enemie.append(body)
		var timer:Timer = get_node("Timer")
		print("Ajout !")
		if timer.is_stopped():
			timer.start();
	
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	var index = cur_enemie.find(body)
	if index != -1 :
		cur_enemie.remove_at(index)
		if cur_enemie.is_empty():
			var timer:Timer = get_node("Timer")
			timer.stop()
			
	pass # Replace with function body.


func shoot() -> void:
	
	target = getShortestMonster()
	if target == null:
		pass
	damage_Monster(target)
	pass

func getShortestMonster() -> Monster:
	var cur_monster:Monster = null;
	var best_distance = INF
	var turret_postion = position
	for monster in cur_enemie:
		#division en plusieur variable pour clarete du code
		var cur_Xdistance = (monster.position.x-turret_postion.x)**2 
		var cur_Ydistance = (monster.position.y-turret_postion.y)**2 
		var cur_Zdistance = (monster.position.z-turret_postion.z)**2
		var cur_distance = cur_Xdistance + cur_Ydistance + cur_Zdistance
		if cur_distance<best_distance:
			cur_monster = monster
			best_distance = cur_distance
	return cur_monster
	
	

func damage_Monster(monster: Monster)-> void:
	monster.health_component.hurt(damage)
	pass


func _on_timer_timeout() -> void:
	shoot()
	pass # Replace with function body.


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	print("Rentreer area")
	_on_area_3d_body_entered(area)
	pass # Replace with function body.


func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	print("Sortie area")
	_on_area_3d_body_exited(area)
	pass # Replace with function body.
