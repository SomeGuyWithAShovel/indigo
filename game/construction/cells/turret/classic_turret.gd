extends Turret
class_name Classic_Turret

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot() -> void:
	super.shoot()
	if (target != null):
		var direction = target.global_position - $SpawnPoint.global_position
		look_at($SpawnPoint.global_position + direction)
		rotation.x = 0
		rotation.z = 0
