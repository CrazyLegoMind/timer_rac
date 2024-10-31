class_name RobotList extends Resource

@export var Partecipants:Array[RobotStats] = []

func add_robot(robot:RobotStats):
	Partecipants.append(robot)

func remove_robot(robot:RobotStats):
	Partecipants.erase(robot)

func _to_string():
	var out = ""
	for part in Partecipants:
		out += str(part)+"\n"
	return out
