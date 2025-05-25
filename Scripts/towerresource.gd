extends Resource

class_name towerResource

enum DamageType {NORMAL, MAGIC, SIEGE, PIERCE}
enum Ranges {CLOSEST, CLOSE, FAR, FURTHEST}
enum AttackType {SINGLE, AOE, CHAIN}

@export var tower_name		: String				#Tower Visual Name
@export var projectile		: PackedScene			#Projectile for attack
@export var fire_speed		: int					#Projectile speed
@export var attack_cd 		: float					#Time between attacks
@export var attack_damage 	: int 					#Damage of attacks
@export var attack_type		: AttackType			#Attack tyype
@export var damage_type 	: DamageType			#Attack type enum
@export var tower_range 	: Ranges				#Range enum value
@export var projectile_color: Color					#Projectile colour
@export var tower_icon 		: Texture2D
