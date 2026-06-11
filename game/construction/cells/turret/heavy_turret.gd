extends Turret
class_name Heavy_Turret

func shoot() -> void:
	super.shoot()
	if (target != null):
		var direction = target.global_position - $SpawnPoint.global_position
		look_at($SpawnPoint.global_position + direction)
		rotation.x = 0
		rotation.z = 0
