extends Node
class_name DayNight;

# Vaut le nombre de nuit passées (incrémenté au début du jour)
var night_number : int = 0;

signal on_day_start();
signal on_night_start();

@export var start_with_day : bool = true;

@export_group("Quotas")
# Pour l'instant, le quota suit une fonction affine
@export var first_quota : int = 20;
@export var quota_increment : int = 10;
@export var days_before_pay_up : int = 3;
@export var amount_per_fill : int = 1;

@export_group("Action points")
@export var action_points_per_day : int = 100;

signal crystals_spent_on_quota(current : int, required : int);
signal quota_changed(required : int);
signal no_crystals_for_pay();

var spent_on_quota : int = 0: 
	get :
		return spent_on_quota;
	set(value): 
		spent_on_quota = value;
		crystals_spent_on_quota.emit(spent_on_quota, crystal_quota);

var crystal_quota : int = 0:
	get:
		return crystal_quota;
	set(value):
		crystal_quota = value;
		quota_changed.emit(crystal_quota);
var day_since_last_pay_up : int = 0;


func _ready() -> void:
	crystal_quota = first_quota;
	setup_day_night.call_deferred();

func spend_on_quota() -> void:
	var crystal_amount := Player.instance.crystals.get_amount();
	if crystal_amount > 0:
		var can_pay = min(amount_per_fill, crystal_amount);
		var pay_amount = min(crystal_quota - spent_on_quota, can_pay);
		Player.instance.crystals.remove(pay_amount);
		spent_on_quota += pay_amount;
	else:
		no_crystals_for_pay.emit();

func setup_day_night() -> void:
	if start_with_day:
		start_day(Player.instance);
	else:
		start_night();

func next_quota(player : Player) -> int:
	if spent_on_quota == crystal_quota:
		day_since_last_pay_up = 0;
		spent_on_quota = 0;
		crystal_quota += quota_increment;
	else:
		# player.crystals.override_amount(0); # I commented that because otherwise we start at 0 crystals, no matter what the resource in the player scene is initialized to. We might want to uncomment it again.
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
