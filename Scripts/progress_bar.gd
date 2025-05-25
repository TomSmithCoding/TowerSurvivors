extends ProgressBar

var fill_stylebox:StyleBoxFlat
const health_bar_colours = preload("res://UI//healthcolours.tres")

@onready var playerhealthlabel = $PlayerHealthValue
@onready var player = $"../../PlayerCharacterBody"

func _ready():
	fill_stylebox = get_theme_stylebox("fill")
	
func _on_value_changed(new_value):
	if(player.playercurrenthealth > player.playermaxhealth):
		player.playercurrenthealth = player.playermaxhealth
	playerhealthlabel.text = str(player.playercurrenthealth) + " / " + str(player.playermaxhealth)
	playerhealthlabel.label_settings.font_color = health_bar_colours.gradient.sample(1 - (new_value / max_value))
	fill_stylebox.bg_color = health_bar_colours.gradient.sample(1 - (new_value / max_value))
	pass # Replace with function body.

func _process(_delta):
	pass
	
