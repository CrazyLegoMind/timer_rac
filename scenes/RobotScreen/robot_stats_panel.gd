extends PanelContainer
@onready var bot_name = %BotName
@onready var playing = %Playing
@onready var ant = %Ant

var bot_stats:RobotStats = null

func _ready():
	update_visuals()


func update_visuals():
	if not is_instance_valid(bot_stats):
		return
	bot_name.text = bot_stats.bot_name
	playing.button_pressed = bot_stats.is_playing
	ant.button_pressed = bot_stats.is_antweight
	if not bot_stats.is_playing:
		modulate = Color("#ffffff60")
	else:
		modulate = Color("#ffffffff")

func _on_playing_toggled(toggled_on):
	if toggled_on != bot_stats.is_playing:
		bot_stats.is_playing = toggled_on
		update_visuals()


func _on_ant_toggled(toggled_on):
	if toggled_on != bot_stats.is_antweight:
		bot_stats.is_antweight = toggled_on
		update_visuals()


func _on_bot_name_text_changed(new_text):
	bot_stats.bot_name = new_text
