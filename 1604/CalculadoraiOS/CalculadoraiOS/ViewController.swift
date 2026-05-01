import UIKit

// MARK: - Botão circular customizado

final class CircleButton: UIButton {

    enum Estilo {
        case numero       // cinza escuro
        case funcao       // cinza claro (AC, %, ⌫, etc.)
        case operacao     // laranja (÷ × − + =)
        case cientifico   // cinza muito escuro (sci buttons)
    }

    private let estilo: Estilo
    private var pillShape: Bool = false

    init(titulo: String, estilo: Estilo, pillShape: Bool = false) {
        self.estilo = estilo
        self.pillShape = pillShape
        super.init(frame: .zero)
        configurar(titulo: titulo)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func configurar(titulo: String) {
        setTitle(titulo, for: .normal)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.lineBreakMode = .byClipping
        titleLabel?.numberOfLines = 1
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)

        switch estilo {
        case .numero:
            backgroundColor = UIColor(white: 0.20, alpha: 1)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 32, weight: .regular)
        case .funcao:
            backgroundColor = UIColor(white: 0.65, alpha: 1)
            setTitleColor(.black, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 26, weight: .regular)
        case .operacao:
            backgroundColor = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 32, weight: .regular)
        case .cientifico:
            backgroundColor = UIColor(white: 0.30, alpha: 1)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        }
    }

    /// Marca o botão como "selecionado" (operação pendente / 2nd ativo)
    func definirSelecionado(_ selecionado: Bool) {
        guard estilo == .operacao || estilo == .cientifico else { return }
        if selecionado {
            backgroundColor = .white
            setTitleColor(estilo == .operacao
                          ? UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)
                          : .black,
                          for: .normal)
        } else {
            configurar(titulo: currentTitle ?? "")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = pillShape ? min(bounds.height, bounds.width) / 2
                                       : bounds.height / 2
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.08) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }
}

// MARK: - View Controller principal

class ViewController: UIViewController {

    private let engine = CalculatorEngine()

    // MARK: UI - Display

    private let lblExpressao: UILabel = {
        let l = UILabel()
        l.text = " "
        l.textColor = UIColor(white: 1, alpha: 0.45)
        l.font = .systemFont(ofSize: 24, weight: .light)
        l.textAlignment = .right
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.4
        return l
    }()

    private let lblDisplay: UILabel = {
        let l = UILabel()
        l.text = "0"
        l.textColor = .white
        l.font = .systemFont(ofSize: 80, weight: .light)
        l.textAlignment = .right
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.35
        l.numberOfLines = 1
        return l
    }()

