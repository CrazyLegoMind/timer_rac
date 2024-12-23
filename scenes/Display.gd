extends Node

signal countdown_completed
@export var fight_time_seconds:float = 60.0
const point_display_delay:float = 0.5
const final_beeps_amount:int = 3
const countdown_seconds:int = 3
const release_seconds:float = 5.0

enum BotSide{BOT_LEFT,BOT_RIGHT}
enum PointTypes{FLIP,TOUCH,WALL,GRAB,OVERRIDE}

#global vars
var fscreen_mode := false
var left_bot_stats :RobotStats = null
var right_bot_stats :RobotStats = null
#timer variables
var time_flowing := false
var countdown_running := false
var time_left:float = fight_time_seconds
var timer_text:String = ""
var final_beeps_remaining = final_beeps_amount
var standby = false
var release_state = false
var last_30_sec = false
var last_10_sec = false


#points variables
var left_delay:float = 0.0
var right_delay:float = 0.0
var left_point_buffer:int = 0
var right_point_buffer:int = 0
var left_point:int = 0
var right_point:int = 0
var left_hold_time := 0.0
var right_hold_time := 0.0
var left_sum_time := false
var right_sum_time := false

var right_touch_state := false
var right_touch_cooldown := 0.0
var left_touch_state := false
var left_touch_cooldown := 0.0


#release_variables
var release_flowing: = false
var release_left: = release_seconds
var release_text:String = "Release!"
var release_beeps = false
var release_buffer :int = int(release_seconds)

var release_label_node = null
var left_buffer_label_node = null
var right_buffer_label_node = null
var timer_label_node = null
@onready var beeps_player_node = $ShortBeep
@onready var beepl_player_node = $LongBeep
var left_name_optlabel = null
var right_name_optlabel = null

var root_ui_node: MatchUI = null

var right_bot_id = 0;
var left_bot_id = 0;

func _ready():
	fill_nodes($StandardUI)
	
	init_values()
	#Engine.time_scale = 0.2
	pass # Replace with function body.

func _input(event):

	if Input.is_action_just_pressed("t_start"):
		print("\nMATCH SART/PAUSE")
		print_match_scores()
		toggle_timer()
	
	if Input.is_action_just_pressed("t_reset"):
		print("\nMATCH RESET")
		print_match_scores()
		init_values()
	
	if Input.is_action_just_pressed("botname_left"):
		left_bot_id = (left_bot_id +1 )% GlobalUtils.playing_robot_list.partecipants.size()
		left_bot_stats = GlobalUtils.playing_robot_list.partecipants[left_bot_id]
		left_name_optlabel.text = left_bot_stats.bot_name
		
	
	
	if Input.is_action_just_pressed("botname_right"):
		right_bot_id = (right_bot_id +1 )% GlobalUtils.playing_robot_list.partecipants.size()
		right_bot_stats = GlobalUtils.playing_robot_list.partecipants[right_bot_id]
		right_name_optlabel.text = right_bot_stats.bot_name
		
	
	
	if Input.is_action_just_pressed("t_release"):
		toggle_release(Input.is_action_pressed("mode_key"))
	
	if Input.is_action_just_pressed("fullscreen"):
		fscreen_mode = !fscreen_mode
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fscreen_mode) else Window.MODE_WINDOWED
	var point_mode = 1
	if Input.is_action_pressed("mode_key"):
		point_mode = -1
	if Input.is_action_just_released("right_point"):
		add_points(BotSide.BOT_RIGHT,PointTypes.OVERRIDE)
	if Input.is_action_just_released("left_point"):
		add_points(BotSide.BOT_LEFT,PointTypes.OVERRIDE)
	if Input.is_action_just_released("right_touch") and $RightTouchTimer.is_stopped() and time_flowing:
		$RightTouchTimer.start()
		add_points(BotSide.BOT_RIGHT,PointTypes.TOUCH)
		update_buffer(BotSide.BOT_RIGHT,"Hit!")
	if Input.is_action_just_released("left_touch") and $LeftTouchTimer.is_stopped() and time_flowing:
		$LeftTouchTimer.start()
		add_points(BotSide.BOT_LEFT,PointTypes.TOUCH)
		update_buffer(BotSide.BOT_LEFT,"Hit!")
	if Input.is_action_just_released("right_flip"):
		add_points(BotSide.BOT_RIGHT,PointTypes.FLIP)
		update_buffer(BotSide.BOT_RIGHT,"FLIP")
	if Input.is_action_just_released("left_flip"):
		add_points(BotSide.BOT_LEFT,PointTypes.FLIP)
		update_buffer(BotSide.BOT_LEFT,"FLIP")
	if Input.is_action_just_released("right_wall"):
		add_points(BotSide.BOT_RIGHT,PointTypes.WALL)
		update_buffer(BotSide.BOT_RIGHT,"push>")
	if Input.is_action_just_released("left_wall"):
		add_points(BotSide.BOT_LEFT,PointTypes.WALL)
		update_buffer(BotSide.BOT_LEFT,"push>")

