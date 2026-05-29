extends Control

@onready var health_bar : TextureProgressBar = $LeftPanel/HealthContainer/ProgressBar;
@onready var quota_bar : TextureProgressBar = $LeftPanel/QuotaContainer/ProgressBar;
@onready var crystal_label : Label = $LeftPanel/CrystalContainer/Amount;
@onready var action_point_bar : TextureProgressBar = $RightPanel/RightPanel/ProgressBar;

func _ready() -> void:
	setup_events.call_deferred();
	init_values.call_deferred();
func setup_events() -> void:
	Player.instance.character.health.health_changed.connect(func (h : HealthComponent, hp : int):
		set_health_progress(float(hp) / h.max_health);
	);
	DayNightSystem.quota_changed.connect(func (curr : int, quota : int):
		set_quota_progress(float(curr) / quota);	
	);
	Player.instance.resources.crystals.amount_changed.connect(func (new_amount : int, _ignore):
		set_crystal_count(new_amount);
	);
	Player.instance.resources.action_points.amount_changed.connect(func (new_amount : int, _ignore):
		var max_action_points = DayNightSystem.action_points_per_day;
		set_action_point_progress(float(new_amount)/max_action_points)	
	);
	
func init_values() -> void:
	var player_health := Player.instance.character.health;
	set_health_progress(float(player_health.get_health()) / player_health.max_health);
	set_quota_progress(float(DayNightSystem.quota_amount) / DayNightSystem.crystal_quota);
	set_crystal_count(Player.instance.resources.crystals.get_amount());
	set_action_point_progress(float(Player.instance.resources.action_points.get_amount()) / DayNightSystem.action_points_per_day);

func set_health_progress(percent : float) -> void:
	health_bar.value = percent;
	
func set_quota_progress(percent : float) -> void:
	quota_bar.value = percent;

func set_crystal_count(value : int) -> void:
	crystal_label.text = str(value);

func set_action_point_progress(percent : float) -> void:
	action_point_bar.value = 1.0 - percent;

const confirmation_box = preload("res://game/ui/confirmation.tscn");
func _on_night_requested() -> void:
	var ap_amount := Player.instance.resources.action_points.get_amount();
	if ap_amount > 0:
		var box : Confirmation = confirmation_box.instantiate();
		add_child(box);
		box.set_text("%d actions points remaining. Start night anyway ?" % ap_amount);
		var should_start := await box.is_yes();
		if should_start:
			DayNightSystem.start_night();
		else:
			remove_child(box);
			box.queue_free();
	else:
		DayNightSystem.start_night();
