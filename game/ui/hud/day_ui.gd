extends Control

@onready var health : BarContainer = $LeftPanel/HealthContainer;
@onready var quota : BarContainer = $LeftPanel/QuotaContainer;
@onready var crystal_label : Label = $LeftPanel/CrystalContainer/Amount;
@onready var action_point: BarContainer = $RightPanel/ActionPointsContainer;
@onready var building_indication : Label = $VBoxContainer/BuildingMenuKey;
@onready var movement_indication : HBoxContainer = $VBoxContainer/HBoxContainer;

@onready var w_icon = $VBoxContainer/HBoxContainer/W;
@onready var a_icon = $VBoxContainer/HBoxContainer/A;
@onready var s_icon = $VBoxContainer/HBoxContainer/S;
@onready var d_icon = $VBoxContainer/HBoxContainer/D;

func _ready() -> void:
	setup_events();
	init_values();
	init_wasd();
	
func setup_events() -> void:
	if not Globals.is_setup: await Globals.globals_setup;
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
	Globals.player.action_points.amount_changed.connect(func (new_amount : int, _ignore):
		var max_action_points = DayNightSystem.action_points_per_day;
		action_point.set_progress(new_amount, max_action_points);	
	);
	
func init_values() -> void:
	if not Globals.is_setup: await Globals.globals_setup;
	var player_health : HealthComponent = Globals.player.character.health;
	health.set_progress(player_health.get_health(), player_health.max_health);
	quota.set_progress(DayNightSystem.spent_on_quota, DayNightSystem.quota);
	set_crystal_count(Globals.player.crystals.get_amount());
	action_point.set_progress(Globals.player.action_points.get_amount(), DayNightSystem.action_points_per_day);

func _unhandled_input(event: InputEvent) -> void:
	if building_indication == null: return;
	if building_indication != null and event is InputEventKey and event.keycode == KEY_SPACE:
		building_indication.queue_free();
	elif movement_indication != null and (
		Input.is_action_pressed("move_left") or 
		Input.is_action_pressed("move_right") or 
		Input.is_action_pressed("move_forwards") or
		Input.is_action_pressed("move_backwards")):
			movement_indication.queue_free();

func set_crystal_count(value : int) -> void:
	crystal_label.text = str(value);

var is_confirmation_box_opened := false;
const confirmation_box = preload("res://game/ui/confirmation.tscn");
func _on_night_requested() -> void:
	# Pas de spam
	if is_confirmation_box_opened: return;
	
	var ap_amount : int = Globals.player.action_points.get_amount();
	if ap_amount > 0:
		var box : Confirmation = confirmation_box.instantiate();
		var ui_manager := get_parent() as UIManager;
		add_child(box);
		is_confirmation_box_opened = true;
		box.set_text("%d actions points remaining. Start night anyway ?" % ap_amount);
		var should_start := await box.is_yes();
		if should_start:
			DayNightSystem.start_night(Globals.player);
		else:
			ui_manager.can_open_building_menu = true;
		remove_child(box);
		is_confirmation_box_opened = false;
		box.queue_free();
	else:
		DayNightSystem.start_night(Globals.player);


func _on_night_request_down() -> void:
	var ui_manager := get_parent() as UIManager;
	ui_manager.close_building_menu();
	ui_manager.can_open_building_menu = false;


func init_wasd() -> void:
	for icon in [w_icon, a_icon, s_icon, d_icon]:
		var key_code := ord(icon.name) as Key;
		var atlas := (icon.texture as AtlasTexture);
		assert(atlas);
		assert(key_code in ButtonIndication.pos);
		atlas.region.position = ButtonIndication.top_left_in_atlas(key_code) as Vector2;
	
