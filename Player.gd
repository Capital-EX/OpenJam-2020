extends Node2D
enum Side { Left, Right }

const MAX_HOVER_TIME : float = 20.0 / 60.0

var side : int = Side.Left
var is_up : bool = false
var can_high_dodge : bool = true
var up_time : float = 0




# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	pass

func _process(delta):
	
	if Input.is_action_just_pressed("move_left") and not $Tween.is_active() and side == Side.Right:
		if is_up and can_high_dodge: # use the high dodge
			$Tween.interpolate_property(self, "position:x", 470, 42, 0.1, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
			$Tween.start()
			$AnimationPlayer.play("Left")
			side = Side.Left
			can_high_dodge = false
			
		elif not is_up:
			$Tween.interpolate_property(self, "position:x", 470, 42, 0.1, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
			$Tween.start()
			$AnimationPlayer.play("Left")
			side = Side.Left
		
		
	elif Input.is_action_just_pressed("move_right") and not $Tween.is_active() and side == Side.Left:
		if is_up and can_high_dodge: # use the high dodge
			$Tween.interpolate_property(self, "position:x", 42, 470, 0.05, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
			$Tween.start()
			$AnimationPlayer.play("Right")
			side = Side.Right
			can_high_dodge = false
			
		elif not is_up:
			$Tween.interpolate_property(self, "position:x", 42, 470, 0.05, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
			$Tween.start()
			$AnimationPlayer.play("Right")
			side = Side.Right
		
		
	elif Input.is_action_just_pressed("dodge_up") and not $Tween.is_active() and not is_up:
		$Tween.interpolate_property(self, "position:y", 250, 54, 0.05, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		$Tween.start()
		is_up = true
	
	if is_up:
		up_time += delta
		if up_time > MAX_HOVER_TIME and not $Tween.is_active():
			$Tween.interpolate_property(self, "position:y", 54, 250, 0.05, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
			$Tween.connect("tween_all_completed", self, "drop", [], CONNECT_ONESHOT)
			$Tween.start()
	
func drop():
	is_up = false
	can_high_dodge = true
	up_time = 0
	
