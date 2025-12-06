# ProjectileFactory.gd
extends Node

# Precargar todas las escenas de proyectiles
const PERDIGON_SCENE = preload("res://scenes/Armas/Holded/Escopeta/perdigones.tscn")
const SNIPER_BULLET_SCENE = preload("res://scenes/Armas/Holded/Sniper/SniperBullet.tscn")
const CHAKRAM_SCENE = preload("res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn")
const DRON_PROYECTIL_SCENE = preload("res://scenes/Armas/Throweables/Dron/proyectildron.tscn")

# Tamaños iniciales de cada pool
const POOL_SIZE_PERDIGON = 30
const POOL_SIZE_SNIPER = 10
const POOL_SIZE_CHAKRAM = 5
const POOL_SIZE_DRON = 10

# Pools de proyectiles
var pool_perdigones: Array = []
var pool_sniper: Array = []
var pool_chakram: Array = []
var pool_dron: Array = []

# Contenedor de proyectiles activos
var proyectiles_container: Node

func _ready() -> void:
	_inicializar_pool(PERDIGON_SCENE, pool_perdigones, POOL_SIZE_PERDIGON)
	_inicializar_pool(SNIPER_BULLET_SCENE, pool_sniper, POOL_SIZE_SNIPER)
	_inicializar_pool(CHAKRAM_SCENE, pool_chakram, POOL_SIZE_CHAKRAM)
	_inicializar_pool(DRON_PROYECTIL_SCENE, pool_dron, POOL_SIZE_DRON)
	
	print("Pools inicializados:")
	print("  Perdigones: ", pool_perdigones.size())
	print("  Sniper: ", pool_sniper.size())
	print("  Chakram: ", pool_chakram.size())
	print("  Dron: ", pool_dron.size())

func _inicializar_pool(escena: PackedScene, pool: Array, cantidad: int) -> void:
	for i in cantidad:
		var proyectil = escena.instantiate()
		proyectil.process_mode = Node.PROCESS_MODE_DISABLED
		proyectil.visible = false
		
		var container = _get_container()
		if container:
			container.add_child(proyectil)
		
		# Conectar señal UNA SOLA VEZ aquí
		if proyectil.has_signal("destruido"):
			proyectil.destruido.connect(_on_proyectil_destruido.bind(proyectil))
		
		pool.append(proyectil)

func _get_container() -> Node:
	if proyectiles_container and is_instance_valid(proyectiles_container):
		return proyectiles_container
	
	var scene_root = get_tree().current_scene
	if not scene_root:
		return null
	
	proyectiles_container = scene_root.get_node_or_null("Proyectiles")
	
	if not proyectiles_container:
		proyectiles_container = Node2D.new()
		proyectiles_container.name = "Proyectiles"
		scene_root.add_child(proyectiles_container)
	
	return proyectiles_container

func _obtener_del_pool(pool: Array, escena: PackedScene) -> Node:
	for proyectil in pool:
		# Verificar validez ANTES de acceder a propiedades
		if not is_instance_valid(proyectil):
			continue
		
		if not proyectil.visible and proyectil.process_mode == Node.PROCESS_MODE_DISABLED:
			return proyectil
	
	# Pool agotado, crear nuevo
	print("Pool agotado, creando nuevo proyectil")
	var nuevo_proyectil = escena.instantiate()
	var container = _get_container()
	if container:
		container.add_child(nuevo_proyectil)
	
	if nuevo_proyectil.has_signal("destruido"):
		nuevo_proyectil.destruido.connect(_on_proyectil_destruido.bind(nuevo_proyectil))
	
	pool.append(nuevo_proyectil)
	return nuevo_proyectil

func _activar_proyectil(proyectil: Node) -> void:
	proyectil.visible = true
	proyectil.process_mode = Node.PROCESS_MODE_INHERIT

func _devolver_al_pool(proyectil: Node) -> void:
	if not is_instance_valid(proyectil):
		return
	
	proyectil.visible = false
	proyectil.process_mode = Node.PROCESS_MODE_DISABLED
	proyectil.global_position = Vector2(-10000, -10000)

