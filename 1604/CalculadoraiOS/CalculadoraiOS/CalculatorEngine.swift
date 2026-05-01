import Foundation

// MARK: - Modelo do histórico

struct HistoricoItem {
    let expressao: String
    let resultado: String
    let data: Date
}

// MARK: - Motor da calculadora

final class CalculatorEngine {

    // MARK: Tipos

    enum OperacaoBinaria {
        case soma, subtracao, multiplicacao, divisao
        case potencia        // xʸ
        case raizN           // ʸ√x  -> y é o índice da raiz, x é o radicando
        case ee              // EE: notação científica (a × 10^b)

        var simbolo: String {
            switch self {
            case .soma: return "+"
            case .subtracao: return "−"
            case .multiplicacao: return "×"
            case .divisao: return "÷"
            case .potencia: return "^"
            case .raizN: return "ʸ√"
            case .ee: return "E"
            }
        }

        func aplicar(_ a: Double, _ b: Double) -> Double {
            switch self {
            case .soma:           return a + b
            case .subtracao:      return a - b
            case .multiplicacao:  return a * b
            case .divisao:        return a / b
            case .potencia:       return pow(a, b)
            case .raizN:          return pow(a, 1.0 / b)
            case .ee:             return a * pow(10, b)
            }
        }
    }

    enum ModoAngulo { case graus, radianos }

    // Frame para suportar parênteses (empilhamento de estado)
    private struct Frame {
        var valorAnterior: Double?
        var operacaoPendente: OperacaoBinaria?
    }

    // MARK: Estado público

    private(set) var displayText: String = "0"
    private(set) var expressaoText: String = ""
    private(set) var historico: [HistoricoItem] = []

    var modoAngulo: ModoAngulo = .graus
    var modoSegunda: Bool = false              // 2nd toggle

    private(set) var memoria: Double = 0
    var temMemoria: Bool { memoria != 0 }

    // MARK: Estado interno

    private var valorAnterior: Double?
    private var operacaoPendente: OperacaoBinaria?
    private var digitandoNumeroNovo: Bool = true
    private var ultimaExpressao: String = ""
    private var pilhaParenteses: [Frame] = []

    // MARK: Helpers de leitura/escrita

    private var valorAtual: Double {
        get { Double(displayText) ?? 0 }
        set { displayText = formatar(newValue) }
    }

    // MARK: Reset

    func limparTudo() {
        displayText = "0"
        expressaoText = ""
        valorAnterior = nil
        operacaoPendente = nil
        digitandoNumeroNovo = true
        pilhaParenteses.removeAll()
    }

    func limparEntrada() {
        displayText = "0"
        digitandoNumeroNovo = true
    }

    // MARK: Entrada de dígitos

    func digitar(_ digito: String) {
        if digitandoNumeroNovo {
            displayText = (digito == ".") ? "0." : digito
            digitandoNumeroNovo = false
            return
        }
        if digito == "." && displayText.contains(".") { return }
        if displayText.replacingOccurrences(of: "-", with: "").count >= 12 { return }
        if displayText == "0" && digito != "." {
            displayText = digito
        } else {
            displayText += digito
        }
    }

    func backspace() {
        if digitandoNumeroNovo { return }
        var t = displayText
        if t.count > 1 {
            t.removeLast()
            if t == "-" || t.isEmpty { t = "0"; digitandoNumeroNovo = true }
            displayText = t
        } else {
            displayText = "0"
            digitandoNumeroNovo = true
        }
    }

    // MARK: Operações binárias

    func definirOperacao(_ op: OperacaoBinaria) {
        if let anterior = valorAnterior, let pendente = operacaoPendente, !digitandoNumeroNovo {
            let resultado = pendente.aplicar(anterior, valorAtual)
            valorAtual = resultado
            valorAnterior = resultado
        } else {
            valorAnterior = valorAtual
        }
        operacaoPendente = op
        digitandoNumeroNovo = true
        expressaoText = "\(formatar(valorAnterior ?? 0)) \(op.simbolo)"
    }

    func igual() {
        guard let anterior = valorAnterior, let op = operacaoPendente else { return }
        let atual = valorAtual
        let resultado = op.aplicar(anterior, atual)
        let expr = "\(formatar(anterior)) \(op.simbolo) \(formatar(atual))"
        valorAtual = resultado
        expressaoText = expr
        registrarHistorico(expressao: expr, resultado: displayText)
        valorAnterior = nil
        operacaoPendente = nil
        digitandoNumeroNovo = true
    }

    // MARK: Parênteses

    func abrirParenteses() {
        pilhaParenteses.append(Frame(valorAnterior: valorAnterior, operacaoPendente: operacaoPendente))
        valorAnterior = nil
        operacaoPendente = nil
        digitandoNumeroNovo = true
        expressaoText += "("
    }

    func fecharParenteses() {
        // Calcula a operação interna (se houver) antes de desempilhar
        if let anterior = valorAnterior, let op = operacaoPendente {
            let resultado = op.aplicar(anterior, valorAtual)
            valorAtual = resultado
        }
        guard let frame = pilhaParenteses.popLast() else { return }
        valorAnterior = frame.valorAnterior
        operacaoPendente = frame.operacaoPendente
        digitandoNumeroNovo = false
        expressaoText += ")"
    }

    // MARK: Operações unárias instantâneas

