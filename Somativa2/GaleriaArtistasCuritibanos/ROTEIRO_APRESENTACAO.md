# Roteiro da Apresentação — Galeria de Artistas Curitibanos

**Disciplina:** Mobile Development iOS — PUCPR 2026
**Avaliação:** Somativa UIKit
**Duração alvo:** 12–15 minutos (limite permitido: 10–20 min)
**Integrantes:** Lucas Stopinski da Silva • Lucas Bruno e Silva

---

## Como usar este roteiro

- Cada bloco indica **quem fala**, **tempo aproximado**, **o que mostrar na tela** e **pontos a cobrir** (não é script literal — fale natural).
- Tenha o Xcode aberto com o projeto em uma janela e o simulador iPhone 17 em outra antes de começar a gravar.
- Use `Cmd + Shift + 5` no macOS para iniciar gravação de tela; ative o microfone.
- Se for usar Zoom/Meet para gravar com webcam dos dois, deixe a tela compartilhada como visão principal e os rostos em PiP no canto.

---

## Estrutura geral

| Bloco | Tempo | Quem fala | Tema |
|-------|-------|-----------|------|
| 1 | 0:00 – 0:30 | **Lucas Stopinski** | Abertura e apresentação |
| 2 | 0:30 – 1:30 | **Lucas Bruno** | Contexto e objetivos do projeto |
| 3 | 1:30 – 4:30 | **Lucas Stopinski** | Demonstração ao vivo no simulador |
| 4 | 4:30 – 5:30 | **Lucas Bruno** | Arquitetura MVC e estrutura de pastas |
| 5 | 5:30 – 6:30 | **Lucas Stopinski** | Modelo `ObraDeArte` e camada `Data` |
| 6 | 6:30 – 8:00 | **Lucas Bruno** | `UICollectionView`: DataSource, Delegate, FlowLayout |
| 7 | 8:00 – 9:00 | **Lucas Stopinski** | Célula custom + carregamento de imagens com fallback |
| 8 | 9:00 – 10:00 | **Lucas Bruno** | Barra de busca + animação na seleção |
| 9 | 10:00 – 11:30 | **Lucas Stopinski** | Tela de detalhes + compartilhamento |
| 10 | 11:30 – 13:00 | **Lucas Bruno** | Decisões de UI/UX e responsividade |
| 11 | 13:00 – 13:30 | **Lucas Stopinski** | Dificuldades encontradas |
| 12 | 13:30 – 14:00 | **Lucas Bruno** | Encerramento |

---

## Bloco 1 — Abertura (0:00 – 0:30) — **Lucas Stopinski**

**Mostrar:** webcam ou slide simples com nome do projeto.

**Falar:**
- "Olá, professor. Somos o Lucas Stopinski e o Lucas Bruno, da disciplina de Mobile Development iOS da PUCPR."
- "Este é o nosso projeto somativo: a **Galeria de Artistas Curitibanos** — um app iOS em UIKit que apresenta obras de oito artistas com forte ligação com Curitiba."
- "Nos próximos 14 minutos vamos mostrar o app rodando, explicar a arquitetura e fazer um walkthrough técnico do código."

---

## Bloco 2 — Contexto e objetivos (0:30 – 1:30) — **Lucas Bruno**

**Mostrar:** README aberto no editor ou no GitHub, focando na seção de objetivos.

**Falar:**
- "O objetivo da tarefa era desenvolver um app iOS com **UICollectionView** que valorizasse a produção artística local."
- "Escolhemos representar oito artistas que tiveram forte ligação com Curitiba, atravessando diferentes épocas e estilos — da pintura acadêmica do Alfredo Andersen do início do século XX até a escultura contemporânea da Helena Wong."
- Lista rápida: "Temos pinturas, gravuras e esculturas — então o app precisa lidar com obras visualmente bem diferentes."
- "Os requisitos obrigatórios eram: struct `ObraDeArte`, `UICollectionView` em grade, layout responsivo iPhone e iPad, tela de detalhes e compartilhamento via `UIActivityViewController`."
- "Implementamos também os dois desafios adicionais: busca por título/artista e animação ao tocar nas células."

---

## Bloco 3 — Demonstração ao vivo (1:30 – 4:30) — **Lucas Stopinski**

**Mostrar:** simulador iPhone 17 com o app rodando. Esse é o bloco mais longo, dê tempo para mostrar cada coisa com calma.

**Roteiro da demo:**

