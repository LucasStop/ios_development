import UIKit

// MARK: - Botão circular customizado

final class CircleButton: UIButton {

    enum Estilo {
        case numero      // cinza escuro
        case funcao      // cinza claro (AC, %, ⌫)
        case operacao    // laranja (÷ × − + =)
    }

    private let estilo: Estilo

    init(titulo: String, estilo: Estilo) {
        self.estilo = estilo
        super.init(frame: .zero)
        configurar(titulo: titulo)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }

    private func configurar(titulo: String) {
        setTitle(titulo, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 32, weight: .regular)
        switch estilo {
        case .numero:
            backgroundColor = UIColor(white: 0.20, alpha: 1)
            setTitleColor(.white, for: .normal)
        case .funcao:
            backgroundColor = UIColor(white: 0.65, alpha: 1)
            setTitleColor(.black, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 28, weight: .regular)
        case .operacao:
            backgroundColor = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 36, weight: .regular)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2  // círculo perfeito
    }

    // Feedback visual ao tocar
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }
}

// MARK: - View Controller principal

class ViewController: UIViewController {

    // MARK: UI

    private let lblExpressao: UILabel = {
        let l = UILabel()
        l.text = " "
        l.textColor = UIColor(white: 1, alpha: 0.4)
        l.font = .systemFont(ofSize: 28, weight: .light)
        l.textAlignment = .right
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.5
        return l
    }()

    private let lblDisplay: UILabel = {
        let l = UILabel()
        l.text = "0"
        l.textColor = .white
        l.font = .systemFont(ofSize: 80, weight: .light)
        l.textAlignment = .right
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.4
        l.numberOfLines = 1
        return l
    }()

    // MARK: Estado da calculadora

    private enum Operacao: String {
        case soma = "+"
        case sub  = "−"
        case mult = "×"
        case div  = "÷"

        func aplicar(_ a: Double, _ b: Double) -> Double {
            switch self {
            case .soma: return a + b
            case .sub:  return a - b
            case .mult: return a * b
            case .div:  return a / b
            }
        }
    }

    private var valorAnterior: Double?
    private var operacaoPendente: Operacao?
    private var digitandoNumeroNovo: Bool = true

    // MARK: Ciclo de vida

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        montarInterface()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: Construção da UI

