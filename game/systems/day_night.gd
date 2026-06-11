extends Node
class_name DayNight;

# Vaut le nombre de nuit passées (incrémenté au début du jour)
var night_number : int = 0;

signal on_day_start();
signal on_night_start();

@export var start_with_day : bool = true;
var is_day := true :
	get:
		return is_day;
	set(value):
		# Si on emet 2 fois les évenements il peut y avoir des soucis dans WaveGenerator
		if value == is_day: 
			return; 		
		is_day = value;
		if is_day:
			on_day_start.emit();
		else:
			on_night_start.emit();
			
@export_group("Quotas")
# Pour l'instant, le quota suit une fonction affine
@export var first_quota : int = 20;
@export var quota_increment : int = 10;
@export var days_before_pay_up : int = 3;
@export var amount_per_fill : int = 1;

@export_group("Action points")
@export var action_points_per_day : int = 100;

signal spent_on_quota_changed(current : int, required : int);
signal quota_changed(required : int);
signal no_crystals_for_pay();
signal no_requestable_crystals_in_quota();
signal days_left_for_quota_changed(days_left : int);

var spent_on_quota : int = 0: 
	get :
		return spent_on_quota;
	set(value): 
		spent_on_quota = value;
		spent_on_quota_changed.emit(spent_on_quota, quota);

var quota : int = 0:
	get:
		return quota;
	set(value):
		quota = value;
		quota_changed.emit(quota);
		
var days_left_for_quota : int = 0:
	get:
		return days_left_for_quota;
	set(value):
		days_left_for_quota = value;
		days_left_for_quota_changed.emit(days_left_for_quota);


func _ready() -> void:
	quota = first_quota;
	days_left_for_quota = days_before_pay_up;
	setup_day_night.call_deferred();
	get_tree().scene_changed.connect(_ready, CONNECT_ONE_SHOT);

func spend_on_quota() -> void:
	var crystal_amount := Globals.player.crystals.get_amount();
	if crystal_amount > 0:
		var can_pay = min(amount_per_fill, crystal_amount);
		var pay_amount = min(quota - spent_on_quota, can_pay);
		Globals.player.crystals.remove(pay_amount);
		spent_on_quota += pay_amount;
	else:
		no_crystals_for_pay.emit();

func take_from_quota() -> void:
	if spent_on_quota > 0:
		var can_receive = min(amount_per_fill, spent_on_quota);
		spent_on_quota -= can_receive;
		Globals.player.crystals.add(can_receive);
	else:
		no_requestable_crystals_in_quota.emit();

func setup_day_night() -> void:
	if not Globals.is_setup: await Globals.globals_setup;
	if start_with_day:
		# Un peu moche, c'est accordé
		days_left_for_quota += 1;
		start_day(Globals.player);
	else:
		start_night(Globals.player);

func next_quota() -> bool:
	if spent_on_quota == quota:
		days_left_for_quota = days_before_pay_up;
		spent_on_quota = 0;
		quota += quota_increment;
		return true;
	else:
		# player.crystals.override_amount(0); # I commented that because otherwise we start at 0 crystals, no matter what the resource in the player scene is initialized to. We might want to uncomment it again.
		GameOverSystem.end_game(GameOver.Reason.QUOTA_NOT_MET);
		return false;
	
func start_day(player : Player) -> void:
	days_left_for_quota -= 1
	if days_left_for_quota <= 0:
		if not next_quota(): 
			return;
	is_day = true;
	player.action_points.override_amount(action_points_per_day);
	print("Day start");
	
func start_night(player : Player) -> void:
	is_day = false;
	const INT_MAX = 9223372036854775807;
	player.action_points.override_amount(INT_MAX);
	print("Night start");
