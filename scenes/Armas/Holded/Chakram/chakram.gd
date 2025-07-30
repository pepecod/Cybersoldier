extends ArmaBase
class_name ArmaChakram

@export var chakram_scene: PackedScene = preload("res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn")
@onready var spawn: Marker2D = $BulletSpawn

@export var nivel: int = 0

func _logica_disparo(posicion: Vector2, direccion: Vector2):
	var chakram = chakram_scene.instantiate() as ProyectilChakram
	chakram.global_position = spawn.global_position

	# —► Opción 1 (recomendado):
	var dir_norm = direccion.normalized()
	chakram.rotation = dir_norm.angle()

	# —► Opción 2 (si añades var direccion al chakram):
	# chakram.direccion = direccion.normalized()

	chakram.creador     = self
	chakram.max_rebotes = 2 + nivel
	chakram.daño        = daño
	get_tree().current_scene.add_child(chakram)
