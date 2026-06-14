extends Node2D

signal puzzle_completed
@export var spritesheet_setas: Texture2D
@export var tamanho_da_seta: int = 32 
@export var tamanho_sequencia: int = 5
var direcoes = ["cima", "direita", "baixo", "esquerda"]

var sequencia_correta: Array = []
var indice_atual: int = 0
var progresso_total: int = 0
var puzzle_ativo: bool = false

# Dicionários que vão guardar os frames na memória
var texturas_apagadas = {}
var texturas_acesas = {}
var texturas_erro = {}

@onready var sequencia_container = $SequenciaContainer
@onready var barra_progresso = $ProgressBar
@onready var anim_player = $AnimationPlayer
@onready var boot_sprite = $BootSprite
@onready var acesso_garantido_sprite = $AcessoGarantidoSprite
@onready var texto_explicativo = $Label

# Pré-carrega a cena das setinhas na tela (que contém apenas um TextureRect)
var cena_seta_tela = preload("res://scenes/minigames/setas_tela.tscn")

func _ready():
	# Corta o PNG em frames na memória assim que o puzzle abre
	fatiar_spritesheet()
	barra_progresso.max_value = 100
	barra_progresso.value = 0
	acesso_garantido_sprite.hide()
	texto_explicativo.hide()
	$ControleContainer/ControleBase/BtnUp.pressed.connect(func(): _on_botao_pressionado("cima"))
	$ControleContainer/ControleBase/BtnRight.pressed.connect(func(): _on_botao_pressionado("direita"))
	$ControleContainer/ControleBase/BtnDown.pressed.connect(func(): _on_botao_pressionado("baixo"))
	$ControleContainer/ControleBase/BtnLeft.pressed.connect(func(): _on_botao_pressionado("esquerda"))
		
	iniciar_computador()
	
func iniciar_computador():
	AudioManager.play_boot()
	puzzle_ativo = false
	# Esconde os elementos do puzzle para o boot aparecer limpo
	boot_sprite.show()
	texto_explicativo.hide()
	sequencia_container.hide()
	barra_progresso.hide()
	acesso_garantido_sprite.hide()

	if anim_player.has_animation("boot"):
		anim_player.play("boot")
		await anim_player.animation_finished
	
	AudioManager.play_puzzle()
	boot_sprite.hide()
	sequencia_container.show()
	barra_progresso.show()
	texto_explicativo.show()
	puzzle_ativo = true
	gerar_nova_sequencia()


func fatiar_spritesheet():
	for i in range(direcoes.size()):
		var dir = direcoes[i]
		# Linha 0 (Apagada) -> Frame da coluna i, linha 0
		texturas_apagadas[dir] = criar_recorte_atlas(i, 0)
		# Linha 1 (Acesa) -> Frame da coluna i, linha 1
		texturas_acesas[dir] = criar_recorte_atlas(i, 1)
		# Linha 2 (Erro) -> Frame da coluna i, linha 2
		texturas_erro[dir] = criar_recorte_atlas(i, 2)
# Função que calcula a posição exata (X, Y) do frame e cria o Atlas correspondente
func criar_recorte_atlas(coluna: int, linha: int) -> AtlasTexture:
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = spritesheet_setas
	
	# Calcula a área (X, Y, Largura, Altura) do frame
	atlas_tex.region = Rect2(
		coluna * tamanho_da_seta, 
		linha * tamanho_da_seta, 
		tamanho_da_seta, 
		tamanho_da_seta
	)
	return atlas_tex

func gerar_nova_sequencia():
	if not puzzle_ativo: return
	
	sequencia_correta.clear()
	indice_atual = 0
	
	for child in sequencia_container.get_children():
		child.queue_free()
	
	var ultima_direcao: String = ""
	
	for i in range(tamanho_sequencia):
		var dir_aleatoria = direcoes[randi() % direcoes.size()]
		while dir_aleatoria == ultima_direcao and direcoes.size() > 1:
			dir_aleatoria = direcoes[randi() % direcoes.size()]
		ultima_direcao = dir_aleatoria
		sequencia_correta.append(dir_aleatoria)
		
		var nova_seta = cena_seta_tela.instantiate() as TextureRect
		nova_seta.texture = texturas_apagadas[dir_aleatoria]
		sequencia_container.add_child(nova_seta)

func _on_botao_pressionado(direcao_clicada: String):
	if not puzzle_ativo or progresso_total >= 100:
		return
		
	if direcao_clicada == sequencia_correta[indice_atual]:
		AudioManager.play_correct()
		# ACERTOU: Transforma a seta atual em ACERTO (acesa)
		var seta_ui = sequencia_container.get_child(indice_atual) as TextureRect
		seta_ui.texture = texturas_acesas[direcao_clicada]
		
		indice_atual += 1
		
		if indice_atual == tamanho_sequencia:
			AudioManager.play_sequence()
			rodada_completada()
	else:
		# ERROU: Transforma a seta atual em ERRO (vermelha)
		AudioManager.play_wrong()
		var seta_ui = sequencia_container.get_child(indice_atual) as TextureRect
		seta_ui.texture = texturas_erro[sequencia_correta[indice_atual]]
		
		puzzle_ativo = false
		await get_tree().create_timer(0.4).timeout
		puzzle_ativo = true
		gerar_nova_sequencia()

func rodada_completada():
	progresso_total += 25
	
	var tween = create_tween()
	tween.tween_property(barra_progresso, "value", progresso_total, 0.4).set_trans(Tween.TRANS_LINEAR)
	
	if progresso_total >= 100:
		await tween.finished
		puzzle_concluido()
	else:
		puzzle_ativo = false
		await get_tree().create_timer(0.5).timeout
		puzzle_ativo = true
		gerar_nova_sequencia()
func puzzle_concluido():
	puzzle_ativo = false
	AudioManager.play_win()
	sequencia_container.hide()
	barra_progresso.hide()
	texto_explicativo.hide()
	acesso_garantido_sprite.show()
	if anim_player.has_animation("acesso_garantido"):
		anim_player.play("acesso_garantido")
		await anim_player.animation_finished
		
	puzzle_completed.emit()
	get_tree().paused = false
	queue_free()
