extends Node

signal countdown_completed
export var fight_time_seconds:float = 60.0
const point_display_delay:float = 0.5
const final_beeps_amount:int = 3
const countdown_seconds:int = 3
const release_seconds:float = 5.0

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


#release_variables
var release_flowing: = false
var release_left: = release_seconds
var release_text:String = "Release!"
var release_beeps = false

onready var release_label_node = $MarginContainer/VBoxContainer/ReleaseLabel
onready var red_label_node = $MarginContainer/VBoxContainer/TopHalf/RedContainer/RedLabel
onready var blue_label_node = $MarginContainer/VBoxContainer/TopHalf/BlueContainer/BlueLabel
onready var red_buffer_label_node = $MarginContainer/VBoxContainer/TopHalf/RedContainer/RedBufferLabel
onready var blue_buffer_label_node = $MarginContainer/VBoxContainer/TopHalf/BlueContainer/BlueBufferLabel
onready var timer_label_node = $MarginContainer/VBoxContainer/TopHalf/ClockLabel
onready var beeps_player_node = $ShortBeep
onready var beepl_player_node = $LongBeep

func _ready():
	init_values()
	#Engine.time_scale = 0.2
	pass # Replace with function body.

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
	timer_label_node.self_modulate = Color(Color.white)
	timer_text = "Ready"
	standby = true
	last_10_sec = false
	last_30_sec = false
	
	#reset release
	release_state = false
	release_flowing = false
	release_beeps = false
	release_label_node.self_modulate = Color(Color.yellow)
	release_label_node.set_text("")



func _input(event):

	if Input.is_action_just_pressed("t_start"):
		toggle_timer()
	if Input.is_action_just_pressed("t_reset"):
		init_values()
	if Input.is_action_just_pressed("t_release"):
		toggle_release(Input.is_action_pressed("mode_key"))
	

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
	blue_label_node.text = str(blue_point)
	red_label_node.text = str(red_point)
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
			timer_label_node.self_modulate = Color(Color.yellow)
			beepl_player_node.pitch_scale = 0.5
			beepl_player_node.play()
			$CutAudioTimer.start()
		if time_left < 10 and not last_10_sec:
			last_10_sec = true
			timer_label_node.self_modulate = Color(Color.orangered)
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
			yield(get_tree().create_timer(0.4),"timeout")
			$ReleaseBeep.stop()
			$ReleaseBeep.play()
			yield(get_tree().create_timer(0.4),"timeout")
			$ReleaseBeep.stop()
			release_beeps = false
		else:
			release_label_node.text = seconds_to_timestamp(release_left)
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
		release_flowing = true
	else:
		if restart:
			release_left = release_seconds
		else:
			release_flowing = false

func toggle_timer():
	if time_flowing:
		time_flowing = false
		release_state = release_flowing
		if release_state:
			release_flowing = false
	else:
		if countdown_running or time_left <= 0:
			return
		countdown(countdown_seconds)
		yield(self,"countdown_completed")
		time_flowing = true
		if release_state:
			release_flowing = true

func countdown(duration_sec:int):
	timer_label_node.self_modulate = Color(Color.white)
	if countdown_running:
		return
	countdown_running = true
	beeps_player_node.pitch_scale = 0.8
	for i in duration_sec:
		timer_label_node.text = str(duration_sec-i)+ ".."
		beeps_player_node.play()
		yield(get_tree().create_timer(1),"timeout")
	beepl_player_node.pitch_scale = 0.8
	emit_signal("countdown_completed")
	standby = false
	timer_label_node.text = "Start!"
	beepl_player_node.play()
	yield(get_tree().create_timer(0.5),"timeout")
	beepl_player_node.stop()
	countdown_running = false

func seconds_to_timestamp(seconds_f:float) -> String:
		var minutes = int(seconds_f)/60
		var seconds = int(seconds_f-minutes*60)
		var centis = stepify(seconds_f-minutes*60-seconds,0.1)*10
		if centis>=10:
			centis = 0
		var sec_dec = ""
		if seconds < 10:
			sec_dec = "0"
		var res = str(minutes)+":"+sec_dec+str(seconds)+"."+str(centis)
		return res



func _on_CutAudioTimer_timeout():
	$LongBeep.stop()
