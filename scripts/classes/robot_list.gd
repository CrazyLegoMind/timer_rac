class_name RobotList extends Resource


@export var partecipants:Array[RobotStats] = []
@export var list_name = "default"

func add_robot(robot:RobotStats):
	partecipants.append(robot)

func remove_robot(robot:RobotStats):
	partecipants.erase(robot)

func _to_string():
	var out = "default: \n"
	for part in partecipants:
		out += str(part)+"\n"
	return out
