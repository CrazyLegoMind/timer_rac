extends Node

const bot_file_path = "user://bots.txt"
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
	"WitchClaw",
	"Dark Franko",
	"Panda",
]
var bot_names = []
var bot_amount = bot_names_default.size()

func load_bot_names() -> Array:
	if not FileAccess.file_exists(bot_file_path):
		var file := FileAccess.open(bot_file_path,FileAccess.WRITE)
		for botname in bot_names_default:
			file.store_line(botname)
		file.close()
	var file := FileAccess.open(bot_file_path,FileAccess.READ)
	var file_string = file.get_as_text()
	var array_result:Array = []
	for line in file_string.split("\n"):
		if line.length() > 1:
			array_result.append(line)
	bot_amount = array_result.size()
	bot_names = array_result
	return array_result

func get_bot_name(id:int)-> String:
	if id < bot_amount:
		return bot_names[id]
	return "bot 404"
	

# Called when the node enters the scene tree for the first time.
func _ready():
	print(load_bot_names())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
