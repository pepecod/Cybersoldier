# Menu.gd
extends Control

@onready var musica       : AudioStreamPlayer2D = $AudioMusica
@onready var video := $VideoPlayer
@onready var sfx_click    : AudioStreamPlayer2D = $SFXClick
@onready var main_menu    : VBoxContainer        = $CapaMenu/VBoxContainer
@onready var weapon_menu  : Control              = $CapaMenu/JugarMenu
@onready var decoracion   : TextureRect          = $FondoMain
@onready var decoracion2  : CanvasLayer          = $CapaMenu/JugarMenu/CapaMenu2

# Botones de selección de arma
@onready var btn_sel_escopeta : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerEscopeta/Selescopeta
@onready var btn_sel_chakram  : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerChakram/Selchakram
@onready var btn_sel_sniper   : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerSniper/Selsniper

# Botones del MainMenu
@onready var btn_jugar      : Button = $CapaMenu/VBoxContainer/Jugar
@onready var btn_opciones   : Button = $CapaMenu/VBoxContainer/Opciones
@onready var btn_salir      : Button = $CapaMenu/VBoxContainer/Salir

# Botón “Volver” dentro de JugarMenu
@onready var btn_volver     : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/VolverMenu2

# Ruta de la escena de juego (ajusta si tu path difiere)
const GAME_SCENE_PATH : String = "res://scenes/game.tscn"

@export var duracion_intro: float = 16.0

func _ready() -> void:
	# ── Ocultar todo al arrancar ─────────────────────────
	decoracion.visible    = false
	main_menu.visible     = false
	weapon_menu.visible   = false
	decoracion2.visible   = false

	# ── Arrancar música y vídeo ─────────────────────────
	musica.play()
	video.play()

	# ── Tras la intro, muestro el MainMenu ──────────────
	await get_tree().create_timer(duracion_intro).timeout
	_show_main_menu()

	# ── Conectar señales de navegación ──────────────────
	btn_jugar.pressed.connect(_on_main_jugar_pressed)
	btn_opciones.pressed.connect(_on_main_opciones_pressed)
	btn_salir.pressed.connect(_on_main_salir_pressed)
	btn_volver.pressed.connect(_on_back_to_main)

	# ── Conectar selección de arma ──────────────────────
	btn_sel_escopeta.pressed.connect(_on_sel_escopeta)
	btn_sel_chakram.pressed.connect(_on_sel_chakram)
	btn_sel_sniper.pressed.connect(_on_sel_sniper)
	#100% hay una manera mejor usando etiquetas como la de enemigo pero de moomento asi
	for btn in [btn_jugar, btn_opciones, btn_salir, btn_volver, btn_sel_escopeta, btn_sel_chakram, btn_sel_sniper]:
		btn.pressed.connect(_play_click_sfx)

func _play_click_sfx() -> void:
	sfx_click.play()

func _show_main_menu() -> void:
	video.visible       = false
	decoracion.visible  = true
	main_menu.visible   = true
	weapon_menu.visible = false
	decoracion2.visible = false

func _on_main_jugar_pressed() -> void:
	main_menu.visible   = false
	weapon_menu.visible = true
	decoracion2.visible = true

func _on_main_opciones_pressed() -> void:
	# Aquí más adelante mostrarás el submenu Opciones
	pass

func _on_main_salir_pressed() -> void:
	get_tree().quit()

func _on_back_to_main() -> void:
	_show_main_menu()

# ── Handlers de selección ─────────────────────────────
func _on_sel_escopeta() -> void:
	GameState.selected_weapon_index = 0
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_sel_chakram() -> void:
	GameState.selected_weapon_index = 1
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_sel_sniper() -> void:
	GameState.selected_weapon_index = 2
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
