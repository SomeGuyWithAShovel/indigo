extends NavigationRegion3D

@onready var nav_region : NavigationRegion3D = $".";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayNightSystem.on_night_start.connect(recalculate_navmesh);

func recalculate_navmesh() -> void:
	nav_region.bake_navigation_mesh();
