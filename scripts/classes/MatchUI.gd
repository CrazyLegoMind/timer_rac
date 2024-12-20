extends MarginContainer
class_name MatchUI

@export_subgroup("labels")
@export var left_bot_label :Label
@export var right_bot_label :Label
@export var timer_label :Label
@export var debug_label :Label
@export_subgroup("")

@export_subgroup("points")
@export var left_points_labels :Array[Label]
@export var right_points_labels  :Array[Label]
@export var left_buffer_label :Label
@export var right_buffer_label :Label
@export_subgroup("")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_points(left_points:int,right_points:int):
	if left_points >= 0:
		for elem in left_points_labels:
			elem.text = str(left_points)
	if right_points >= 0:
		for elem in right_points_labels:
			elem.text = str(right_points)
