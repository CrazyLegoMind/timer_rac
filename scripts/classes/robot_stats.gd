class_name RobotStats extends Resource

var bot_name := "Robot":
	set(value):
		bot_name = value
	get:
		return bot_name
var is_playing := true :
	set(value):
		is_playing = value
	get:
		return is_playing
var is_antweight := false:
	set(value):
		is_antweight = value
	get:
		return is_antweight

func _init(robot_name):
	self.bot_name = robot_name

func _to_string():
	var out = str(bot_name)\
			+" - playing: "+str(is_playing)\
			+", ant: "+str(is_antweight)
	return out
