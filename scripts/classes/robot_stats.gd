class_name RobotStats extends Resource

@export var bot_name := "Robot":
	set(value):
		bot_name = value
	get:
		return bot_name
@export var is_playing := true :
	set(value):
		is_playing = value
	get:
		return is_playing
@export var is_antweight := false:
	set(value):
		is_antweight = value
	get:
		return is_antweight

func _to_string():
	var out = str(bot_name)\
			+" - playing: "+str(is_playing)\
			+", ant: "+str(is_antweight)
	return out