    func aplicarUnaria(_ nome: String) {
        let x = valorAtual
        let resultado: Double
        let expr: String
        switch nome {
        case "+/-":
            resultado = -x
            displayText = formatar(resultado)
            return
        case "%":
            resultado = x / 100
            displayText = formatar(resultado)
            return
        case "x²":
            resultado = x * x
            expr = "(\(formatar(x)))²"
        case "x³":
            resultado = x * x * x
            expr = "(\(formatar(x)))³"
        case "1/x":
            resultado = 1 / x
            expr = "1/(\(formatar(x)))"
        case "²√x":
            resultado = sqrt(x)
            expr = "√(\(formatar(x)))"
        case "³√x":
            resultado = cbrt(x)
            expr = "∛(\(formatar(x)))"
        case "ln":
            resultado = log(x)
            expr = "ln(\(formatar(x)))"
        case "log":
            resultado = log10(x)
            expr = "log(\(formatar(x)))"
        case "eˣ":
            resultado = exp(x)
            expr = "e^(\(formatar(x)))"
        case "10ˣ":
            resultado = pow(10, x)
            expr = "10^(\(formatar(x)))"
        case "x!":
            resultado = fatorial(x)
            expr = "(\(formatar(x)))!"
        case "sin":
            resultado = sin(emRadianos(x))
            expr = "sin(\(formatar(x)))"
        case "cos":
            resultado = cos(emRadianos(x))
            expr = "cos(\(formatar(x)))"
        case "tan":
            resultado = tan(emRadianos(x))
            expr = "tan(\(formatar(x)))"
        case "sin⁻¹":
            resultado = paraAngulo(asin(x))
            expr = "sin⁻¹(\(formatar(x)))"
        case "cos⁻¹":
            resultado = paraAngulo(acos(x))
            expr = "cos⁻¹(\(formatar(x)))"
        case "tan⁻¹":
            resultado = paraAngulo(atan(x))
            expr = "tan⁻¹(\(formatar(x)))"
        case "sinh":
            resultado = sinh(x)
            expr = "sinh(\(formatar(x)))"
        case "cosh":
            resultado = cosh(x)
            expr = "cosh(\(formatar(x)))"
        case "tanh":
            resultado = tanh(x)
            expr = "tanh(\(formatar(x)))"
        case "sinh⁻¹":
            resultado = asinh(x)
            expr = "sinh⁻¹(\(formatar(x)))"
        case "cosh⁻¹":
            resultado = acosh(x)
            expr = "cosh⁻¹(\(formatar(x)))"
        case "tanh⁻¹":
            resultado = atanh(x)
            expr = "tanh⁻¹(\(formatar(x)))"
        default:
            return
        }
        valorAtual = resultado
        digitandoNumeroNovo = true
        expressaoText = expr
        registrarHistorico(expressao: expr, resultado: displayText)
    }

    // MARK: Constantes

    func inserirConstante(_ nome: String) {
        switch nome {
        case "π": valorAtual = .pi
        case "e": valorAtual = M_E
        case "Rand": valorAtual = Double.random(in: 0..<1)
        default: return
        }
        digitandoNumeroNovo = true
    }

    // MARK: Memória

    func memoriaLimpar()  { memoria = 0 }
    func memoriaSomar()   { memoria += valorAtual; digitandoNumeroNovo = true }
    func memoriaSubtrair(){ memoria -= valorAtual; digitandoNumeroNovo = true }
    func memoriaRecuperar() {
        valorAtual = memoria
        digitandoNumeroNovo = true
    }

    // MARK: Histórico

    private func registrarHistorico(expressao: String, resultado: String) {
        historico.insert(HistoricoItem(expressao: expressao, resultado: resultado, data: Date()), at: 0)
        if historico.count > 100 { historico.removeLast() }
    }

    func limparHistorico() { historico.removeAll() }

    func recuperarHistorico(_ item: HistoricoItem) {
        displayText = item.resultado
        digitandoNumeroNovo = true
    }

    // MARK: Helpers privados

    private func emRadianos(_ x: Double) -> Double {
        modoAngulo == .graus ? x * .pi / 180 : x
    }

    private func paraAngulo(_ rad: Double) -> Double {
        modoAngulo == .graus ? rad * 180 / .pi : rad
    }

    private func fatorial(_ x: Double) -> Double {
        guard x >= 0, x.truncatingRemainder(dividingBy: 1) == 0, x <= 170 else {
            return .nan
        }
        var resultado: Double = 1
        var i: Double = 2
        while i <= x { resultado *= i; i += 1 }
        return resultado
    }

    func formatar(_ valor: Double) -> String {
        if valor.isNaN { return "Erro" }
        if valor.isInfinite { return "Erro" }
        if valor == 0 { return "0" }

        let abs = Swift.abs(valor)
        if abs >= 1e16 || (abs > 0 && abs < 1e-6) {
            // Notação científica
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.maximumFractionDigits = 6
            formatter.exponentSymbol = "e"
            return formatter.string(from: NSNumber(value: valor)) ?? "\(valor)"
        }

        if valor.truncatingRemainder(dividingBy: 1) == 0, abs < 1e16 {
            return String(format: "%.0f", valor)
        }

        // Decimal com até 8 casas, removendo zeros à direita
        var s = String(format: "%.8f", valor)
        while s.last == "0" { s.removeLast() }
        if s.last == "." { s.removeLast() }
        return s
    }
}
