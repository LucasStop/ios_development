import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var campoA: UITextField!
    @IBOutlet weak var campoB: UITextField!
    @IBOutlet weak var lblResultado: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Esconder teclado ao tocar fora dos campos
        let tap = UITapGestureRecognizer(target: self, action: #selector(fecharTeclado))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func fecharTeclado() {
        view.endEditing(true)
    }

    // MARK: - Ações dos botões

    @IBAction func somar(_ sender: UIButton)       { calcular(op: .soma) }
    @IBAction func subtrair(_ sender: UIButton)    { calcular(op: .subtracao) }
    @IBAction func multiplicar(_ sender: UIButton) { calcular(op: .multiplicacao) }
    @IBAction func dividir(_ sender: UIButton)     { calcular(op: .divisao) }

    @IBAction func limpar(_ sender: UIButton) {
        campoA.text = ""
        campoB.text = ""
        lblResultado.text = "Resultado: —"
    }

    // MARK: - Lógica

    private enum Operacao { case soma, subtracao, multiplicacao, divisao }

    private func calcular(op: Operacao) {
        guard
            let textoA = campoA.text,
            let a = Double(textoA.replacingOccurrences(of: ",", with: ".")),
            let textoB = campoB.text,
            let b = Double(textoB.replacingOccurrences(of: ",", with: "."))
        else {
            lblResultado.text = "Erro: digite números válidos"
            return
        }

        let resultado: Double
        switch op {
        case .soma:          resultado = a + b
        case .subtracao:     resultado = a - b
        case .multiplicacao: resultado = a * b
        case .divisao:
            guard b != 0 else {
                lblResultado.text = "Erro: divisão por zero"
                return
            }
            resultado = a / b
        }

        lblResultado.text = "Resultado: \(formatar(resultado))"
    }

    private func formatar(_ valor: Double) -> String {
        // Remove o .0 quando o resultado é inteiro
        if valor.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", valor)
        }
        return String(format: "%g", valor)
    }
}
