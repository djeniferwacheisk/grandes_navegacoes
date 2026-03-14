# Grandes Navegacoes

Jogo educativo 2D sobre as Grandes Navegacoes portuguesas, feito em Godot 4.6.

O jogador controla um jovem cartografo que se junta as expedicoes maritimas para mapear o mundo. A Fase 1 (Escola de Sagres) esta implementada com 3 puzzles interativos.

---

## Pre-requisitos

- **Godot 4.6.1** (versao estavel)
  - Download: https://godotengine.org/download
  - Ou via mise: `mise install godot@4.6.1-stable`

---

## Como rodar

### Pelo editor (recomendado para desenvolvimento)

```bash
# Abrir o editor do Godot no projeto
godot --path grandes_navegacoes/ --editor
```

Depois, no editor, pressione **F5** (ou o botao de Play no canto superior direito) para rodar o jogo.

### Direto pelo terminal (sem abrir o editor)

```bash
# Rodar o jogo diretamente
godot --path grandes_navegacoes/
```

### Importar pela primeira vez

Se for a primeira vez abrindo o projeto, o Godot precisa importar os recursos:

```bash
# Importar recursos (headless, sem interface)
godot --headless --import --path grandes_navegacoes/
```

---

## Controles

| Tecla | Acao |
|-------|------|
| W / A / S / D | Mover o personagem |
| Space | Pular |
| E | Interagir com NPCs/objetos |
| F | Abrir mapa |
| ESC | Menu de pausa |

Nos puzzles, use o **mouse** para interagir (clicar, arrastar) e **E** para confirmar acoes.

---

## Estrutura do Projeto

```
grandes_navegacoes/
├── project.godot              # Configuracao principal do Godot
├── STATUS.md                  # Progresso das etapas
├── assets/                    # Sprites, audio, fontes (placeholders por enquanto)
├── scenes/
│   ├── main/                  # Cena principal e tela de fim de fase
│   ├── menus/                 # Menu principal, pausa, configuracoes
│   ├── player/                # Personagem jogavel (CharacterBody2D)
│   ├── hud/                   # Interface: bussola, minimapa, objetivos
│   ├── puzzles/               # 3 puzzles da Fase 1
│   │   ├── compass_puzzle     # Puzzle da bussola e ventos
│   │   ├── ship_navigation    # Navegacao da caravela
│   │   └── astrolabe_puzzle   # Puzzle do astrolabio e estrelas
│   ├── npcs/                  # NPCs com sistema de dialogo
│   ├── levels/                # Cenarios das fases
│   └── ui/                    # Caixa de dialogo
├── scripts/
│   ├── autoload/              # Singletons globais
│   │   ├── game_manager.gd    # Estado do jogo, inventario, save/load
│   │   ├── audio_manager.gd   # Musica e efeitos sonoros
│   │   └── scene_manager.gd   # Transicoes entre cenas
│   └── resources/             # Classes Resource customizadas
└── data/
    └── dialogs/               # Dialogos em JSON
```

---

## Fluxo do Jogo (Fase 1)

1. **Menu Principal** - Jogar / Configuracoes / Sair
2. **Escola de Sagres** - Cenario principal com 3 areas
3. **Puzzle 1: Bussola e Ventos** - Girar bussola ate apontar Norte + associar ventos
4. **Puzzle 2: Navegacao da Caravela** - Navegar entre rochedos, coletar 3 mapas
5. **Puzzle 3: Astrolabio e Estrelas** - Alinhar mira com 3 estrelas no ceu
6. **Tela de Conclusao** - Texto final + revelacao de peca do mapa-mundi

---

## Comandos uteis do Godot

```bash
# Abrir o editor
godot --editor --path grandes_navegacoes/

# Rodar o jogo sem editor
godot --path grandes_navegacoes/

# Rodar uma cena especifica
godot --path grandes_navegacoes/ scenes/puzzles/compass_puzzle.tscn

# Exportar o jogo (precisa configurar export preset no editor antes)
godot --headless --export-release "Linux" grandes_navegacoes.x86_64

# Verificar erros de script
godot --headless --check-only --path grandes_navegacoes/

# Importar recursos sem abrir o editor
godot --headless --import --path grandes_navegacoes/
```

---

## Estado Atual

A Fase 1 esta implementada com **placeholders visuais** (retangulos coloridos no lugar de sprites). O jogo e funcional e jogavel. Veja `STATUS.md` para o progresso detalhado de cada etapa.

### Proximos passos
- Substituir placeholders por sprites pixel art
- Adicionar musica e efeitos sonoros
- Implementar Fases 2-5
