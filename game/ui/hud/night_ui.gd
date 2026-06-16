extends Control

@onready var health : BarContainer = $LeftPanel/HealthContainer;
@onready var quota : BarContainer = $LeftPanel/QuotaContainer;
@onready var crystal_label : Label = $LeftPanel/CrystalContainer/Amount;

func _ready() -> void:
	setup_events.call_deferred();
	init_values.call_deferred();
func setup_events() -> void:
	Globals.player.character.health.health_changed.connect(func (h : HealthComponent, hp : int):
		health.set_progress(hp , h.max_health);
	);
	DayNightSystem.quota_changed.connect(func (max_quota : int):
		quota.set_progress(0, max_quota);	
	);
	DayNightSystem.spent_on_quota_changed.connect(func (curr : int, max_quota : int):
		quota.set_progress(curr, max_quota);	
	);
	Globals.player.crystals.amount_changed.connect(func (new_amount : int, _ignore):
		set_crystal_count(new_amount);
	);
	
func init_values() -> void:
	var player_health := Globals.player.character.health;
	health.set_progress(player_health.get_health(), player_health.max_health);
	quota.set_progress(DayNightSystem.spent_on_quota, DayNightSystem.quota);
	set_crystal_count(Globals.player.crystals.get_amount());

func set_crystal_count(value : int) -> void:
	crystal_label.text = str(value);