func fill_nodes(root_ui:MatchUI):
	root_ui_node = root_ui
	
	timer_label_node = root_ui_node.timer_label
	release_label_node = root_ui_node.debug_label
	
	left_name_optlabel = root_ui_node.left_bot_label
	right_name_optlabel = root_ui_node.right_bot_label
	
	left_buffer_label_node = root_ui_node.left_buffer_label
	right_buffer_label_node = root_ui_node.right_buffer_label

func init_values():
	#reset points
	left_point_buffer = 0
	right_point_buffer = 0
	left_point = 0
	right_point = 0
	
	#reset timer
	time_flowing = false
	time_left = fight_time_seconds
	final_beeps_remaining = final_beeps_amount
	timer_label_node.self_modulate = Color(Color.WHITE)
	timer_text = "Ready"
	standby = true
	last_10_sec = false
	last_30_sec = false
	
	#reset release
	release_state = false
	release_flowing = false
	release_beeps = false
	release_label_node.self_modulate = Color(Color.YELLOW)
	release_label_node.set_text("")
	
	#bots
	left_bot_stats = GlobalUtils.playing_robot_list.partecipants[left_bot_id]
	right_bot_stats = GlobalUtils.playing_robot_list.partecipants[right_bot_id]

func add_points(side:BotSide,point_type:PointTypes):
	var point_mode = 1
	if Input.is_action_pressed("mode_key"):
		point_mode = -1
	var points = 0
	if not time_flowing and not point_type == PointTypes.OVERRIDE:
		return
	match point_type:
		PointTypes.FLIP:
			points = 3
		PointTypes.TOUCH:
			points = 1
		PointTypes.WALL:
			points = 1
		PointTypes.GRAB:
			points = 5
		PointTypes.OVERRIDE:
			points = 1
	if side == BotSide.BOT_LEFT:
		if left_bot_stats.is_antweight and [PointTypes.FLIP,PointTypes.WALL].has(point_type):
			points += 1
		points= points*point_mode
		left_point += points
		return
	if side == BotSide.BOT_RIGHT:
		if right_bot_stats.is_antweight and [PointTypes.FLIP,PointTypes.WALL].has(point_type):
			points += 1
		points= points*point_mode
		right_point += points
		return


func update_buffer(side:BotSide,text:String):
	if side == BotSide.BOT_LEFT:
		left_buffer_label_node.text = text
		$LeftDebugClear.start()
		return
	if side == BotSide.BOT_RIGHT:
		right_buffer_label_node.text = text
		$RightDebugClear.start()
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_main_timer(delta)
	handle_points(delta)
	handle_release_timer(delta)


func handle_points(delta):
	root_ui_node.update_points(left_point,right_point)

