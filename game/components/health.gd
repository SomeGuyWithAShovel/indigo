class_name HealthComponent
extends Node3D

@export_group("Health parameters")
@export var max_health : int = 100;
@export_group("Health bar")
@export var health_bar_color : Color = Color.DARK_RED;
@export var has_health_bar := true;

@onready var bar : TextureProgressBar = $BarParent/TextureProgressBar
@onready var bar_parent : Control = $BarParent;

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
	reset();
	if has_health_bar:
		bar.max_value = max_health;
		bar.tint_progress = health_bar_color;
		health_changed.connect(animate_bar);
	else:
		var unprojector = $Unprojector;
		remove_child(bar_parent);
		remove_child(unprojector);
		bar_parent.queue_free();
		unprojector.queue_free();
		bar_parent = null;
		bar = null;
		set_process(false);

func get_health() -> int:
	return _current_health;

func reset() -> void:
	_current_health = max_health;
	
func update_bar_value() -> void:
	bar.visible = _current_health < max_health;
	bar.value = _current_health;
	
func hurt(damage) -> void:
	_current_health -= damage;
	
var tween : Tween = null;
const TWEEN_DURATION := 0.15;
const TWEEN_START_SCALE := Vector2(1.5, 1.5);
const TWEEN_START_COLOR := Color.RED;
func animate_bar(_from : HealthComponent, _new_hp: int) -> void:
	tween = create_tween();
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(bar_parent, "scale", Vector2.ONE, TWEEN_DURATION).from(TWEEN_START_SCALE);
	tween.tween_property(bar, "tint_progress", health_bar_color, TWEEN_DURATION).from(TWEEN_START_COLOR);
