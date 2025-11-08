extends ArmaBase
class_name ArmaSniper

@export var bullet_scene: PackedScene = preload("res://scenes/Armas/Holded/Sniper/SniperBullet.tscn")
@onready var spawn: Marker2D = $BulletSpawn
@onready var level_up_bd = get_node("/root/LevelUpBD")

@export var nivel: int = 0

# Variables de mejora
var velocidad_proyectil_adicional: float = 0.0
var area_proyectil_multiplicador: float = 0.0  # Acumulativo (0.2 = +20%)

func _logica_disparo(pos: Vector2, dir: Vector2) -> void:
	var bala = bullet_scene.instantiate() as SniperBullet
	bala.global_position = spawn.global_position
	bala.direction = dir.normalized()
	bala.level = nivel
	
	# Aplicar mejoras
	bala.damage = daño + daño_adicional
	bala.speed = 600.0 + velocidad_proyectil_adicional
	bala.area_multiplicador = 1.0 + area_proyectil_multiplicador
	
	get_tree().current_scene.add_child(bala)

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("sniper", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("✅ Sniper nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("velocidad_proyectil"):
		velocidad_proyectil_adicional += upgrades["velocidad_proyectil"]
		print("✅ Sniper nivel ", nivel, " | Velocidad proyectil +", upgrades["velocidad_proyectil"])
	
	if upgrades.has("area_proyectil"):
		area_proyectil_multiplicador += upgrades["area_proyectil"]
		print("✅ Sniper nivel ", nivel, " | Área proyectil +", int(upgrades["area_proyectil"] * 100), "%")
