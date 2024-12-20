extends MarginContainer

@export var robot_stat_panel:PackedScene = preload("res://scenes/RobotScreen/robot_stats_panel.tscn")
@onready var robots_grid = %Robots
var tournament_scene = preload("res://scenes/Display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for robot in GlobalUtils.saved_robot_list.partecipants:
		var stats_node = robot_stat_panel.instantiate()
		stats_node.bot_stats = robot
		robots_grid.add_child(stats_node)



func _on_start_pressed():
	get_tree().change_scene_to_packed(tournament_scene)
	GlobalUtils.save_data()
	GlobalUtils.fill_playing_robots()


func _on_add_pressed():
	var stats_node = robot_stat_panel.instantiate()
	stats_node.bot_stats = RobotStats.new()
	GlobalUtils.saved_robot_list.add_robot(stats_node.bot_stats)
	robots_grid.add_child(stats_node)
