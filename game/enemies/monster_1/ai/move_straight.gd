@tool
extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var target : Node3D = blackboard.get_value("target", monster.default_target);
	var direction := (target.global_position - monster.character.global_position).normalized();
	monster.character.velocity = monster.speed * direction;
	return SUCCESS;
