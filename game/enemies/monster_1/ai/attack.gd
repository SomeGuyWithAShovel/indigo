@tool
extends ActionLeaf

@export var target_name := "target";
@export_flags_3d_physics var hurt_layers : int;

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var target : Node3D = blackboard.get_value(target_name);
	if target == null:
		return FAILURE
	var space_state := monster.get_world_3d().direct_space_state;
	var query := PhysicsRayQueryParameters3D.create(monster.global_position, target.global_position);
	query.collision_mask = hurt_layers;
	var result : Dictionary = space_state.intersect_ray(query);
	if not result.is_empty():
		var target_or_obstacle : Node3D = result["collider"].get_parent();
		var health_components : Array[Node] = target_or_obstacle.find_children("*", "HealthComponent", false);
		assert(len(health_components) == 1, "Cible de monstre sans HealthComponent ?");
		(health_components[0] as HealthComponent).hurt(monster.attack_damage);
	return SUCCESS;
