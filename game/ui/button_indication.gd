extends Control
class_name ButtonIndication

var key : Key :
	get:
		return key;
	set(value):
		key = value;
		if atlas != null:
			var top_left := top_left_in_atlas(key);
			atlas.region.position = top_left as Vector2;
		
@onready var button_icon : TextureRect = $Button;
var action : Interactible.Action :
	get:
		return action;
	set(value):
		action = value;
		action_icon.texture = action_icons[value];

@onready var action_icon : TextureRect = $Action;

@export var action_icons : Dictionary[Interactible.Action, CompressedTexture2D] = {}

var atlas : AtlasTexture;

const SQUARE_PIXEL_SIZE := 64;

static var pos : Dictionary[Key, Vector2i] = {
	KEY_E: Vector2i(5, 10),
	KEY_A: Vector2i(4, 14)
}

func _ready() -> void:
	atlas = button_icon.texture as AtlasTexture;
	assert(atlas != null);
	
func top_left_in_atlas(k : Key) -> Vector2i:
	assert(k in pos, "Cette clé n'est pas dans le dictionnaire");
	return SQUARE_PIXEL_SIZE*pos[k];
