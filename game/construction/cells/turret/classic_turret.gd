extends Turret
class_name Classic_Turret

@export var laser_timer: Timer = null;
@export var laser: Node3D = null;
@export var laser_sound: AudioStreamPlayer3D = null;

func _enter_tree() -> void :
	super._enter_tree(); # not called automatically by Godot
	
	assert(laser_timer != null);
	# automatically sets the duration while the laser is seen, 
	# proportionnaly linked to the duration between 2 shots of the turret
	laser_timer.wait_time = shoot_timer.wait_time * 0.3;
	
	assert(laser != null);
	assert(laser_sound != null);
	return;

func node_look_at(node: Node3D, node_target: Vector3) -> void :
	node.look_at(node_target);
	node.rotation.x = 0;
	node.rotation.z = 0;
	return;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (target != null):
		node_look_at(self, target.global_position);
		pass;
	return;

func shoot() -> void:
	super.shoot()

func _on_shoot(_origin: Vector3, _direction: Vector3) -> void :
	_direction.y = 0;
	laser.global_position = _origin;
	node_look_at(self, _origin + _direction);
	laser_sound.play();
	
	laser.visible = true;
	laser_timer.start();
	return;


func _on_laser_timer_timeout() -> void :
	laser.visible = false;
	return;
