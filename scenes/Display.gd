extends Node

signal countdown_completed
@export var fight_time_seconds:float = 60.0
const point_display_delay:float = 0.5
const final_beeps_amount:int = 3
const countdown_seconds:int = 3
const release_seconds:float = 5.0

var fscreen_mode := false

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
var red_delay:float = 0.0
var blue_delay:float = 0.0
var red_point_buffer:int = 0
var blue_point_buffer:int = 0
var red_point:int = 0
var blue_point:int = 0
var red_hold_time := 0.0
var blue_hold_time := 0.0
var red_sum_time := false
var blue_sum_time := false

var blue_touch_state := false
var blue_touch_cooldown := 0.0
var red_touch_state := false
var red_touch_cooldown := 0.0


#release_variables
var release_flowing: = false
var release_left: = release_seconds
var release_text:String = "Release!"
var release_beeps = false
var release_buffer :int = int(release_seconds)

var release_label_node = null
var red_buffer_label_node = null
var blue_buffer_label_node = null
var timer_label_node = null
@onready var beeps_player_node = $ShortBeep
@onready var beepl_player_node = $LongBeep
var red_name_optlabel = null
var blue_name_optlabel = null

var root_ui_node: MatchUI = null

var blue_bot_id = 0;
var red_bot_id = 0;

func _ready():
	fill_nodes($StandardUI)
	
	init_values()
	#Engine.time_scale = 0.2
	pass # Replace with function body.

func fill_nodes(root_ui:MatchUI):
	root_ui_node = root_ui
	
	timer_label_node = root_ui_node.timer_label
	release_label_node = root_ui_node.debug_label
	
	red_name_optlabel = root_ui_node.red_bot_label
	blue_name_optlabel = root_ui_node.blue_bot_label
	
	red_buffer_label_node = root_ui_node.red_buffer_label
	blue_buffer_label_node = root_ui_node.blue_buffer_label

func init_values():
	#reset points
	red_point_buffer = 0
	blue_point_buffer = 0
	red_point = 0
	blue_point = 0
	
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



func _input(event):

	if Input.is_action_just_pressed("t_start"):
		print("\nMATCH SART/PAUSE")
		print_match_scores()
		toggle_timer()
	if Input.is_action_just_pressed("botname_left"):
		red_name_optlabel.text = GlobalUtils.get_bot_name(red_bot_id)
		red_bot_id = (red_bot_id +1 )% GlobalUtils.bot_amount
	if Input.is_action_just_pressed("botname_right"):
	
		blue_name_optlabel.text = GlobalUtils.get_bot_name(blue_bot_id)
		blue_bot_id = (blue_bot_id +1 )% GlobalUtils.bot_amount
		
	if Input.is_action_just_pressed("t_reset"):
		print("\nMATCH RESET")
		print_match_scores()
		init_values()
	if Input.is_action_just_pressed("t_release"):
		toggle_release(Input.is_action_pressed("mode_key"))
	if Input.is_action_just_pressed("fullscreen"):
		fscreen_mode = !fscreen_mode
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fscreen_mode) else Window.MODE_WINDOWED

#	if Input.is_action_just_released("blue_point"):
#		blue_point_buffer += point_mode
#		blue_delay += point_display_delay
#	if Input.is_action_just_released("red_point"):
#		red_point_buffer += point_mode
#		red_delay += point_display_delay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_point_input(delta)
	handle_main_timer(delta)
	handle_points(delta)
	handle_release_timer(delta)


func handle_point_input(delta):
	var point_mode = 1
	var release_restart = false
	if Input.is_action_pressed("mode_key"):
		point_mode = -1
		release_restart = true
	if Input.is_action_pressed("mode_up_key"):
		point_mode = point_mode*3
	if not time_flowing:
		point_mode = 0
	if blue_touch_cooldown >= 0.0:
		blue_touch_cooldown -= delta
	if red_touch_cooldown >= 0.0:
		red_touch_cooldown -= delta
	
	if Input.is_action_pressed("blue_touch") and not blue_touch_state:
		blue_touch_state = true
		if blue_touch_cooldown <= 0.0:
			blue_point_buffer += 1
			blue_touch_cooldown = 1.0
	elif not Input.is_action_pressed("blue_touch"):
		blue_touch_state = false
	
	if Input.is_action_pressed("red_touch") and not red_touch_state:
		red_touch_state = true
		if red_touch_cooldown <= 0.0:
			red_point_buffer += 1
			red_touch_cooldown = 1.0
	elif not Input.is_action_pressed("red_touch"):
		red_touch_state = false
	
	if Input.is_action_pressed("blue_point"):
		blue_hold_time += delta
		if blue_hold_time > 0.03 and blue_sum_time:
			blue_sum_time = false
			blue_point_buffer += point_mode
			blue_delay += point_display_delay
		if blue_hold_time > 1.0:
			blue_point_buffer += point_mode
			blue_delay += point_display_delay
			blue_hold_time = 0.0
	else:
		blue_hold_time = 0.0
		blue_sum_time = true
	
	
	if Input.is_action_pressed("red_point"):
		red_hold_time += delta
		if red_hold_time > 0.03 and red_sum_time:
			red_sum_time = false
			red_point_buffer += point_mode
			red_delay += point_display_delay
		if red_hold_time > 1.0:
			red_point_buffer += point_mode
			red_delay += point_display_delay
			red_hold_time = 0.0
	else:
		red_hold_time = 0.0
		red_sum_time = true
	
	

func handle_points(delta):
	# big points
	red_delay -= delta
	blue_delay -= delta
	red_delay = clamp(red_delay,0.0,point_display_delay)
	blue_delay = clamp(blue_delay,0.0,point_display_delay)
	if red_delay <= 0 and red_point_buffer != 0:
		var temp = red_point_buffer
		red_point += temp
		red_point_buffer = red_point_buffer - temp
	if blue_delay <= 0 and blue_point_buffer != 0:
		var temp = blue_point_buffer
		blue_point += temp
		blue_point_buffer = blue_point_buffer - temp
	
	root_ui_node.update_points(red_point,blue_point)
	#feedback buffers
	
	blue_buffer_label_node.text = ("+" if blue_point_buffer>0 else "")+str(blue_point_buffer)
	red_buffer_label_node.text = ("+" if red_point_buffer>0 else "")+str(red_point_buffer)

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
	var red_name = red_name_optlabel.text
	var blue_name = blue_name_optlabel.text
	print("WIN FOR ",red_name, " -> ", red_name," ",red_point+round(time_left), " - ", blue_point," ",blue_name )
	print("WIN FOR ",blue_name, " -> ",red_name," ",red_point, " - ", blue_point+round(time_left)," ",blue_name )


func _on_CutAudioTimer_timeout():
	$LongBeep.stop()
