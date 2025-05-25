extends ProgressBar

var fill_stylebox:StyleBoxFlat
const health_bar_colours = preload("res://UI//healthcolours.tres")

@onready var enemyhealthlabel = $EnemyHealthValue
@onready var enemy = $"../../EnemyCharacterBody"

func _ready():
	fill_stylebox = get_theme_stylebox("fill")
	set_max(enemy.enemymaxhealth)
	#print("Max: ", max_value)
	
func _on_value_changed(new_value):
	if(enemy.enemycurrenthealth > enemy.enemymaxhealth):
		enemy.enemycurrenthealth = enemy.enemymaxhealth
	
	enemyhealthlabel.text = str(enemy.enemycurrenthealth) + " / " + str(enemy.enemymaxhealth)
	enemyhealthlabel.label_settings.font_color = health_bar_colours.gradient.sample(1 - (new_value / max_value))
	
	fill_stylebox.bg_color = health_bar_colours.gradient.sample(1 - (new_value / max_value))

func _process(_delta):
	pass
	
