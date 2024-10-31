extends Node

@export var saved_robot_list:RobotList = null
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

func load_bot_names() -> Array:
	var array_result = []
	for robot in saved_robot_list.Partecipants:
		if robot.is_playing:
			array_result.append(robot.bot_name)
	bot_amount = array_result.size()
	bot_names = array_result
	return array_result

func get_bot_name(id:int)-> String:
	if id < bot_amount:
		return bot_names[id]
	return "bot 404"
	

# Called when the node enters the scene tree for the first time.
func _ready():
	saved_robot_list = RobotList.new()
	for botname in bot_names_default:
		saved_robot_list.add_robot(RobotStats.new(botname))
	print("pre: ",saved_robot_list)
	save_data()
	load_data()
	print("post: ",saved_robot_list)

func save_data():
	var result = ResourceSaver.save(saved_robot_list,botlist_file,ResourceSaver.FLAG_BUNDLE_RESOURCES)
	print("save: ", result)

func load_data():
	if ResourceLoader.exists(botlist_file):
		var file_list = ResourceLoader.load(botlist_file)
		if file_list is RobotList: # Check that the data is valid
			print("file_list ok: ",file_list)
			saved_robot_list = file_list
		else:
			print("file_list ERR")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()
		get_tree().quit() # default behavior
