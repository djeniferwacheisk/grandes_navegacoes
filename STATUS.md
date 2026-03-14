# Grandes Navegacoes - Status do Projeto

## Visao Geral
Jogo educativo 2D side-scrolling pixel art sobre as Grandes Navegacoes portuguesas.
Engine: Godot 4.6.1 | Resolucao: 320x180

---

## ETAPA 1 - Base do Projeto
- [x] Estrutura de pastas
- [x] project.godot configurado (resolucao, input, autoloads)
- [x] GameManager (estado global, inventario, save/load)
- [x] AudioManager (musica com fade, SFX)
- [x] SceneManager (transicoes com fade)

## ETAPA 2 - Jogador e Movimentacao
- [x] Player CharacterBody2D com WASD + pulo
- [x] Sistema de estados (EXPLORING, IN_PUZZLE, IN_DIALOG, IN_SHIP)
- [x] Area2D para deteccao de interagiveis
- [x] Indicador [E] ao se aproximar de interagiveis
- [ ] Sprites e animacoes do cartografo (usando placeholders)

## ETAPA 3 - Sistemas Core
- [x] Sistema de dialogo (typewriter, JSON, retratos)
- [x] HUD (bussola, minimapa, objetivos)
- [x] Menu principal (Jogar, Configuracoes, Sair)
- [x] Menu de pausa (ESC)
- [x] Configuracoes (volume musica/SFX)
- [x] Sistema de inventario basico
- [ ] Fonte pixel art customizada
- [ ] Efeitos de tinta no HUD

## ETAPA 4 - Fase 1: Escola de Sagres
- [x] Cenario com porto, treinamento, observatorio
- [x] Parallax background (ceu, mar)
- [x] NPCs (Mestre Navegador, marinheiros)
- [x] Cutscene de introducao
- [x] Puzzle 1: Bussola e Ventos (rotacao + ventos)
- [x] Puzzle 2: Navegacao da Caravela (top-down, rochedos, mapas)
- [x] Puzzle 3: Astrolabio e Estrelas (alinhamento, mapa da rota)
- [x] Transicao de fim de fase
- [x] Tela de mapa revelado
- [ ] Tileset grafico (usando ColorRect placeholders)
- [ ] Sprites de personagens (usando placeholders)
- [ ] Musica e efeitos sonoros
- [ ] Animacoes de bandeiras no puzzle da bussola

## ETAPA 5 - Fase 2: Periplo Africano (FUTURA)
- [ ] Exploracao costeira com registro de pontos
- [ ] Minigame de escambo (drag-and-drop)
- [ ] Puzzle do mapa fenicio (remontar pecas)
- [ ] NPCs locais e ambientacao africana
- [ ] Dialogos da Fase 2

## ETAPA 6 - Fase 3: Cabo das Tormentas (FUTURA)
- [ ] Sistema de tempestades (chuva, raios, ondas)
- [ ] Navegacao entre faixas do mar
- [ ] Minigame de reparo de velas (QTE)
- [ ] Puzzle de correntes maritimas

## ETAPA 7 - Fase 4: Rumo as Indias (FUTURA)
- [ ] Sistema de recursos (agua, comida, moral)
- [ ] Navegacao com moncoes
- [ ] Puzzle diplomatico em Calecute
- [ ] Ilhas para coleta de recursos

## ETAPA 8 - Fase 5: Chegada ao Brasil (FUTURA)
- [ ] Registro da costa brasileira
- [ ] Interacao com indigenas
- [ ] Puzzle da cruz de posse
- [ ] Finalizacao narrativa e creditos

## ETAPA 9 - Polimento (FUTURA)
- [ ] HUD final com efeitos de tinta
- [ ] Diario de bordo ilustrado
- [ ] Balanceamento de dificuldade
- [ ] Otimizacao de performance
- [ ] Trilha sonora e mixagem final