func handle_main_timer(delta):
	if time_flowing :
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			time_flowing = false
			timer_text = "End!"
			standby = true
		if time_left < 30 and not last_30_sec:
			last_30_sec = true
			timer_label_node.self_modulate = Color(Color.YELLOW)
			beepl_player_node.pitch_scale = 0.5
			beepl_player_node.play()
			$CutAudioTimer.start()
		if time_left < 10 and not last_10_sec:
			last_10_sec = true
			timer_label_node.self_modulate = Color(Color.ORANGE_RED)
			beepl_player_node.pitch_scale = 0.5
			beepl_player_node.play()
			$CutAudioTimer.start()
		if time_left <= final_beeps_remaining:
			if final_beeps_remaining == 0:
				beepl_player_node.pitch_scale = 0.5
				beepl_player_node.play()
				$CutAudioTimer.start()
			else:
				beeps_player_node.pitch_scale = 1.05
				beeps_player_node.play()
			final_beeps_remaining -= 1
		
		if not countdown_running:
			timer_label_node.text = seconds_to_timestamp(time_left)
	else:
		if not countdown_running:
			if standby:
				timer_label_node.text = timer_text
			else:
				timer_label_node.text = seconds_to_timestamp(time_left)


func handle_release_timer(delta):
	if release_flowing:
		release_left -= delta
		if release_left <= 0:
			release_flowing = false
			release_label_node.set_text("Release!")
			release_beeps = true
			$ReleaseBeep.play()
			await get_tree().create_timer(0.4).timeout
			$ReleaseBeep.stop()
			$ReleaseBeep.play()
			await get_tree().create_timer(0.4).timeout
			$ReleaseBeep.stop()
			release_beeps = false
		else:
			
			if release_left <= release_buffer:
				release_buffer -= 1
				$ReleaseBeep.play()
			if release_left < 3 and release_left >2:
				release_label_node.set_text("Wall!")
			else:
				release_label_node.text = str("%2.1f" % release_left)
	else:
		if release_beeps:
			release_label_node.set_text("Release!")
		elif time_flowing:
			release_label_node.set_text("")


func toggle_release(restart:bool):
	if not time_flowing or standby:
		return
	if not release_flowing:
		release_left = release_seconds
		release_buffer = int(release_seconds)
		release_flowing = true
	else:
		if restart:
			release_left = release_seconds
		else:
			release_flowing = false
			$ShortBeep.pitch_scale  = 0.4
			$ShortBeep.play()

func toggle_timer():
	if time_flowing:
		time_flowing = false
		release_state = release_flowing
		if release_state:
			release_flowing = false
	else:
		if countdown_running or time_left <= 0:
			return
		countdown()
		await self.countdown_completed
		time_flowing = true
		if release_state:
			release_flowing = true

func countdown():
	timer_label_node.self_modulate = Color(Color.WHITE)
	if countdown_running:
		return
	countdown_running = true
	beeps_player_node.pitch_scale = 1.02
	var temp = "."
	for i in range(3):
		timer_label_node.text = temp
		temp += "."
		beeps_player_node.play()
		await get_tree().create_timer(0.2).timeout
	beepl_player_node.pitch_scale = 0.6
	var rand_wait = 0.5+(randi()%20)*0.1
	
	await get_tree().create_timer(rand_wait).timeout
	print(rand_wait)
	beepl_player_node.play()
	$CutAudioTimer.start()
	emit_signal("countdown_completed")
	print("START!")
	standby = false
	countdown_running = false

func seconds_to_timestamp(seconds_f:float) -> String:
		var minutes = int(seconds_f)/60
		var seconds = int(seconds_f-minutes*60)
		var centis = snapped(seconds_f-minutes*60-seconds,0.1)*10
		if centis>=10:
			centis = 0
		var sec_dec = ""
		if seconds < 10:
			sec_dec = "0"
		var res = str(minutes)+":"+sec_dec+str(seconds)+"."+str(centis)
		return res

func print_match_scores():
	var left_name = left_name_optlabel.text
	var right_name = right_name_optlabel.text
	print("WIN FOR ",left_name, " -> ", left_name," ",left_point+round(time_left), " - ", right_point," ",right_name )
	print("WIN FOR ",right_name, " -> ",left_name," ",left_point, " - ", right_point+round(time_left)," ",right_name )


func _on_CutAudioTimer_timeout():
	$LongBeep.stop()


func _on_right_debug_clear_timeout():
	right_buffer_label_node.text = ""


func _on_left_debug_clear_timeout():
	left_buffer_label_node.text = ""
