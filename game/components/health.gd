class_name HealthComponent
extends Node

@export var max_health : int;
@export var invincibility_duration : float;

var invincibility_timer : Timer;

# On renvoie HealthComponent si jamais on veut récupérer son parent
signal health_changed(from : HealthComponent, new_hp: int);
signal died(from : HealthComponent); # On pourra rajouter des paramètres si besoin
signal invincibility_started(from : HealthComponent);
signal invincibility_ended(from : HealthComponent);

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
		return;

func get_health() -> int:
	return _current_health;

func _ready() -> void:
	invincibility_timer = Timer.new();
	invincibility_timer.one_shot = true;
	add_child(invincibility_timer);
	invincibility_timer.timeout.connect(func(): invincibility_ended.emit(self));
	reset();

func reset() -> void:
	_current_health = max_health;
	invincibility_timer.start(invincibility_duration);
	invincibility_started.emit(self);
	
func hurt(damage) -> void:
	if abs(invincibility_timer.time_left) < 1e-5:
		_current_health -= damage;
		invincibility_timer.start(invincibility_duration);
		invincibility_started.emit(self);
