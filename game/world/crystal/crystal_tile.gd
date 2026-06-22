class_name CrystalTile
extends Node3D

var camera : Camera3D;
var terrain: Terrain = null;
@export var player_collect_sound: AudioStreamPlayer = null;
@export var crystal_obtained_icon_scene : PackedScene;
var crystal_obtained_icon : CrystalObtainedIcon;

@export var crystal_amount_per_operation: int = 5;

@export var manual_multiplier: int = 2;
@export var action_points_per_interaction: int = 5;
signal on_being_manually_mined();

static var interaction_count := 0; # Pour éviter que le joueur génère des PA à partir de ses cristaux
var is_day := true;

var interactible : Interactible;

func _enter_tree() -> void :
	find_terrain_rec(self);
	assert(terrain != null);
	set_tile_as_crystals();
	
	assert(player_collect_sound != null);
	
	return;
	
func _ready() -> void:
	DayNightSystem.on_day_start.connect(day_started);
	DayNightSystem.on_night_start.connect(night_started);
	interactible = Interactible.new(Callable(self, &"interact"), Interactible.Action.MINE, Callable(self, &"uninteract"));
	
	crystal_obtained_icon = crystal_obtained_icon_scene.instantiate();
	camera = get_viewport().get_camera_3d();
	assert(camera != null);
	
func day_started() -> void:
	is_day = true;
	interaction_count = 0;
	
func night_started() -> void:
	is_day = false;

func find_terrain_rec(node: Node3D) -> void :
	var parent: Node3D = node.get_parent();
	if (parent == null) :
		print("CrystalTile::find_terrain_rec() : couldn't find terrain node");
		assert(false);
		return;
	var found_terrain: Terrain = parent as Terrain;
	if (found_terrain != null) :
		terrain = found_terrain;
		return;
	find_terrain_rec(parent);
	return;


func set_tile_as_crystals() -> void :
	var coords_2d: Vector2 = Vector2(global_position.x, global_position.z) / 2.0;
	var grid_coords: Vector2i = terrain.construction_grid.get_grid_coords_from_world_coords(global_position);
	if (Vector2(grid_coords) != coords_2d) :
		print("CrystalTile: ", name, " is not placed inside a cell!");
		return;
	terrain.construction_grid.set_tile_as_crystal_tile(grid_coords, self);
	return;
	
var mining_tween : Tween = null;
	
func interact() -> void :
	if not is_day and mining_tween != null and mining_tween.is_running(): 
		return;
	
	var player: Player = Globals.player; # should probably be a parameter of interact ?
	var crystals_obtained : int;
	
	if (player.action_points.remove_with_check(action_points_per_interaction)) :
		crystals_obtained = crystal_amount_per_operation * manual_multiplier;
		player.crystals.add(crystals_obtained);
		on_being_manually_mined.emit();
		interaction_count += 1;
		add_indication(crystals_obtained);
		if not is_day:
			mining_tween = get_tree().create_tween();
			mining_tween.tween_property(self, "scale", scale, 1.0).from(Vector3.ONE*0.1).set_ease(Tween.EASE_OUT);
		return;
	
func add_indication(crystals_obtained : int) -> void:
	var other_indication = UIManager.instance.get_children().find(crystal_obtained_icon);
	if other_indication >= 0 and crystal_obtained_icon.unprojector != null:
		# Doit se faire avant, le reset réinitialise également la position de l'unrojector
		crystal_obtained_icon.reset_self(); 		
		if crystal_obtained_icon.unprojector.global_position.is_equal_approx(global_position):
			crystal_obtained_icon.add_to_value(crystals_obtained);
		else:
			crystal_obtained_icon.set_value(crystals_obtained);
			crystal_obtained_icon.unprojector.global_position = global_position;
	else:
		UIManager.instance.add_child(crystal_obtained_icon);
		await get_tree().process_frame;
		crystal_obtained_icon.set_value(crystals_obtained);
		crystal_obtained_icon.unprojector.global_position = global_position;
		crystal_obtained_icon.unprojector.camera = camera;
	

func uninteract() -> void:
	if not is_day or interaction_count <= 0: 
		return;	
	var player : Player = Globals.player;
	
	if player.crystals.remove_with_check(crystal_amount_per_operation * manual_multiplier):
		player.action_points.add(action_points_per_interaction);
		pass;
	interaction_count -= 1;
	return;

func _on_being_manually_mined() -> void :
	# animations, sounds, ...
	
	player_collect_sound.play();
	return;
