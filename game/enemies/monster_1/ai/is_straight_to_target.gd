@tool
extends ConditionLeaf

@export var target_name : String;
@export_flags_3d_physics var layers : int;

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster_char : Node3D = (actor as Monster).character;
	var target : Node3D = blackboard.get_value(target_name, actor.default_target);
	assert(target != null, "Cible indéfinie lors du passage dans un noeud is_straight_to_target : "+target_name);
	
	var params := PhysicsShapeQueryParameters3D.new();
	var collision_shape := (monster_char.find_child("CollisionShape3D") as CollisionShape3D).shape;
	params.shape = collision_shape;
	params.motion = target.global_position - monster_char.global_position;
	params.collision_mask &= layers;
	
	var space_state := (monster_char as Node3D).get_world_3d().direct_space_state;
	var intersections := space_state.intersect_shape(params);
	if intersections.is_empty() or (len(intersections) == 1 and intersections[0]["collider"].get_parent() == target):
		return SUCCESS;
	else:
		return FAILURE;
