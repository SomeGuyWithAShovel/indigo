class_name HealthComponent
extends Node

@export var max_health : int;
@export var invincibility_duration : float;

var invincibility_timer : Timer;

# On renvoie HealthComponent si jamais on veut récupérer son parent
signal died(from : HealthComponent); # On pourra rajouter des paramètres si besoin
signal invincibility_started(from : HealthComponent);
signal invincibility_ended(from : HealthComponent);

var _current_health: int:
	get:
		return _current_health;
	set(value):
		_current_health = value;
		if _current_health < 0:
			died.emit(self);

func _ready() -> void:
	_current_health = max_health;
	invincibility_timer = Timer.new();
	invincibility_timer.timeout.connect(func(): invincibility_ended.emit(self));
	
func hurt(damage) -> void:
	if invincibility_timer.is_stopped():
		_current_health -= damage;
		invincibility_timer.start(invincibility_duration);
		invincibility_started.emit(self);
