class_name PlayerBaseModuleSlot
extends Node3D

# Represents a "slot" somewhere, where we can build a PlayerBaseModule.
# each slot might have a list of allowed modules (
# [bullet turret, laser turret, ...] or [research_module, weapons_module, collect_module, ...]
# ), but only one module can be on the slot at a time (the module needs to be destroyed for another one to be built here)

@export var base_cell: PlayerBaseCell = null;
@export var area: Area3D = null;
@export var allowed_modules: Array[PlayerBaseModules.Enum] = [];
@export var current_module: PlayerBaseModule = null;

@export var magouille_door: Array[CollisionShape3D] = [];

func _enter_tree() -> void :
	assert(area != null);
	return;

func is_free() -> bool :
	return (current_module == null);

func set_as_free() -> void :
	# current_module.removed.disconnect(set_as_free); # CONNECT_ONE_SHOT, so not needed
	current_module = null;
	return;

func _raw_place_module(module: PlayerBaseModules.Enum) -> bool :
	if not is_free():
		return false;
		
	if (module == PlayerBaseModules.Enum.None) :
		if (current_module.as_enum() == PlayerBaseModules.Enum.None) :
			print("_raw_place_module() : trying to place None while current_module is already None");
			return false;
			
		# current_module.remove(); takes time, so we don't want to set current_module to null instantly
		current_module.removed.connect(set_as_free, ConnectFlags.CONNECT_ONE_SHOT);
		current_module.remove(); # start animation that takes time
		return true;
	
	if (allowed_modules.has(module) == false) :
		print("_raw_place_module() : module isn't allowed");
		return false;
	
	var new_node: Node = PlayerBaseModules.scene_array[module as int].instantiate();
	if (module == PlayerBaseModules.Enum.Door) :
		for collisionshape in magouille_door:
			collisionshape.disabled = true
	var new_module: PlayerBaseModule = new_node as PlayerBaseModule;
	assert(new_module != null);
	
		
	add_child(new_module);
	new_module.owner = self;
	new_module.init_module();
	
	current_module = new_module;
	
	return true;

func check_module(module: PlayerBaseModules.Enum) -> bool:
	if ((allowed_modules.has(module) == false) or (module == PlayerBaseModules.Enum.None)) :
		return false;
	return true
