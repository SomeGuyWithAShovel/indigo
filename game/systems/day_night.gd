extends Node
class_name DayNight;

# Vaut le nombre de nuit passées (incrémenté au début du jour)
var night_number : int = 0;

signal on_day_start();
signal on_night_start();

@export var start_with_day : bool = true;

@export_group("Quotas")
# Pour l'instant, le quota suit une fonction affine
@export var first_quota : int = 200;
@export var quota_increment : int = 100;
@export var days_before_pay_up : int = 3;

@export_group("Action points")
@export var action_points_per_day : int = 100;

signal quota_changed(current : int, required : int);

var quota_amount : int = 0: 
	get :
		return quota_amount;
	set(value): 
		quota_amount = value;
		quota_changed.emit(quota_amount, crystal_quota);

var crystal_quota : int;
var day_since_last_pay_up : int = 0;


func _ready() -> void:
	crystal_quota = first_quota;
	setup_day_night.call_deferred();

func fill_quota() -> void:
	var crystal_amount := Player.instance.crystals.get_amount();
	var pay_amount = max(crystal_quota - quota_amount, crystal_amount);
	Player.instance.crystals.remove(pay_amount);
	quota_amount += pay_amount;

func setup_day_night() -> void:
	if start_with_day:
		start_day(Player.instance);
	else:
		start_night();

func next_quota(player : Player) -> int:
	if quota_amount == crystal_quota:
		day_since_last_pay_up = 0;
	else:
		player.crystals.override_amount(0);
		GameOverSystem.end_game(GameOver.Reason.QUOTA_NOT_MET);
	return crystal_quota;
	
func start_day(player : Player) -> void:
	night_number += 1;
	if day_since_last_pay_up < days_before_pay_up:
		next_quota(player);
	player.action_points.override_amount(action_points_per_day);
	on_day_start.emit();
	print("Day start");
	
func start_night() -> void:
	on_night_start.emit();
	print("Night start");
