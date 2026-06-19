extends Turret
class_name Heavy_Turret

func _enter_tree() -> void:
	super._enter_tree()
	building_type = cell_type.MISSILE_LAUNCHER

func shoot() -> void:
	super.shoot()
	if (target != null):
		var direction = target.global_position - $SpawnPoint.global_position
		look_at($SpawnPoint.global_position + direction)
		rotation.x = 0
		rotation.z = 0
