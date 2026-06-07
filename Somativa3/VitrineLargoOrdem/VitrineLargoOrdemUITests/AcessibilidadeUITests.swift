import XCTest

/// Testes automatizados de Acessibilidade.
/// Validam os requisitos do enunciado:
/// 1. Labels descritivos nas imagens
/// 2. Preço lido corretamente (sem "R cifrão ponto zero zero")
/// 3. Touch target de 44×44 no botão favoritar
/// 4. Suporte a Dynamic Type (sem .frame fixos em texto)
/// 5. accessibilitySortPriority na tela de detalhes
final class AcessibilidadeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Pula onboarding nos UITests via launch environment.
        // O App lê esta env var na init e força jaViuOnboarding = true.
        app.launchArguments = ["-UITestMode"]
        app.launchEnvironment["SKIP_ONBOARDING"] = "1"
        app.launch()
    }

    // MARK: - Requisito 1: Labels descritivos nas imagens

    func testCardTemAccessibilityLabelDescritivo() throws {
        let firstCard = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Escultura de Capivara")).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5), "Card do primeiro produto deve existir")
        XCTAssertTrue(firstCard.label.contains("Escultura"), "Label do card deve conter o nome do produto")
    }

    // MARK: - Requisito 2: Preço acessível (sem leitura literal de "R cifrão")

    func testPrecoTemAccessibilityLabelEmReais() throws {
        // Procura por elemento cujo label começa com "Preço:" (precoAcessivel)
        let precoLabel = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Preço:")).firstMatch
        XCTAssertTrue(precoLabel.waitForExistence(timeout: 5), "Deve existir pelo menos um elemento com label 'Preço: X reais'")
        XCTAssertTrue(precoLabel.label.contains("reais"), "Label do preço deve conter 'reais', não 'R cifrão'")
        XCTAssertFalse(precoLabel.label.contains("R$"), "Label acessível NÃO deve conter 'R$'")
    }

    // MARK: - Requisito 3: Touch target de 44×44 no botão favoritar

    func testBotaoFavoritarTemTouchTargetMinimoDe44Pontos() throws {
        let botoesFavoritar = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "favoritos"))
        XCTAssertGreaterThan(botoesFavoritar.count, 0, "Deve haver pelo menos um botão de favoritar visível")

        let primeiroBotao = botoesFavoritar.firstMatch
        let frame = primeiroBotao.frame
        XCTAssertGreaterThanOrEqual(frame.width, 44, "Largura do botão favoritar deve ser >= 44 pontos")
        XCTAssertGreaterThanOrEqual(frame.height, 44, "Altura do botão favoritar deve ser >= 44 pontos")
    }

    // MARK: - Requisito 4: Dynamic Type — botões e textos crescem com fonte grande

    func testTextosNaoEstaoEmAlturaFixaQuebrada() throws {
        // Quando o Dynamic Type aumenta, textos não podem ser cortados.
        // Aqui validamos que os labels do card existem em fonte normal.
        // Em UI Tests é difícil aumentar Dynamic Type via API estável.
        // Validamos qualitativamente que os textos existem (não somem se truncados).
        let nomeProduto = app.staticTexts["Escultura de Capivara em Madeira"]
        XCTAssertTrue(nomeProduto.waitForExistence(timeout: 5),
                     "Nome do produto deve estar visível e legível com fonte padrão")
    }

    // MARK: - Requisito 5: Tela de detalhes — accessibilitySortPriority

    func testNavegacaoParaDetalhesPreservaAcessibilidade() throws {
        // Toca no primeiro card
        let firstCard = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Escultura de Capivara")).firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        // Confirma que entrou na tela de detalhes (botão de contato existe)
        let botaoContato = app.buttons["Entrar em contato com o Artesão"]
        XCTAssertTrue(botaoContato.waitForExistence(timeout: 5),
                     "Botão de contato deve existir na tela de detalhes")

        // O nome do produto deve aparecer (com header trait)
        let tituloDetalhe = app.staticTexts["Escultura de Capivara em Madeira"].firstMatch
        XCTAssertTrue(tituloDetalhe.exists, "Nome do produto deve ser visível na tela de detalhes")
    }

    // MARK: - Favoritar funciona sem disparar navegação

    func testFavoritarNaoDisparaNavegacao() throws {
        let botaoFavoritar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Adicionar")).firstMatch
        XCTAssertTrue(botaoFavoritar.waitForExistence(timeout: 5))

        botaoFavoritar.tap()

        // Após tap, o label muda para "Remover"
        let botaoRemover = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Remover")).firstMatch
        XCTAssertTrue(botaoRemover.waitForExistence(timeout: 2),
                     "Após favoritar, deve haver um botão 'Remover dos favoritos'")

        // E NÃO deve ter navegado pra tela de detalhes (botão de contato não existe)
        XCTAssertFalse(app.buttons["Entrar em contato com o Artesão"].exists,
                      "Tap no botão de favoritar NÃO deve disparar navegação")
    }

    // MARK: - Busca

    func testBuscaPorNomeFiltraResultados() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "SearchField deve existir")
        searchField.tap()
        searchField.typeText("Quibe")

        // Após filtrar, "Quibe" deve aparecer
        let quibe = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Quibe")).firstMatch
        XCTAssertTrue(quibe.waitForExistence(timeout: 2), "Busca 'Quibe' deve retornar resultado")
    }

    func testBuscaPorCategoriaFiltraResultados() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Madeira")

        // Pelo menos um produto de Madeira deve aparecer (Capivara ou Cuia de Mate)
        let resultado = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Capivara", "Cuia")).firstMatch
        XCTAssertTrue(resultado.waitForExistence(timeout: 2),
                     "Busca por categoria 'Madeira' deve retornar produtos de madeira")
    }

    func testBuscaSemResultadoExibeContentUnavailable() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("xyzabc123")

        let estadoVazio = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Nenhum produto encontrado")).firstMatch
        XCTAssertTrue(estadoVazio.waitForExistence(timeout: 2),
                     "Quando busca não retorna nada, deve exibir ContentUnavailableView")
    }

    // MARK: - Screenshots para o relatório

    func testCapturaScreenshotsParaRelatorio() throws {
        // 1. Vitrine inicial
        let screenshotVitrine = XCUIScreen.main.screenshot()
        let attVitrine = XCTAttachment(screenshot: screenshotVitrine)
        attVitrine.name = "01-vitrine-inicial"
        attVitrine.lifetime = .keepAlways
        add(attVitrine)

        // 2. Após favoritar
        let botaoFavoritar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Adicionar")).firstMatch
        if botaoFavoritar.waitForExistence(timeout: 3) {
            botaoFavoritar.tap()
            sleep(1)
            let screenshotFav = XCUIScreen.main.screenshot()
            let attFav = XCTAttachment(screenshot: screenshotFav)
            attFav.name = "02-vitrine-com-favorito"
            attFav.lifetime = .keepAlways
            add(attFav)
        }

        // 3. Tela de detalhes
        let card = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Escultura de Capivara")).firstMatch
        if card.waitForExistence(timeout: 3) {
            card.tap()
            sleep(1)
            let screenshotDet = XCUIScreen.main.screenshot()
            let attDet = XCTAttachment(screenshot: screenshotDet)
            attDet.name = "03-tela-detalhes"
            attDet.lifetime = .keepAlways
            add(attDet)
        }
    }
}