    private func montarInterface() {
        // Layout do teclado: 5 linhas × 4 colunas
        // Linha 1: ⌫  AC  %  ÷
        // Linha 2: 7  8  9  ×
        // Linha 3: 4  5  6  −
        // Linha 4: 1  2  3  +
        // Linha 5: +/-  0  .  =
        let linhas: [[(String, CircleButton.Estilo, Selector)]] = [
            [
                ("⌫",  .funcao,   #selector(tocouBackspace)),
                ("AC", .funcao,   #selector(tocouAC)),
                ("%",  .funcao,   #selector(tocouPercentual)),
                ("÷",  .operacao, #selector(tocouOperacao(_:))),
            ],
            [
                ("7", .numero,   #selector(tocouDigito(_:))),
                ("8", .numero,   #selector(tocouDigito(_:))),
                ("9", .numero,   #selector(tocouDigito(_:))),
                ("×", .operacao, #selector(tocouOperacao(_:))),
            ],
            [
                ("4", .numero,   #selector(tocouDigito(_:))),
                ("5", .numero,   #selector(tocouDigito(_:))),
                ("6", .numero,   #selector(tocouDigito(_:))),
                ("−", .operacao, #selector(tocouOperacao(_:))),
            ],
            [
                ("1", .numero,   #selector(tocouDigito(_:))),
                ("2", .numero,   #selector(tocouDigito(_:))),
                ("3", .numero,   #selector(tocouDigito(_:))),
                ("+", .operacao, #selector(tocouOperacao(_:))),
            ],
            [
                ("+/-", .funcao,   #selector(tocouSinal)),
                ("0",   .numero,   #selector(tocouDigito(_:))),
                (".",   .numero,   #selector(tocouDigito(_:))),
                ("=",   .operacao, #selector(tocouIgual)),
            ],
        ]

        // Stack das linhas
        let stackTeclado = UIStackView()
        stackTeclado.axis = .vertical
        stackTeclado.distribution = .fillEqually
        stackTeclado.spacing = 14
        stackTeclado.translatesAutoresizingMaskIntoConstraints = false

        for linhaConfig in linhas {
            let stackLinha = UIStackView()
            stackLinha.axis = .horizontal
            stackLinha.distribution = .fillEqually
            stackLinha.spacing = 14

            for (titulo, estilo, acao) in linhaConfig {
                let botao = CircleButton(titulo: titulo, estilo: estilo)
                botao.addTarget(self, action: acao, for: .touchUpInside)
                botao.heightAnchor.constraint(equalTo: botao.widthAnchor).isActive = true
                stackLinha.addArrangedSubview(botao)
            }
            stackTeclado.addArrangedSubview(stackLinha)
        }

        // Labels
        lblExpressao.translatesAutoresizingMaskIntoConstraints = false
        lblDisplay.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(lblExpressao)
        view.addSubview(lblDisplay)
        view.addSubview(stackTeclado)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackTeclado.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            stackTeclado.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            stackTeclado.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),

            lblDisplay.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            lblDisplay.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            lblDisplay.bottomAnchor.constraint(equalTo: stackTeclado.topAnchor, constant: -24),

            lblExpressao.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            lblExpressao.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            lblExpressao.bottomAnchor.constraint(equalTo: lblDisplay.topAnchor, constant: -8),
        ])
    }

    // MARK: Ações dos botões

    @objc private func tocouDigito(_ sender: UIButton) {
        guard let digito = sender.currentTitle else { return }

        if digitandoNumeroNovo {
            lblDisplay.text = (digito == ".") ? "0." : digito
            digitandoNumeroNovo = false
        } else {
            let atual = lblDisplay.text ?? "0"
            // não permite mais de um ponto
            if digito == "." && atual.contains(".") { return }
            // limita tamanho para não estourar a tela
            if atual.count >= 12 { return }
            lblDisplay.text = atual + digito
        }
    }

    @objc private func tocouOperacao(_ sender: UIButton) {
        guard
            let titulo = sender.currentTitle,
            let novaOp = Operacao(rawValue: titulo)
        else { return }

        // Se já existe um número anterior e o usuário acabou de digitar, calcula primeiro
        if let anterior = valorAnterior, let pendente = operacaoPendente, !digitandoNumeroNovo {
            let atual = valorAtual()
            let resultado = pendente.aplicar(anterior, atual)
            lblDisplay.text = formatar(resultado)
            valorAnterior = resultado
        } else {
            valorAnterior = valorAtual()
        }

        operacaoPendente = novaOp
        digitandoNumeroNovo = true
        lblExpressao.text = "\(formatar(valorAnterior ?? 0)) \(titulo)"
    }

    @objc private func tocouIgual() {
        guard let anterior = valorAnterior, let op = operacaoPendente else { return }
        let atual = valorAtual()
        let resultado = op.aplicar(anterior, atual)
        lblExpressao.text = "\(formatar(anterior)) \(op.rawValue) \(formatar(atual))"
        lblDisplay.text = formatar(resultado)
        valorAnterior = nil
        operacaoPendente = nil
        digitandoNumeroNovo = true
    }

    @objc private func tocouAC() {
        lblDisplay.text = "0"
        lblExpressao.text = " "
        valorAnterior = nil
        operacaoPendente = nil
        digitandoNumeroNovo = true
    }

    @objc private func tocouBackspace() {
        guard !digitandoNumeroNovo else { return }
        var texto = lblDisplay.text ?? "0"
        if texto.count > 1 {
            texto.removeLast()
            // se sobrar só "-" trata como zero
            if texto == "-" { texto = "0"; digitandoNumeroNovo = true }
        } else {
            texto = "0"
            digitandoNumeroNovo = true
        }
        lblDisplay.text = texto
    }

    @objc private func tocouPercentual() {
        let valor = valorAtual() / 100
        lblDisplay.text = formatar(valor)
    }

    @objc private func tocouSinal() {
        let valor = -valorAtual()
        lblDisplay.text = formatar(valor)
    }

    // MARK: Helpers

    private func valorAtual() -> Double {
        return Double(lblDisplay.text ?? "0") ?? 0
    }

    private func formatar(_ valor: Double) -> String {
        // Mostra inteiros sem .0; senão usa precisão razoável
        if valor.truncatingRemainder(dividingBy: 1) == 0,
           abs(valor) < 1e15 {
            return String(format: "%.0f", valor)
        }
        // Formatação com até 8 dígitos significativos, removendo zeros à direita
        let s = String(format: "%.8f", valor)
        if s.contains(".") {
            return s.trimmingTrailingZeros()
        }
        return s
    }
}

private extension String {
    func trimmingTrailingZeros() -> String {
        var s = self
        while s.last == "0" { s.removeLast() }
        if s.last == "." { s.removeLast() }
        return s
    }
}
