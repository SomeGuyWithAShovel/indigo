@tool
extends ActionLeaf

@export var animation := "Attacking !";

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	print(animation);
	return SUCCESS;
