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
		assert(value != Interactible.Action.NONE);
		action = value;
		action_icon.texture = action_icons[value];

@onready var action_icon : TextureRect = $Action;

@export var action_icons : Dictionary[Interactible.Action, CompressedTexture2D] = {}

var atlas : AtlasTexture;

const SQUARE_PIXEL_SIZE := 64;

static var pos : Dictionary[Key, Vector2i] = {
	KEY_A: Vector2i(4, 14),
	KEY_D: Vector2i(1, 10),
	KEY_E: Vector2i(5, 10),
	KEY_R: Vector2i(15, 5),
	KEY_S: Vector2i(2, 4),
	KEY_Q: Vector2i(9, 5),
	KEY_W: Vector2i(2, 2),
	KEY_Z: Vector2i(10, 2),
}

func _ready() -> void:
	atlas = button_icon.texture as AtlasTexture;
	assert(atlas != null);
	
static func top_left_in_atlas(k : Key) -> Vector2i:
	var logical_key := DisplayServer.keyboard_get_keycode_from_physical(k)
	assert(k in pos, "Cette clé n'est pas dans le dictionnaire");
	return SQUARE_PIXEL_SIZE*pos[logical_key];
