extends Node
var high_score := 0
var score := 0

func _ready():
	var file = File.new()
	if file.file_exists("user://highscore"):
		file.open("user://highscore", File.READ)
		high_score = file.get_64()
		file.close()

func save_high_score(new_high_score):
	var file = File.new()
	file.open("user://highscore", File.WRITE)
	file.store_64(new_high_score)
	high_score = new_high_score
	file.close()
	
