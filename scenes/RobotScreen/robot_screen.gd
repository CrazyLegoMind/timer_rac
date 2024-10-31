extends MarginContainer

@export var robot_stat_panel:PackedScene = preload("res://scenes/RobotScreen/robot_stats_panel.tscn")
@onready var robots_grid = %Robots

# Called when the node enters the scene tree for the first time.
func _ready():
	for robot in GlobalUtils.saved_robot_list.partecipants:
		var stats_node = robot_stat_panel.instantiate()
		stats_node.bot_stats = robot
		robots_grid.add_child(stats_node)

