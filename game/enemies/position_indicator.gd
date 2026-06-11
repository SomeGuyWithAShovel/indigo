extends Control
class_name PositionIndicator

@onready var viewport_texture : TextureRect = $Monster;
@onready var timer : Timer = $Timer;
@onready var encompassing_texture : TextureRect = $Indicator;
var world_camera : Camera3D
var follow : Monster = null :
	get:
		return follow;
	set(value):
		follow = value;
		setup_indicator();
		
# Non utilisé pour l'instant
var other_indicators : Array[PositionIndicator];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(world_camera != null, "Main camera not assigned by wave generator");
	timer.timeout.connect(update_position);

func setup_indicator() -> void:
	if follow != null:
		timer.start();
		viewport_texture.texture = follow.viewport.get_texture();
		follow.health_component.died.connect(remove_indicator);
		update_position();
		
func remove_indicator(_from : HealthComponent) -> void:
	queue_free();

func update_position() -> void:
	if follow == null: return;
	
	var half_size : Vector2 = (encompassing_texture.size / 2.0)*scale;
	var pos_on_camera : Vector2 = world_camera.unproject_position(follow.global_position);
	var own_position := pos_on_camera.clamp(half_size, get_viewport_rect().end - half_size);
	global_position = own_position;

func _on_other_indicator_entered(area: Area2D) -> void:
	assert(area.get_parent() is PositionIndicator);
	other_indicators.append(area.get_parent());

func _on_other_indicator_exited(area: Area2D) -> void:
	assert(area.get_parent() is PositionIndicator);
	other_indicators.erase(area.get_parent());
