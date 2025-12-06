extends ArmaBase
class_name ArmaChakram

@onready var spawn: Marker2D = $BulletSpawn
@onready var level_up_bd = get_node("/root/LevelUpBD")

@export var nivel: int = 0

# Variables de mejora
var rebotes_adicionales: int = 0
var velocidad_rebote_adicional: float = 0.0

func _logica_disparo(posicion: Vector2, direccion: Vector2):
	var dir_norm = direccion.normalized()
	
	ProjectileFactory.crear_chakram(
		spawn.global_position,
		dir_norm,
		daño + daño_adicional,
		2 + rebotes_adicionales,
		600.0 + velocidad_rebote_adicional,
		self
	)

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("chakram", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("Chakram nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("rebotes"):
		rebotes_adicionales += upgrades["rebotes"]
		print("Chakram nivel ", nivel, " | Rebotes +", upgrades["rebotes"])
	
	if upgrades.has("velocidad_rebote"):
		velocidad_rebote_adicional += upgrades["velocidad_rebote"]
		print("Chakram nivel ", nivel, " | Velocidad rebote +", upgrades["velocidad_rebote"])
