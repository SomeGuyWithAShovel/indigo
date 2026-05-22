extends Node3D

func interact() -> void:
	print("Nom d'une feuille tu m'as trouvé !");
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(2.0, 2.0, 2.0), 0.5)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.5)
