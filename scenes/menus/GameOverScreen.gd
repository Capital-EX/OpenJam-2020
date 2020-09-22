extends Control
var done = false


func _ready():
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("rise-up")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	$CanvasLayer2/CenterContainer/HBoxContainer/Label.text %= [Scoreboard.score, Scoreboard.high_score]
	if Scoreboard.score > Scoreboard.high_score:
		$HighscoreAnimation.play("show_scores")
		Scoreboard.save_high_score(Scoreboard.score)
	$TextAnimations.play("show_scores")
	yield($TextAnimations, "animation_finished")
	
	done = true

func _input(event):
	if event is InputEventKey and done:
		get_tree().change_scene("res://scenes/menus/MainMenu.tscn")
