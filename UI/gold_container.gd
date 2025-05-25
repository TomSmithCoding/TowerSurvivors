extends VBoxContainer

@onready var gold_display = $GoldText

var gold: String = str(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	update_gold()
	pass

func update_gold():
	gold_display.text = ("GOLD: " + gold)