# CALLBACK ÚNICO para todos los proyectiles
func _on_proyectil_destruido(proyectil: Node) -> void:
	_devolver_al_pool(proyectil)

# ========== ESCOPETA ==========
func crear_perdigon(posicion: Vector2, direccion: Vector2, daño: int, creador: Node = null) -> Node:
	var perdigon = _obtener_del_pool(pool_perdigones, PERDIGON_SCENE)
	
	perdigon.global_position = posicion
	perdigon.direccion = direccion.normalized()
	perdigon.daño = daño
	perdigon.creador = creador
	
	if perdigon.has_method("resetear"):
		perdigon.resetear()
	
	_activar_proyectil(perdigon)
	return perdigon

# ========== SNIPER ==========
func crear_bala_sniper(posicion: Vector2, direccion: Vector2, daño: int, velocidad: float = 600.0, area_mult: float = 1.0, nivel: int = 1) -> Node:
	var bala = _obtener_del_pool(pool_sniper, SNIPER_BULLET_SCENE)
	
	bala.global_position = posicion
	bala.direction = direccion.normalized()
	bala.damage = daño
	bala.speed = velocidad
	bala.area_multiplicador = area_mult
	bala.level = nivel
	
	# Resetear directamente (sin has())
	bala.hit_enemies.clear()
	
	if bala.has_method("_ajustar_tamaño"):
		bala._ajustar_tamaño()
	if bala.direction != Vector2.ZERO:
		bala.rotation = bala.direction.angle()
	
	if bala.has_node("TiempoVida"):
		bala.get_node("TiempoVida").start()
	
	_activar_proyectil(bala)
	return bala

# ========== CHAKRAM ==========
func crear_chakram(posicion: Vector2, direccion: Vector2, daño: int, max_rebotes: int, velocidad: float = 600.0, creador: Node = null) -> Node:
	var chakram = _obtener_del_pool(pool_chakram, CHAKRAM_SCENE)
	
	chakram.global_position = posicion
	chakram.rotation = direccion.normalized().angle()
	chakram.creador = creador
	chakram.max_rebotes = max_rebotes
	chakram.daño = daño
	chakram.speed = velocidad
	
	chakram.rebotes_realizados = 0
	chakram.enemigos_golpeados.clear()
	chakram.objetivo_actual = null
	
	_activar_proyectil(chakram)
	return chakram

# ========== DRON ==========
func crear_proyectil_dron(posicion: Vector2, direccion: Vector2, daño: float, velocidad_adicional: float = 0.0, creador: Node = null) -> Node:
	var proyectil = _obtener_del_pool(pool_dron, DRON_PROYECTIL_SCENE)
	
	if proyectil.has_method("setup"):
		proyectil.setup({
			"posicion": posicion,
			"direccion": direccion,
			"daño": daño,
			"velocidad_adicional": velocidad_adicional,
			"creador": creador
		})
	
	if proyectil.has_node("TiempoVida"):
		proyectil.get_node("TiempoVida").start(2.0)
	
	_activar_proyectil(proyectil)
	return proyectil

# ========== UTILIDADES ==========
func limpiar_proyectiles() -> void:
	for pool in [pool_perdigones, pool_sniper, pool_chakram, pool_dron]:
		for proyectil in pool:
			if proyectil.visible:
				_devolver_al_pool(proyectil)

func contar_proyectiles_activos() -> int:
	var count = 0
	for pool in [pool_perdigones, pool_sniper, pool_chakram, pool_dron]:
		for proyectil in pool:
			if proyectil.visible:
				count += 1
	return count

func obtener_stats_pools() -> Dictionary:
	return {
		"perdigones": {"total": pool_perdigones.size(), "activos": _contar_activos(pool_perdigones)},
		"sniper": {"total": pool_sniper.size(), "activos": _contar_activos(pool_sniper)},
		"chakram": {"total": pool_chakram.size(), "activos": _contar_activos(pool_chakram)},
		"dron": {"total": pool_dron.size(), "activos": _contar_activos(pool_dron)}
	}

func _contar_activos(pool: Array) -> int:
	var count = 0
	for proyectil in pool:
		if proyectil.visible:
			count += 1
	return count
