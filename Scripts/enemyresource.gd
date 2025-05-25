extends Resource

class_name enemyResource

enum AttackType {MELEE, RANGED, MAGIC, SIEGE}

@export var projectile			: PackedScene	#Projectile for attack
@export var speed 				: float			#Movement speed
@export var fire_speed 			: float			#Projectile speed
@export var attack_cd 			: float			#Time between attacks
@export var attack_damage 		: int			#Damage of attacks
@export var attack_type 		: AttackType	#Attack type enum
@export var enemymaxhealth 		: int 			#Maximum health
@export var enemycurrenthealth 	: int			#Current health
@export var enemy_colour 		: Color			#Enemy mesh color
@export var projectile_color	: Color			#Enemy projectile color
@export var range				: int			#Potentially used for changing raycast length?
