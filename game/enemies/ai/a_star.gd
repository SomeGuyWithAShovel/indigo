@tool
extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var current_agent_position: Vector3 = monster.character.global_position;
	var next_path_position: Vector3 = monster.navigation.get_next_path_position();
	
	var target : Node3D = blackboard.get_value("target", monster.default_target);
	assert(target != null);
	monster.navigation.target_position = target.global_position;

	monster.character.velocity = current_agent_position.direction_to(next_path_position) * monster.speed;
	monster.character.move_and_slide();
	return SUCCESS;
