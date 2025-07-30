extends Node
class_name WeaponDB

class WeaponData:
	var name: String
	var scene_path: String
	var type: String
	var unlock_level: int
	var description: String
	var icon_path: String

	func _init(
		_name: String = "",
		_scene_path: String = "",
		_type: String = "active",
		_unlock_level: int = 1,
		_description: String = "",
		_icon_path: String = ""
	) -> void:
		name          = _name
		scene_path    = _scene_path
		type          = _type
		unlock_level  = _unlock_level
		description   = _description
		icon_path     = _icon_path

# Lista con todas las armas/pasivas del juego
var all_weapons: Array[WeaponData] = [
	WeaponData.new(
		"Chakram",
		"res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn",
		"active",
		1,
		"Rebota entre varios enemigos antes de desaparecer.",
		"res://assets/armas/chakram.png"
	),
	WeaponData.new(
		"Sniper",
		"res://scenes/Armas/Holded/Sniper/sniper.tscn",
		"active",
		1,
		"Bala lenta y penetrante que atraviesa múltiples blancos.",
		"res://assets/armas/sniper.png"
	),
	WeaponData.new(
		"Escopeta",
		"res://scenes/Armas/Holded/Escopeta/escopeta.tscn",
		"active",
		1,
		"Dispara una nube de proyectiles cortos con gran dispersión.",
		"res://assets/armas/escopeta.png"
	),
	WeaponData.new(
		"Aura",
		"res://scenes/Armas/Throweables/Aura/aura.tscn",
		"passive",
		1,
		"Genera un campo que daña a los enemigos cercanos.",
		"res://assets/armas/aura.png"
	),
	WeaponData.new(
		"Dron",
		"res://scenes/Armas/Throweables/Dron/dron.tscn",
		"passive",
		1,
		"Un dron que dispara automáticamente a los enemigos.",
		"res://assets/armas/dron.png"
	),
	WeaponData.new(
		"Minas",
		"res://scenes/Armas/Throweables/Minas/minas.tscn",
		"passive",
		1,
		"Coloca minas que explotan al paso de un enemigo.",
		"res://assets/armas/minas.png"
	),
	WeaponData.new(
		"Molotov",
		"res://scenes/Armas/Throweables/Molotov/molotov.tscn",
		"passive",
		1,
		"Lanza cócteles molotov que prenden el suelo.",
		"res://assets/armas/molotov.png"
	),
	WeaponData.new(
		"Sierras",
		"res://scenes/Armas/Throweables/Sierras/sierras.tscn",
		"passive",
		1,
		"Sierras giratorias que cortan todo a su paso.",
		"res://assets/sierras/sierras.png"
	),
	WeaponData.new(
		"Lanzacohetes",
		"res://scenes/Armas/Definitivas/Lanzacohetes/lanzacohetes.tscn",
		"active",
		10,
		"Dispara cohetes balísticos de gran daño.",
		"res://assets/armas/lanzacohetes.png"
	),
	WeaponData.new(
		"Lanzallamas",
		"res://scenes/Armas/Definitivas/Lanzallamas/lanzallamas.tscn",
		"active",
		10,
		"Una ráfaga continua de fuego ígneo.",
		"res://assets/armas/lanzallamas.png"
	),
]