1. **Tela inicial** (~20s)
   - "Esta é a tela principal — um grid de 2 colunas mostrando as oito obras."
   - "Cada célula traz a imagem da obra, o título e o nome do artista."
   - Faça scroll suave pra cima e pra baixo.

2. **Busca** (~30s)
   - Toque na barra de busca no topo: "A busca está embutida na navigation bar, padrão de apps nativos como Mail e Notes."
   - Digite "Poty": "Filtra por artista em tempo real."
   - Limpe e digite "Pinheirais": "Funciona também por título."
   - Limpe a busca: "Tudo volta ao normal."

3. **Animação ao tocar** (~20s)
   - "Veja o que acontece quando toco numa célula — ela faz um leve scale antes de navegar."
   - Toque na obra do Poty Lazzarotto.

4. **Tela de detalhes** (~40s)
   - "Aqui temos a obra em tamanho maior, o título grande, o artista em destaque, estilo e ano nos metadados, e a descrição completa."
   - Faça scroll na descrição: "A tela é um `UIScrollView`, então funciona com textos longos."
   - Volte e abra outra (ex.: João Turin): "Cada obra tem sua descrição própria, contextualizando o artista e a importância dele."

5. **Compartilhamento** (~30s)
   - Toque no ícone de share no canto superior direito.
   - "O `UIActivityViewController` aparece com o texto convidando a conhecer mais artistas curitibanos, junto com a imagem da obra."
   - Cancele o compartilhamento e volte para a galeria.

6. **iPad (opcional, ~20s)**
   - Se houver tempo, mostre o app rodando no simulador iPad: "O mesmo app no iPad — note que agora são 3 colunas em vez de 2. O layout se adapta automaticamente."

---

## Bloco 4 — Arquitetura MVC (4:30 – 5:30) — **Lucas Bruno**

**Mostrar:** Navigator do Xcode (`Cmd+1`) com a árvore de pastas aberta.

**Falar:**
- "Decidimos seguir o MVC clássico, mas com separação física por responsabilidade em pastas."
- Aponte para cada pasta:
  - `Models/` → "Onde fica o struct `ObraDeArte`, totalmente livre de dependências de UIKit."
  - `Data/` → "Aqui está a fonte dos dados — hoje é um array estático, mas separamos para facilitar trocar por uma API ou Core Data no futuro sem mexer no model."
  - `Views/` → "Componentes visuais: a célula custom e o gerador de placeholders."
  - `Controllers/` → "Os dois view controllers: o da galeria e o de detalhes."
- "Optamos por **View Code** em vez de Storyboards. Isso facilita versionamento, evita conflitos de merge em XML e é a tendência da comunidade iOS hoje."

---

## Bloco 5 — Modelo e dados (5:30 – 6:30) — **Lucas Stopinski**

**Mostrar:** `Models/ObraDeArte.swift` e depois `Data/ObrasMockData.swift`.

**Falar (sobre ObraDeArte):**
- "O struct tem exatamente os seis campos que o enunciado pedia: título, artista, ano, estilo, nome da imagem e descrição."
- "Conformamos com `Hashable` para deixar a porta aberta para `UICollectionViewDiffableDataSource` se um dia decidirmos migrar."

**Falar (sobre ObrasMockData):**
- Scrolla pelo arquivo: "Aqui temos as oito obras com metadados reais — datas, estilos e descrições baseadas em pesquisa sobre cada artista."
- "Note que o `imagemNome` aponta diretamente para o nome do imageset no Asset Catalog: `poty_apostolo`, `debona_pinheirais`, e assim por diante. Cada obra tem sua imagem própria."

---

## Bloco 6 — UICollectionView (6:30 – 8:00) — **Lucas Bruno**

**Mostrar:** `Controllers/GaleriaViewController.swift`.

**Pontos a cobrir:**

1. **Setup do layout** (~20s)
   - Aponte para a `lazy var collectionView`: "Configuramos o `UICollectionViewFlowLayout` com espaçamento de 16 pontos entre linhas e 12 entre colunas."
   - "Registramos a célula com o reuse identifier que vamos usar no DataSource."

2. **DataSource** (~30s)
   - Vá até a extension `UICollectionViewDataSource`: "Implementamos os dois métodos obrigatórios."
   - `numberOfItemsInSection`: "Retorna a contagem de `obrasFiltradas` — note o nome, não é `todasObras` direto, porque a busca afeta isso."
   - `cellForItemAt`: "Aqui usamos `dequeueReusableCell(withReuseIdentifier:for:)` exatamente como o enunciado pedia, fazendo o reuso correto das células."

