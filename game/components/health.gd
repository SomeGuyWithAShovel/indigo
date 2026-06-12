class_name HealthComponent
extends Node3D

@export_group("Health parameters")
@export var max_health : int = 100;
@export_group("Health bar")
@export var health_bar_color : Color = Color.DARK_RED;
@export var has_health_bar := true;

@onready var bar : TextureProgressBar = $BarParent/TextureProgressBar
@onready var bar_parent : Control = $BarParent;

var camera : Camera3D;

# On renvoie HealthComponent si jamais on veut récupérer son parent
signal health_changed(from : HealthComponent, new_hp: int);
signal died(from : HealthComponent); # On pourra rajouter des paramètres si besoin

signal on_damaged(new_hp: int, old_hp: int); # I didn't want to update already existing signals, so I created my own.
# Because there weren't any way to know when we are damaged (health_changed doesn't tell what was the previous health so we can't compare)

var _current_health: int :
	get:
		return _current_health;
	set(value):
		if (value < _current_health) :
			on_damaged.emit(value, _current_health);
			pass;
		_current_health = value;
		health_changed.emit(self, _current_health);
		if _current_health <= 0:
			died.emit(self);
			pass;
		elif has_health_bar:
			update_bar_value();
		return;

func _ready() -> void:
	if has_health_bar:
		bar.max_value = max_health;
		bar.tint_progress = health_bar_color;
	else:
		remove_child(bar_parent);
		bar_parent.queue_free();
		bar_parent = null;
		bar = null;
		set_process(false);
	camera = get_viewport().get_camera_3d();
	assert(camera != null);
	
	reset();

func get_health() -> int:
	return _current_health;

func reset() -> void:
	_current_health = max_health;
	
func _process(_delta: float) -> void:
	var screen_pos = camera.unproject_position(global_position);
	bar_parent.global_position = screen_pos;
	var distance_to_cam = global_position.distance_to(camera.global_position);
	bar.scale = Vector2.ONE * clamp(1.0 - distance_to_cam/10.0, 0.1, 1.0);
	
func update_bar_value() -> void:
	bar.visible = _current_health < max_health;
	bar.value = _current_health;
	
func hurt(damage) -> void:
	_current_health -= damage;
