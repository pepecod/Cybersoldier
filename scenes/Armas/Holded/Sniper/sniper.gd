extends ArmaBase
class_name ArmaSniper

@export var bullet_scene: PackedScene = preload("res://scenes/Armas/Holded/Sniper/SniperBullet.tscn")
@onready var spawn: Marker2D = $BulletSpawn
@export var nivel: int = 0

func _logica_disparo(pos: Vector2, dir: Vector2) -> void:
	var bala = bullet_scene.instantiate() as SniperBullet
	bala.global_position = spawn.global_position
	bala.direction       = dir.normalized()
	bala.level           = nivel
	# aumenta daño según nivel, p.ej. +50% por nivel
	bala.damage          = daño * (1 + 0.5 * nivel)
	get_tree().current_scene.add_child(bala)
