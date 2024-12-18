extends Node


const botlist_file = "user://botlist.tres"
const  bot_names_default = [
	"Arancinu",
	"LAG",
	"Sphiga",
	"Robonapoli",
	"Tau",
	"Lingua",
	"Handy",
	"Crocodile",
	"Devastator",
	"Elatant",
	"Hornet",
	"Banillo",
	"Maresciallo",
	"Panda",
]

var bot_names = []
var bot_amount = 0

var saved_robot_list:RobotList = preload("res://scripts/resources/robot_list.tres")
var robot_stat_tres:RobotStats = preload("res://scripts/resources/robot_stat.tres")

func _ready():
	saved_robot_list = RobotList.new()
	for botname in bot_names_default:
		var placeholder_robot:RobotStats = robot_stat_tres.duplicate()
		placeholder_robot.bot_name = botname
		saved_robot_list.add_robot(placeholder_robot)
	load_data()
	load_bot_names()

func save_data():
	var result = ResourceSaver.save(saved_robot_list,botlist_file)
	print("saved: ", result)

func load_data():
	if ResourceLoader.exists(botlist_file):
		var file_list = ResourceLoader.load(botlist_file,)
		if file_list is RobotList: # Check that the data is valid
			print("file_list ok: ",file_list)
			saved_robot_list = file_list
			return
		else:
			print("file_list ERR")
	save_data()

func load_bot_names() -> Array:
	var array_result = []
	print("part \n", saved_robot_list.partecipants)
	for robot in saved_robot_list.partecipants:
		print(robot)
		if robot.is_playing:
			array_result.append(robot.bot_name)
	bot_amount = array_result.size()
	bot_names = array_result
	print(bot_amount)
	return array_result

func get_bot_name(id:int)-> String:
	if id < bot_amount:
		return bot_names[id]
	return "bot 404"

func _exit_tree():
	save_data()
