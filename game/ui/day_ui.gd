extends Control

@onready var health : BarContainer = $LeftPanel/HealthContainer;
@onready var quota : BarContainer = $LeftPanel/QuotaContainer;
@onready var crystal_label : Label = $LeftPanel/CrystalContainer/Amount;
@onready var action_point: BarContainer = $RightPanel/ActionPointsContainer;

func _ready() -> void:
	setup_events.call_deferred();
	init_values.call_deferred();
func setup_events() -> void:
	Player.instance.character.health.health_changed.connect(func (h : HealthComponent, hp : int):
		health.set_progress(hp , h.max_health);
	);
	DayNightSystem.quota_changed.connect(func (max_quota : int):
		quota.set_progress(0, max_quota);	
	);
	DayNightSystem.crystals_spent_on_quota.connect(func (curr : int, max_quota : int):
		quota.set_progress(curr, max_quota);	
	);
	Player.instance.crystals.amount_changed.connect(func (new_amount : int, _ignore):
		set_crystal_count(new_amount);
	);
	Player.instance.action_points.amount_changed.connect(func (new_amount : int, _ignore):
		var max_action_points = DayNightSystem.action_points_per_day;
		action_point.set_progress(new_amount, max_action_points);	
	);
	
func init_values() -> void:
	var player_health := Player.instance.character.health;
	health.set_progress(player_health.get_health(), player_health.max_health);
	quota.set_progress(DayNightSystem.spent_on_quota, DayNightSystem.crystal_quota);
	set_crystal_count(Player.instance.crystals.get_amount());
	action_point.set_progress(Player.instance.action_points.get_amount(), DayNightSystem.action_points_per_day);

func set_crystal_count(value : int) -> void:
	crystal_label.text = str(value);

const confirmation_box = preload("res://game/ui/confirmation.tscn");
func _on_night_requested() -> void:
	(get_parent() as UIManager).close_building_menu();
	var ap_amount := Player.instance.action_points.get_amount();
	if ap_amount > 0:
		var box : Confirmation = confirmation_box.instantiate();
		add_child(box);
		box.set_text("%d actions points remaining. Start night anyway ?" % ap_amount);
		var should_start := await box.is_yes();
		if should_start:
			DayNightSystem.start_night();
		remove_child(box);
		box.queue_free();
	else:
		DayNightSystem.start_night();
