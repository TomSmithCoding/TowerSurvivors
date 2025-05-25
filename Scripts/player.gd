extends CharacterBody3D

@onready var healthbar = $"../SubViewport/PlayerHealth"
@onready var playerhealthlabel = $"../SubViewport/PlayerHealth/PlayerHealthValue"

@onready var towers = []

@export var tower:PackedScene
@export var playermaxhealth:int = 1000
@export var playercurrenthealth:int = 1000
@export var healthregen = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	healthbar.value = playermaxhealth
	
	if(playercurrenthealth > playermaxhealth):
		playercurrenthealth = playermaxhealth
		
	if(playerhealthlabel):
		playerhealthlabel.text = str(playercurrenthealth) + " / " + str(playermaxhealth)
	
	add_tower()

func _physics_process(_delta: float) -> void:
	pass

func add_tower():
	var instance = tower.instantiate()
	towers.append(instance)
	add_child(instance)
	pass

func damage(value: int) -> void:
	if playercurrenthealth > 0:
		playercurrenthealth -= value
		healthbar.value -= value

func _process(_delta):
	#healthbar.value = playercurrenthealth
	pass
