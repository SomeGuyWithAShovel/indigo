extends Turret
class_name Classic_Turret

@export var laser_timer: Timer = null;
@export var laser: Node3D = null;

func _enter_tree() -> void :
	assert(laser_timer != null);
	assert(laser != null);
	return;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (target != null):
		var direction = target.global_position - $SpawnPoint.global_position
		look_at($SpawnPoint.global_position + direction)
		rotation.x = 0;
		rotation.z = 0;
		pass;
	return;

func shoot() -> void:
	super.shoot()

func _on_shoot(_origin: Vector3, _direction: Vector3) -> void :
	laser.visible = true;
	laser_timer.start();
	return;


func _on_laser_timer_timeout() -> void:
	laser.visible = false;
	return;
