extends VBoxContainer

@onready var score_display = $ScoreText

var score: String = str(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	update_score()
	pass

func update_score():
	score_display.text = ("SCORE: " + score)
