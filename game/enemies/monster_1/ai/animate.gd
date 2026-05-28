@tool
extends ActionLeaf

@export var animation : Monster1Animations.Anim = Monster1Animations.Anim.IDLE;

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	match animation:
		Monster1Animations.Anim.IDLE:
			monster.animations.start_idle();
		Monster1Animations.Anim.WALK:
			monster.animations.start_walk();
		Monster1Animations.Anim.ATTACK:
			monster.animations.start_attack();
		Monster1Animations.Anim.HURT:
			monster.animations.start_hurt();		
	return SUCCESS;