3. **FlowLayout responsivo** (~40s)
   - Vá até `sizeForItemAt`:
   - "Aqui está a parte interessante: o FlowLayout não tem suporte direto a 'X colunas', então calculamos manualmente."
   - "Pegamos a largura disponível, descontamos os insets das laterais, descontamos o espaçamento total entre colunas e dividimos pelo número de colunas — que é 2 no iPhone (size class compact) ou 3 no iPad (size class regular)."
   - Mostre o `viewWillTransition`: "Quando a tela rotaciona, invalidamos o layout para recalcular tudo."

---

## Bloco 7 — Célula e imagens com fallback (8:00 – 9:00) — **Lucas Stopinski**

**Mostrar:** `Views/ObraCollectionViewCell.swift` e depois `Views/PlaceholderImageGenerator.swift`.

**Pontos a cobrir:**

1. **ObraCollectionViewCell** (~30s)
   - "A célula tem três subviews: `UIImageView` quadrado em cima, label de título abaixo e label de artista logo embaixo."
   - "Auto Layout via `NSLayoutConstraint.activate` — sem stack view aqui porque a imagem precisa de constraint de aspect ratio próprio."
   - Aponte para `contentMode = .scaleAspectFill` + `clipsToBounds`: "Isso garante que imagens com proporções diferentes (vertical, horizontal) fiquem bem cortadas sem distorção."

2. **Método configure com fallback** (~30s)
   - "Esta é uma decisão de robustez que vale a pena destacar."
   - Mostre o `if let imagem = UIImage(named: obra.imagemNome)`:
   - "Primeiro tentamos carregar a imagem real do Asset Catalog. Se ela existir, usamos."
   - "Se por algum motivo a imagem não estiver no bundle — por exemplo, alguém removeu o asset — caímos no `PlaceholderImageGenerator`, que desenha um gradiente colorido derivado do estilo da obra com um SF Symbol no centro."
   - Abra rapidamente o `PlaceholderImageGenerator`: "Cores por estilo: gravura usa tons sépia, pintura usa tons quentes, escultura usa tons frios."
   - "O app **nunca crasha por falta de imagem** — pior cenário, mostra um placeholder bonito."

---

## Bloco 8 — Busca e animação (9:00 – 10:00) — **Lucas Bruno**

**Mostrar:** `Controllers/GaleriaViewController.swift` — busca e didSelect.

**Pontos a cobrir:**

1. **UISearchController** (~30s)
   - Aponte para `setupSearch`: "Usamos `UISearchController` integrado à `navigationItem.searchController` em vez de uma `UISearchBar` solta — é o padrão dos apps da Apple."
   - Mostre a extension `UISearchResultsUpdating`:
   - "A cada caractere digitado, filtramos `todasObras` por `titulo` ou `artista` com `localizedCaseInsensitiveContains` — acentos e maiúsculas/minúsculas são ignorados."
   - "Quando o texto está vazio, mostramos tudo de volta."

2. **Animação ao tocar** (~30s)
   - Vá até `didSelectItemAt`:
   - "Pegamos a célula tocada e aplicamos um `UIView.animate` em duas fases:"
   - "Primeiro um `scaleEffect(0.94)` em 0.12 segundos — a célula 'afunda' como se respondesse ao toque."
   - "Depois retornamos ao `.identity` em mais 0.12 segundos e só então fazemos o `push` para a tela de detalhes."
   - "Feedback tátil sutil, sem distrair, como acontece em apps modernos."

---

## Bloco 9 — Tela de detalhes e compartilhamento (10:00 – 11:30) — **Lucas Stopinski**

**Mostrar:** `Controllers/DetalheObraViewController.swift`.

**Pontos a cobrir:**

1. **Estrutura** (~30s)
   - "É um `UIScrollView` com um `UIStackView` vertical dentro — isso garante que descrições longas role sem cortar."
   - Aponte para o `init(obra:)`: "Recebemos a obra inteira via injeção de dependência no init, mantendo o controller desacoplado."

2. **Configuração visual** (~20s)
   - Mostre o método `configurar`: "Mesma lógica do fallback de imagem que vimos na célula, agora com tamanho maior."
   - "Os labels usam fontes do sistema com pesos diferentes — título em title1 bold, artista em title2 semibold em azul, metadados secundary, e a descrição em body."

