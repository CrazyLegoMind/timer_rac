extends MarginContainer
class_name MatchUI

@export_subgroup("labels")
@export var red_bot_label :Label
@export var blue_bot_label :Label
@export var timer_label :Label
@export var debug_label :Label
@export_subgroup("")

@export_subgroup("points")
@export var red_points_labels :Array[Label]
@export var blue_points_labels  :Array[Label]
@export var red_buffer_label :Label
@export var blue_buffer_label :Label
@export_subgroup("")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_points(red_points:int,blue_points:int):
	if red_points >= 0:
		for elem in red_points_labels:
			elem.text = str(red_points)
	if blue_points >= 0:
		for elem in blue_points_labels:
			elem.text = str(blue_points)