    private let lblIndicadores: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textAlignment = .left
        return l
    }()

    private lazy var btnHistorico: UIButton = {
        let b = UIButton(type: .system)
        let img = UIImage(systemName: "clock.arrow.circlepath")
        b.setImage(img, for: .normal)
        b.tintColor = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)
        b.addTarget(self, action: #selector(tocouHistorico), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: Containers para teclados

    private var stackRetrato: UIStackView?
    private var stackPaisagem: UIStackView?
    private var teclaACClear: CircleButton?    // muda entre AC e C
    private var teclaSegunda: CircleButton?    // 2nd toggle
    private var teclaRadDeg: CircleButton?     // mostra Rad ou Deg

    private var botoesOperacao: [String: CircleButton] = [:]      // para destacar a pendente
    private var botoesUnariosTrig: [String: CircleButton] = [:]   // para trocar quando 2nd ativa

    private var operacaoDestacada: String?

    // Compose top bar (indicadores, expressão, display, histórico)
    private var topStack: UIStackView!

    // MARK: Ciclo de vida

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        montarTopo()
        montarTecladoRetrato()
        montarTecladoPaisagem()
        atualizarLayoutParaOrientacao()
        atualizarUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.atualizarLayoutParaOrientacao(size: size)
        })
    }

    // MARK: Montagem do topo

    private func montarTopo() {
        let barraTopo = UIStackView(arrangedSubviews: [lblIndicadores, btnHistorico])
        barraTopo.axis = .horizontal
        barraTopo.distribution = .equalSpacing
        barraTopo.alignment = .center

        topStack = UIStackView(arrangedSubviews: [barraTopo, lblExpressao, lblDisplay])
        topStack.axis = .vertical
        topStack.spacing = 6
        topStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStack)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            topStack.topAnchor.constraint(equalTo: safe.topAnchor, constant: 4),
            btnHistorico.widthAnchor.constraint(equalToConstant: 32),
            btnHistorico.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Swipe no display = backspace
        let swipeL = UISwipeGestureRecognizer(target: self, action: #selector(swipeDisplay))
        swipeL.direction = .left
        let swipeR = UISwipeGestureRecognizer(target: self, action: #selector(swipeDisplay))
        swipeR.direction = .right
        lblDisplay.isUserInteractionEnabled = true
        lblDisplay.addGestureRecognizer(swipeL)
        lblDisplay.addGestureRecognizer(swipeR)
    }

    // MARK: Teclado retrato

    private struct Tecla {
        let titulo: String
        let estilo: CircleButton.Estilo
        let acao: Selector
        var widthRatio: CGFloat = 1   // para o "0" duplo no retrato
    }

    private func montarTecladoRetrato() {
        let linhas: [[Tecla]] = [
            [
                Tecla(titulo: "AC", estilo: .funcao, acao: #selector(tocouLimpar)),
                Tecla(titulo: "+/-", estilo: .funcao, acao: #selector(tocouSinal)),
                Tecla(titulo: "%",  estilo: .funcao, acao: #selector(tocouPercentual)),
                Tecla(titulo: "÷",  estilo: .operacao, acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "7", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "8", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "9", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "×", estilo: .operacao, acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "4", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "5", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "6", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "−", estilo: .operacao, acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "1", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "2", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "3", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "+", estilo: .operacao, acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "0", estilo: .numero,  acao: #selector(tocouDigito(_:)), widthRatio: 2),
                Tecla(titulo: ".", estilo: .numero,  acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "=", estilo: .operacao, acao: #selector(tocouIgual)),
            ],
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
        ])

        for linha in linhas {
            let h = UIStackView()
            h.axis = .horizontal
            h.spacing = 14
            h.distribution = .fill
            for tecla in linha {
                let btn = CircleButton(titulo: tecla.titulo, estilo: tecla.estilo, pillShape: tecla.widthRatio > 1)
                btn.addTarget(self, action: tecla.acao, for: .touchUpInside)
                h.addArrangedSubview(btn)
                if tecla.widthRatio == 1 {
                    btn.heightAnchor.constraint(equalTo: btn.widthAnchor).isActive = true
                } else {
                    // botão "0" alongado
                    btn.heightAnchor.constraint(equalTo: btn.widthAnchor, multiplier: 1 / tecla.widthRatio).isActive = true
                }
                if tecla.titulo == "AC" { teclaACClear = btn }
                registrarBotaoOperacao(btn, titulo: tecla.titulo)
            }
            // Forçar larguras iguais entre botões "single" para alinhamento
            let single = h.arrangedSubviews.filter { ($0 as? CircleButton)?.title(for: .normal) != "0" }
            for v in single.dropFirst() {
                v.widthAnchor.constraint(equalTo: single[0].widthAnchor).isActive = true
            }
            stack.addArrangedSubview(h)
        }
        stackRetrato = stack
    }

    // MARK: Teclado paisagem (científico)

    private func montarTecladoPaisagem() {
        // 5 linhas × 10 colunas
        let linhas: [[Tecla]] = [
            [
                Tecla(titulo: "(", estilo: .cientifico, acao: #selector(tocouAbreParen)),
                Tecla(titulo: ")", estilo: .cientifico, acao: #selector(tocouFechaParen)),
                Tecla(titulo: "mc", estilo: .cientifico, acao: #selector(tocouMC)),
                Tecla(titulo: "m+", estilo: .cientifico, acao: #selector(tocouMPlus)),
                Tecla(titulo: "m−", estilo: .cientifico, acao: #selector(tocouMMinus)),
                Tecla(titulo: "mr", estilo: .cientifico, acao: #selector(tocouMR)),
                Tecla(titulo: "AC", estilo: .funcao, acao: #selector(tocouLimpar)),
                Tecla(titulo: "+/-", estilo: .funcao, acao: #selector(tocouSinal)),
                Tecla(titulo: "%",  estilo: .funcao, acao: #selector(tocouPercentual)),
                Tecla(titulo: "÷",  estilo: .operacao, acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "2nd", estilo: .cientifico, acao: #selector(tocouSegunda)),
                Tecla(titulo: "x²",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "x³",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "xʸ",  estilo: .cientifico, acao: #selector(tocouOperacao(_:))),
                Tecla(titulo: "eˣ",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "10ˣ", estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "7",   estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "8",   estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "9",   estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "×",   estilo: .operacao,  acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "1/x",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "²√x",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "³√x",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "ʸ√x",  estilo: .cientifico, acao: #selector(tocouOperacao(_:))),
                Tecla(titulo: "ln",   estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "log",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "4",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "5",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "6",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "−",    estilo: .operacao,  acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "x!",   estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "sin",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "cos",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "tan",  estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "e",    estilo: .cientifico, acao: #selector(tocouConstante(_:))),
                Tecla(titulo: "EE",   estilo: .cientifico, acao: #selector(tocouOperacao(_:))),
                Tecla(titulo: "1",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "2",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "3",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "+",    estilo: .operacao,  acao: #selector(tocouOperacao(_:))),
            ],
            [
                Tecla(titulo: "Rad",  estilo: .cientifico, acao: #selector(tocouRadDeg)),
                Tecla(titulo: "sinh", estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "cosh", estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "tanh", estilo: .cientifico, acao: #selector(tocouUnaria(_:))),
                Tecla(titulo: "π",    estilo: .cientifico, acao: #selector(tocouConstante(_:))),
                Tecla(titulo: "Rand", estilo: .cientifico, acao: #selector(tocouConstante(_:))),
                Tecla(titulo: "0",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: ".",    estilo: .numero,    acao: #selector(tocouDigito(_:))),
                Tecla(titulo: "=",    estilo: .operacao,  acao: #selector(tocouIgual), widthRatio: 2),
            ],
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        view.addSubview(stack)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
        ])

        for linha in linhas {
            let h = UIStackView()
            h.axis = .horizontal
            h.spacing = 8
            h.distribution = .fill
            var primeiroSimples: UIView?
            for tecla in linha {
                let btn = CircleButton(titulo: tecla.titulo, estilo: tecla.estilo, pillShape: true)
                btn.addTarget(self, action: tecla.acao, for: .touchUpInside)
                h.addArrangedSubview(btn)
                if tecla.widthRatio > 1 {
                    btn.widthAnchor.constraint(equalTo: (primeiroSimples ?? btn).widthAnchor,
                                               multiplier: tecla.widthRatio).isActive = true
                } else {
                    if let p = primeiroSimples {
                        btn.widthAnchor.constraint(equalTo: p.widthAnchor).isActive = true
                    } else {
                        primeiroSimples = btn
                    }
                }
                if tecla.titulo == "AC" { teclaACClear = btn }
                if tecla.titulo == "2nd" { teclaSegunda = btn }
                if tecla.titulo == "Rad" { teclaRadDeg = btn }
                if ["sin","cos","tan","sinh","cosh","tanh"].contains(tecla.titulo) {
                    botoesUnariosTrig[tecla.titulo] = btn
                }
                registrarBotaoOperacao(btn, titulo: tecla.titulo)
            }
            stack.addArrangedSubview(h)
        }
        stackPaisagem = stack
    }

    private func registrarBotaoOperacao(_ btn: CircleButton, titulo: String) {
        let opTitles = ["÷", "×", "−", "+", "xʸ", "ʸ√x", "EE"]
        if opTitles.contains(titulo) {
            // último botão registrado vence (em paisagem sobrescreve retrato e vice-versa)
            // por isso usamos array; aqui simplifico mantendo só um por título visível
            botoesOperacao[titulo] = btn
        }
    }

    // MARK: Layout dinâmico por orientação

    private func atualizarLayoutParaOrientacao(size: CGSize? = nil) {
        let s = size ?? view.bounds.size
        let paisagem = s.width > s.height
        stackRetrato?.isHidden = paisagem
        stackPaisagem?.isHidden = !paisagem

        // Ajusta tamanho da fonte do display
        lblDisplay.font = .systemFont(ofSize: paisagem ? 56 : 80, weight: .light)
        lblExpressao.font = .systemFont(ofSize: paisagem ? 18 : 24, weight: .light)
    }

    // MARK: - Ações dos botões

    @objc private func tocouDigito(_ sender: UIButton) {
        guard let t = sender.currentTitle else { return }
        engine.digitar(t)
        atualizarUI()
    }

    @objc private func tocouOperacao(_ sender: UIButton) {
        guard let t = sender.currentTitle else { return }
        let op: CalculatorEngine.OperacaoBinaria
        switch t {
        case "+":   op = .soma
        case "−":   op = .subtracao
        case "×":   op = .multiplicacao
        case "÷":   op = .divisao
        case "xʸ":  op = .potencia
        case "ʸ√x": op = .raizN
        case "EE":  op = .ee
        default: return
        }
        engine.definirOperacao(op)
        operacaoDestacada = t
        atualizarUI()
    }

    @objc private func tocouIgual() {
        engine.igual()
        operacaoDestacada = nil
        atualizarUI()
    }

    @objc private func tocouLimpar() {
        // AC limpa tudo; C apenas o display (quando há entrada em curso)
        if teclaACClear?.title(for: .normal) == "C" {
            engine.limparEntrada()
        } else {
            engine.limparTudo()
        }
        operacaoDestacada = nil
        atualizarUI()
    }

    @objc private func tocouSinal() {
        engine.aplicarUnaria("+/-")
        atualizarUI()
    }

    @objc private func tocouPercentual() {
        engine.aplicarUnaria("%")
        atualizarUI()
    }

    @objc private func tocouUnaria(_ sender: UIButton) {
        guard var t = sender.currentTitle else { return }
        // Se 2nd está ativa e for trig, mapear para a inversa
        if engine.modoSegunda {
            switch t {
            case "sin":  t = "sin⁻¹"
            case "cos":  t = "cos⁻¹"
            case "tan":  t = "tan⁻¹"
            case "sinh": t = "sinh⁻¹"
            case "cosh": t = "cosh⁻¹"
            case "tanh": t = "tanh⁻¹"
            default: break
            }
        }
        engine.aplicarUnaria(t)
        atualizarUI()
    }

    @objc private func tocouConstante(_ sender: UIButton) {
        guard let t = sender.currentTitle else { return }
        engine.inserirConstante(t)
        atualizarUI()
    }

    @objc private func tocouAbreParen() {
        engine.abrirParenteses()
        atualizarUI()
    }

    @objc private func tocouFechaParen() {
        engine.fecharParenteses()
        atualizarUI()
    }

    @objc private func tocouMC()    { engine.memoriaLimpar();    atualizarUI() }
    @objc private func tocouMPlus() { engine.memoriaSomar();     atualizarUI() }
    @objc private func tocouMMinus(){ engine.memoriaSubtrair();  atualizarUI() }
    @objc private func tocouMR()    { engine.memoriaRecuperar(); atualizarUI() }

    @objc private func tocouSegunda() {
        engine.modoSegunda.toggle()
        teclaSegunda?.definirSelecionado(engine.modoSegunda)
        // Trocar títulos dos botões de trig
        for (nome, btn) in botoesUnariosTrig {
            let novoTitulo: String
            if engine.modoSegunda {
                novoTitulo = nome + "⁻¹"
            } else {
                novoTitulo = nome
            }
            btn.setTitle(novoTitulo, for: .normal)
        }
    }

    @objc private func tocouRadDeg() {
        engine.modoAngulo = (engine.modoAngulo == .graus) ? .radianos : .graus
        atualizarUI()
    }

    @objc private func swipeDisplay() {
        engine.backspace()
        atualizarUI()
    }

    @objc private func tocouHistorico() {
        let vc = HistoryViewController(itens: engine.historico)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: Atualização de UI

    private func atualizarUI() {
        lblDisplay.text = engine.displayText
        lblExpressao.text = engine.expressaoText.isEmpty ? " " : engine.expressaoText

        // Indicadores: M (memória), Rad/Deg
        var partes: [String] = []
        if engine.temMemoria { partes.append("M") }
        partes.append(engine.modoAngulo == .graus ? "Deg" : "Rad")
        lblIndicadores.text = partes.joined(separator: "  ")

        // Atualiza botão Rad/Deg
        teclaRadDeg?.setTitle(engine.modoAngulo == .graus ? "Rad" : "Deg", for: .normal)

        // Texto do AC/C
        let titulo = (engine.displayText == "0" && engine.expressaoText.isEmpty) ? "AC" : "C"
        teclaACClear?.setTitle(titulo, for: .normal)

        // Destacar operação pendente
        for (nome, btn) in botoesOperacao {
            btn.definirSelecionado(nome == operacaoDestacada)
        }
    }
}

// MARK: - Delegate do histórico

extension ViewController: HistoryViewControllerDelegate {
    func historyDidSelect(_ item: HistoricoItem) {
        engine.recuperarHistorico(item)
        atualizarUI()
    }

    func historyDidRequestClear() {
        engine.limparHistorico()
    }
}
