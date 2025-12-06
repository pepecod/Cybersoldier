extends ArmaBase
class_name ArmaSniper

@onready var spawn: Marker2D = $BulletSpawn
@onready var level_up_bd = get_node("/root/LevelUpBD")

@export var nivel: int = 0

# Variables de mejora
var velocidad_proyectil_adicional: float = 0.0
var area_proyectil_multiplicador: float = 0.0

func _logica_disparo(pos: Vector2, dir: Vector2) -> void:
	ProjectileFactory.crear_bala_sniper(
		spawn.global_position,
		dir.normalized(),
		daño + daño_adicional,
		600.0 + velocidad_proyectil_adicional,
		1.0 + area_proyectil_multiplicador,
		nivel
	)

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("sniper", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("Sniper nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("velocidad_proyectil"):
		velocidad_proyectil_adicional += upgrades["velocidad_proyectil"]
		print("Sniper nivel ", nivel, " | Velocidad proyectil +", upgrades["velocidad_proyectil"])
	
	if upgrades.has("area_proyectil"):
		area_proyectil_multiplicador += upgrades["area_proyectil"]
		print("Sniper nivel ", nivel, " | Área proyectil +", int(upgrades["area_proyectil"] * 100), "%")
