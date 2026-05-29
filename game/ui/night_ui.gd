extends Control

@onready var health_bar : TextureProgressBar = $LeftPanel/HealthContainer/ProgressBar;
@onready var quota_bar : TextureProgressBar = $LeftPanel/QuotaContainer/ProgressBar;
@onready var crystal_label : Label = $LeftPanel/CrystalContainer/Amount;

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
	Player.instance.crystals.amount_changed.connect(func (new_amount : int, _ignore):
		set_crystal_count(new_amount);
	);
	
func init_values() -> void:
	var player_health := Player.instance.character.health;
	set_health_progress(float(player_health.get_health()) / player_health.max_health);
	set_quota_progress(float(DayNightSystem.quota_amount) / DayNightSystem.crystal_quota);
	set_crystal_count(Player.instance.crystals.get_amount());

func set_health_progress(percent : float) -> void:
	health_bar.value = percent;
	
func set_quota_progress(percent : float) -> void:
	quota_bar.value = percent;

func set_crystal_count(value : int) -> void:
	crystal_label.text = str(value);
