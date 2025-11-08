extends ArmaBase
class_name ArmaChakram

@export var chakram_scene: PackedScene = preload("res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn")
@onready var spawn: Marker2D = $BulletSpawn
@onready var level_up_bd = get_node("/root/LevelUpBD")

@export var nivel: int = 0

# Variables de mejora
var rebotes_adicionales: int = 0
var velocidad_rebote_adicional: float = 0.0

func _logica_disparo(posicion: Vector2, direccion: Vector2):
	var chakram = chakram_scene.instantiate() as ProyectilChakram
	chakram.global_position = spawn.global_position
	
	var dir_norm = direccion.normalized()
	chakram.rotation = dir_norm.angle()
	
	chakram.creador = self
	chakram.max_rebotes = 2 + rebotes_adicionales
	chakram.daño = daño + daño_adicional
	chakram.speed = 600.0 + velocidad_rebote_adicional
	
	get_tree().current_scene.add_child(chakram)

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("chakram", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("✅ Chakram nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("rebotes"):
		rebotes_adicionales += upgrades["rebotes"]
		print("✅ Chakram nivel ", nivel, " | Rebotes +", upgrades["rebotes"])
	
	if upgrades.has("velocidad_rebote"):
		velocidad_rebote_adicional += upgrades["velocidad_rebote"]
		print("✅ Chakram nivel ", nivel, " | Velocidad rebote +", upgrades["velocidad_rebote"])