3. **Compartilhamento** (~40s)
   - Vá até `compartilharTapped`:
   - "Montamos um texto convidativo: 'título — por artista. Conheça mais artistas curitibanos!'"
   - "Passamos o texto e a imagem da obra para o `UIActivityViewController`."
   - **Destaque**: "Esta linha aqui — `popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem` — é crítica no iPad. Sem ela, o sistema crasha ao tentar apresentar o share."
   - "Esse foi um detalhe que descobrimos testando no simulador de iPad."

---

## Bloco 10 — UI/UX e responsividade (11:30 – 13:00) — **Lucas Bruno**

**Mostrar:** alternar entre simulador iPhone e iPad lado a lado se possível, ou voltar ao README.

**Pontos a cobrir:**
- "Algumas decisões de UX que vale destacar:"
- **Responsividade**: "Não usamos device check (`UIDevice.current.userInterfaceIdiom`), e sim **size classes** (`traitCollection.horizontalSizeClass`). Isso significa que o app se adapta corretamente também em **iPad com split view** ou janela menor, não só por tipo de aparelho."
- **Imagens com proporções variadas**: "As 8 obras vieram de fontes diferentes — algumas verticais, algumas paisagísticas. O `contentMode = .scaleAspectFill` mantém a célula sempre quadrada e bonita."
- **Cores do sistema**: "Usamos `.systemBackground`, `.label`, `.secondaryLabel`, `.systemBlue` etc. — isso garante que o app funcione perfeitamente tanto em **modo claro quanto modo escuro** sem nenhuma configuração extra."
- **Navigation bar com large titles**: "Detalhe sutil mas que dá personalidade ao app — o título grande na home, padrão dos apps nativos."

---

## Bloco 11 — Dificuldades encontradas (13:00 – 13:30) — **Lucas Stopinski**

**Mostrar:** README aberto na seção "Dificuldades encontradas" ou continuar no código.

**Falar (rápido, 3 pontos):**
1. **Cálculo de tamanho de células**: "FlowLayout não tem 'X colunas' nativo, precisamos calcular manualmente."
2. **Crash no share do iPad**: "Demorou pra perceber que precisava do `popoverPresentationController.barButtonItem`."
3. **Diferentes proporções de imagem**: "Cada obra veio de uma fonte; resolvido com `scaleAspectFill` + `clipsToBounds`."

---

## Bloco 12 — Encerramento (13:30 – 14:00) — **Lucas Bruno**

**Mostrar:** simulador com a galeria aberta de novo, ou um slide com agradecimento.

**Falar:**
- "Pra fechar: o app cumpre todos os requisitos obrigatórios mais os dois desafios extras, com uma arquitetura limpa em MVC, totalmente em View Code, responsivo iPhone e iPad."
- "O código está no GitHub e o relatório técnico em PDF acompanha esta entrega."
- "Agradecemos pela atenção, professor. Qualquer dúvida estamos à disposição."

---

## Checklist antes de gravar

- [ ] Xcode 26+ aberto com o projeto `GaleriaArtistasCuritibanos.xcodeproj`
- [ ] Simulador **iPhone 17 (iOS 26.4)** com o app já buildado (`Cmd + R` antes da gravação)
- [ ] Simulador **iPad Pro 13-inch (M4)** disponível para o bloco 10 (opcional)
- [ ] Asset Catalog visível com as 8 imagens (`Cmd + 1` no Xcode, expandir Assets.xcassets)
- [ ] Microfone testado, sem ruído de fundo
- [ ] Resolução de gravação: pelo menos 1080p
- [ ] Falar com clareza, sem pressa — 14 minutos cabem confortavelmente no limite de 20

## Dicas finais

- **Divisão de tela ideal**: 70% Xcode/simulador, 30% rosto do apresentador em PiP no canto inferior direito.
- **Atalhos úteis durante a gravação**:
  - `Cmd + 1` no Xcode: abre Project Navigator
  - `Cmd + 7`: abre Breakpoint Navigator (não usar)
  - `Cmd + 0`: esconde Navigator
  - `Cmd + Opt + 0`: esconde Inspector (mais espaço)
- **Se errar uma fala**: pause uns 2 segundos e refaça a frase. Na edição você corta o erro facilmente.
- **Sobre transições entre apresentadores**: combine sinais (ex.: "passo pra você, Bruno") para a edição ficar natural.
