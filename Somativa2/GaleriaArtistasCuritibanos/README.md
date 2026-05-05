# Galeria de Artistas Curitibanos

Projeto da disciplina **Mobile Development iOS — PUCPR (2026)** — Avaliação Somativa.

App iOS em UIKit que apresenta uma galeria interativa de obras de artistas com forte ligação à cidade de Curitiba.

## Componentes do grupo

- Lucas Stopinski da Silva
- *(adicione os demais integrantes)*

## Como rodar

1. Abrir `GaleriaArtistasCuritibanos.xcodeproj` no Xcode 15+.
2. Selecionar um simulador iPhone ou iPad (iOS 16+).
3. `Cmd+R` para executar.

> O projeto é gerado a partir de `project.yml` via [xcodegen](https://github.com/yonaskolb/XcodeGen). Para regenerar: `xcodegen generate` na pasta raiz.

## Arquitetura

**MVC clássico** com separação física por responsabilidade:

```
GaleriaArtistasCuritibanos/
├── Models/         ObraDeArte (struct imutável conforme enunciado)
├── Data/           ObrasMockData (camada de dados estática, fácil de trocar por API)
├── Views/          ObraCollectionViewCell, PlaceholderImageGenerator
└── Controllers/    GaleriaViewController, DetalheObraViewController
```

A camada `Data` foi separada do Model para manter o struct livre de dependências e permitir migração futura para `URLSession`/JSON ou `Core Data` sem alterar a struct.

## Decisões de UI/UX

- **View Code (programático)** em vez de Storyboards: mantém versionamento amigável (sem merges em XML), favorece reuso e segue a tendência atual da comunidade iOS.
- **Grid responsiva**: 2 colunas em iPhone (compact) e 3 em iPad (regular), calculadas em runtime via `traitCollection.horizontalSizeClass`. Recalcula em rotação via `viewWillTransition`.
- **Imagens originais por obra** em `Assets.xcassets`: cada uma das 8 obras tem seu próprio imageset (`obra_apostolo_cataratas`, `obra_pinheirais`, …) com versões @1x/@2x/@3x. As ilustrações foram geradas proceduralmente em Python/Pillow para evocar cada obra (cenas distintas + paleta por estilo) — sem riscos de copyright e adequado a contexto acadêmico. Caso o asset não seja encontrado em runtime, há *fallback* para o `PlaceholderImageGenerator` (gradiente + SF Symbol).
- **Busca embutida na navigation bar** (`UISearchController`) em vez de uma `UISearchBar` solta no header — segue o padrão de apps nativos (Mail, Notes).
- **Animação sutil ao tocar na célula**: `scaleEffect(0.94)` + retorno antes do push, dá feedback tátil sem distrair.
- **Tela de detalhes em `UIScrollView`** com layout em `UIStackView` vertical: adapta a textos de descrição de qualquer tamanho.
- **Compartilhamento** via `UIActivityViewController` com texto convidativo + imagem da obra. `popoverPresentationController` configurado para iPad (caso contrário crashava).

## Funcionalidades

### Requisitos atendidos

- ✅ `struct ObraDeArte` com `titulo`, `artista`, `ano`, `estilo`, `imagemNome`, `descricao`
- ✅ `UICollectionView` com `UICollectionViewFlowLayout`
- ✅ Layout responsivo iPhone/iPad
- ✅ Célula com imagem, título e nome do artista
- ✅ Tela de detalhes ao tocar na obra
- ✅ Detalhes com imagem grande, título, artista, ano, estilo, descrição
- ✅ Botão de compartilhar via `UIActivityViewController`
- ✅ DataSource e Delegate da `UICollectionView`

### Desafios adicionais

- ✅ **Animação ao tocar** (scale + spring)
- ✅ **Barra de pesquisa** filtra por título ou artista (case-insensitive)

## Obras incluídas

| Obra | Artista | Ano | Estilo |
|------|---------|-----|--------|
| Apóstolo das Cataratas | Poty Lazzarotto | 1986 | Gravura |
| Pinheirais | Theodoro De Bona | 1948 | Pintura |
| Aldeia | Miguel Bakun | 1955 | Pintura |
| Esfera Urbana | Helena Wong | 2010 | Escultura |
| Imagens do Sertão | Loio-Pérsio | 1965 | Pintura |
| Autorretrato | Alfredo Andersen | 1900 | Pintura |
| Tigre Indiano | João Turin | 1928 | Escultura |
| Caboclos | Guido Viaro | 1950 | Pintura |

## Dificuldades encontradas

*(template para a apresentação — preencher com a experiência real)*

- **Cálculo de tamanho responsivo de células**: o `UICollectionViewFlowLayout` não oferece suporte direto a "X colunas", então foi necessário implementar `sizeForItemAt` calculando a partir da largura disponível, descontando insets e espaçamento.
- **Geração de placeholders**: ao invés de bundlar imagens, optamos por desenhar gradientes em runtime via `UIGraphicsImageRenderer`. Isso exigiu cuidado com o `CGContext` e o cálculo do ângulo do gradiente.
- **Compartilhamento no iPad**: sem configurar `popoverPresentationController.barButtonItem`, o `UIActivityViewController` crashava com NSInvalidArgumentException — descoberto e corrigido.

## Vídeo de apresentação

*(adicionar link do YouTube — não listado, 10–20min)*
