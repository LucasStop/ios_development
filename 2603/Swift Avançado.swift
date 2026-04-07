import Cocoa

// MARK: - Enums em Swift: Um Guia Completo

// Enums (Enumerations) são tipos de dados que definem um conjunto de
// valores relacionados, permitindo que você trabalhe com um conjunto
// predefinido e limitado de opções.

// MARK: - 1. Enums Básicos (Sem Valores Associados)

// Este é o tipo mais simples de enum. Ele apenas define um conjunto
// de casos (cases) possíveis.
enum Direcao {
    case norte
    case sul
    case leste
    case oeste
}

// Uso do enum Direcao
let minhaDirecao: Direcao = .norte  // Note a sintaxe abreviada
print("Minha direção é: \(minhaDirecao)")

// MARK: - 2. Enums com Raw Values (Valores Brutos)

// Você pode associar um valor bruto (raw value) a cada caso do enum.
// Isso é útil para representar os casos com valores predefinidos, como
// códigos de status HTTP ou códigos de erro.
enum StatusHTTP: Int {
    case ok = 200
    case criado = 201
    case naoAutorizado = 401
    case naoEncontrado = 404
    case erroInterno = 500
}

// Acessando o raw value
let statusOk = StatusHTTP.ok
print("O código HTTP para OK é: \(statusOk.rawValue)")  // Imprime 200

// Criando um enum a partir de um raw value
if let status = StatusHTTP(rawValue: 404) {
    print("O status 404 é: \(status)")  // Imprime naoEncontrado
} else {
    print("Código de status desconhecido")
}

// MARK: - 3. Enums com Associated Values (Valores Associados)

// Este é o tipo mais poderoso de enum. Ele permite que você associe
// dados diferentes a cada caso do enum. Isso é útil para representar
// diferentes estados ou resultados de uma operação, onde cada estado
// pode ter informações adicionais associadas.
enum Resultado {
    case sucesso(dados: String)  // Sucesso com dados
    case falha(erro: String)    // Falha com mensagem de erro
    case carregando           // Estado de carregamento
}

// Função que retorna um Resultado
func baixarDados(url: String) -> Resultado {
    // Simulando uma operação de download
    let dadosSimulados = "Dados importantes baixados da internet!"

    // Simulando um erro
    let houveErro = false

    if houveErro {
        return .falha(erro: "Erro ao baixar os dados")
    } else {
        return .sucesso(dados: dadosSimulados)
    }
}

// Uso do enum Resultado com switch case para tratar diferentes casos
let resultadoDownload = baixarDados(url: "www.exemplo.com")

switch resultadoDownload {
case .sucesso(let dados):
    print("Sucesso! Dados: \(dados)")
case .falha(let erro):
    print("Falha! Erro: \(erro)")
case .carregando:
    print("Carregando...")
}

// MARK: - 4. Enums para Modelar Estados

// Enums são ideais para representar estados de um objeto ou de uma tela
enum EstadoTela {
    case carregando
    case exibindoDados(dados: String)
    case erro(mensagem: String)
    case vazia
}

// Variável que armazena o estado da tela
var estadoAtual: EstadoTela = .carregando

// Função para atualizar a tela com base no estado
func atualizarTela(estado: EstadoTela) {
    switch estado {
    case .carregando:
        print("Exibindo indicador de carregamento...")
        // Código para exibir o indicador de carregamento
    case .exibindoDados(let dados):
        print("Exibindo dados: \(dados)")
        // Código para exibir os dados na tela
    case .erro(let mensagem):
        print("Exibindo mensagem de erro: \(mensagem)")
        // Código para exibir a mensagem de erro
    case .vazia:
        print("Exibindo tela vazia...")
        // Código para exibir a tela vazia
    }
}

// Simulando o carregamento de dados
estadoAtual = .exibindoDados(dados: "Dados importantes do servidor")
atualizarTela(estado: estadoAtual)  // Imprime "Exibindo dados: Dados importantes do servidor"


struct Inimigo {
    let nome: String
    let vida: Int
    let dano: Int
}

enum Dificuldade {
    case facil
    case medio
    case dificil
}

// Factory para gerar os inimigos de acordo com a dificuldade
extension Dificuldade {
    // Metodo que retorna o inimigo
    static func criarInimigo(dificuldade: Dificuldade) -> Inimigo {
        switch dificuldade {
        case .facil:
            return Inimigo(nome: "Goblin Fraco", vida: 50, dano: 5)
        case .medio:
            return Inimigo(nome: "Orc Médio", vida: 100, dano: 10)
        case .dificil:
            return Inimigo(nome: "Dragão Ancião", vida: 500, dano: 50)
        }
    }
}

// MARK: - Closures em Swift: Definição e Sintaxe Básica

// Closures são blocos de código autocontidos que podem ser passados
// e usados em seu código. Pense nelas como funções anônimas.

// Sintaxe geral de uma closure:
// { (parâmetros) -> tipo de retorno in
//   corpo da closure
// }

// Exemplo simples: Closure que soma dois números
let somar: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
    return a + b
}

let resultado = somar(5, 3) // Resultado: 8
print("Resultado da soma: \(resultado)")

// MARK: - Sintaxe Abreviada e Inferência de Tipo

// Swift é inteligente e pode inferir tipos e abreviar a sintaxe:

// 1. Inferência de tipo dos parâmetros e do tipo de retorno:
let multiplicar: (Int, Int) -> Int = { a, b in
    return a * b
}

// 2. Retorno implícito (se a closure tiver apenas uma linha):
let subtrair: (Int, Int) -> Int = { a, b in a - b }

// 3. Nomes abreviados de argumentos ($0, $1, $2, ...):
let dividir: (Double, Double) -> Double = { $0 / $1 } // $0 é o primeiro argumento, $1 é o segundo

print("Multiplicação: \(multiplicar(4, 2))")
print("Subtração: \(subtrair(10, 5))")
print("Divisão: \(dividir(9, 3))")

// MARK: - Trailing Closures

// Se o último parâmetro de uma função for uma closure, você pode usar
// a "trailing closure syntax" para tornar o código mais legível:

func executarNaTela(acao: () -> Void) {
    print("Preparando para executar...")
    acao() // Executa a closure
    print("Execução concluída.")
}

// Com trailing closure:
executarNaTela {
    print("Atualizando a interface do usuário!")
}

// Sem trailing closure:
executarNaTela(acao: {
    print("Outra ação na interface!")
})

// MARK: - Closures como Callbacks

// Closures são frequentemente usadas como callbacks para tratar eventos
// assíncronos ou para personalizar o comportamento de funções:
struct UIImage{
    let named: String
}
@Sendable
func baixarImagem(url: String, completion: @escaping (UIImage?) -> Void) {
    // Simulando download assíncrono
    DispatchQueue.global().async {
        // Simula um atraso de 2 segundos
        Thread.sleep(forTimeInterval: 2)

        // Simula o carregamento de uma imagem
        let imagemSimulada = UIImage(named: "placeholder") // Substitua "placeholder" por sua imagem real

        // Retorna para a thread principal para atualizar a interface
        DispatchQueue.main.async {
            completion(imagemSimulada) // Executa o callback
        }
    }
}

// Chamando a função com um callback
baixarImagem(url: "www.example.com/image.jpg") { imagem in
    if let imagem = imagem {
        print("Imagem baixada com sucesso!")
        // Exibir a imagem em um UIImageView (exemplo)
        // imageView.image = imagem
    } else {
        print("Falha ao baixar a imagem.")
        // Exibir mensagem de erro
    }
}

// MARK: - Captura de Valores (Capture Lists) e Retain Cycles

// Closures podem capturar valores do contexto em que são definidas.
// É importante evitar "retain cycles" (ciclos de retenção) para evitar
// vazamentos de memória. Use capture lists ([weak self], [unowned self])
// para evitar esses ciclos.

class MeuObjeto {
    var nome: String = "Meu Objeto"
    lazy var imprimirNome: () -> Void = { [weak self] in // Capture list
        guard let self = self else {
            print("Objeto já foi desalocado!")
            return
        }
        print("Nome do objeto: \(self.nome)")
    }

    deinit {
        print("MeuObjeto foi desalocado.")
    }
}

var objeto: MeuObjeto? = MeuObjeto()
objeto?.imprimirNome() // Imprime "Nome do objeto: Meu Objeto"
objeto = nil // Imprime "MeuObjeto foi desalocado."


// MARK: - Generics em Swift: Código Reutilizável e Seguro

// Generics permitem que você escreva código que pode trabalhar com
// qualquer tipo de dado, sem precisar especificar o tipo exato no
// momento da criação. Isso promove a reutilização de código e
// aumenta a segurança de tipo.

// MARK: - 1. Funções Genéricas

// Função genérica para trocar dois valores de qualquer tipo:
func trocarValores<T>(a: inout T, b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Testando a função com inteiros:
var num1 = 10
var num2 = 20
print("Antes da troca: num1 = \(num1), num2 = \(num2)")
trocarValores(a: &num1, b: &num2)
print("Após a troca: num1 = \(num1), num2 = \(num2)")

// Testando a função com strings:
var nome1 = "Alice"
var nome2 = "Bob"
print("Antes da troca: nome1 = \(nome1), nome2 = \(nome2)")
trocarValores(a: &nome1, b: &nome2)
print("Após a troca: nome1 = \(nome1), nome2 = \(nome2)")

// MARK: - 2. Tipos Genéricos (Structs e Classes)

// Struct genérica para representar um par de valores de qualquer tipo:
struct Par<T, U> {
    var primeiro: T
    var segundo: U
}

// Criando instâncias de Par com diferentes tipos:
let parInteiroString = Par(primeiro: 10, segundo: "Dez")
let parBooleanoDouble = Par(primeiro: true, segundo: 3.14)

print("Par Inteiro/String: primeiro = \(parInteiroString.primeiro), segundo = \(parInteiroString.segundo)")
print("Par Booleano/Double: primeiro = \(parBooleanoDouble.primeiro), segundo = \(parBooleanoDouble.segundo)")

// MARK: - 3. Type Constraints (Restrições de Tipo)

// Você pode restringir os tipos que podem ser usados com um generic
// usando "type constraints". Isso garante que o tipo genérico
// tenha certas propriedades ou implemente certos protocolos.

// Função genérica que só funciona com tipos que implementam o protocolo Equatable
func saoIguais<T: Equatable>(a: T, b: T) -> Bool {
    return a == b
}

// Testando com tipos que são Equatable (Int, String):
print("10 é igual a 10? \(saoIguais(a: 10, b: 10))")
print("Alice é igual a Bob? \(saoIguais(a: "Alice", b: "Bob"))")

// Testando com um tipo que NÃO é Equatable (gera erro de compilação):
/*
struct MeuTipo {
    let valor: Int
}
let tipo1 = MeuTipo(valor: 5)
let tipo2 = MeuTipo(valor: 5)
print("tipo1 é igual a tipo2? \(saoIguais(a: tipo1, b: tipo2))") // Erro!
*/

// MARK: - 4. Associated Types em Protocolos

// Associated types permitem que você defina um tipo "placeholder"
// dentro de um protocolo. O tipo concreto é especificado quando o
// protocolo é implementado por uma classe ou struct.

protocol Armazenavel {
    associatedtype Item
    mutating func adicionar(item: Item)
    func obter(indice: Int) -> Item?
    var quantidade: Int { get }
}

// Implementando o protocolo Armazenavel com uma struct que armazena strings:
struct ListaDeStrings: Armazenavel {
    typealias Item = String // Define o tipo Item como String
    private var itens: [String] = []

    mutating func adicionar(item: String) {
        itens.append(item)
    }

    func obter(indice: Int) -> String? {
        if indice >= 0 && indice < itens.count {
            return itens[indice]
        } else {
            return nil
        }
    }

    var quantidade: Int {
        return itens.count
    }
}

var minhaLista = ListaDeStrings()
minhaLista.adicionar(item: "Maçã")
minhaLista.adicionar(item: "Banana")
print("Quantidade de itens: \(minhaLista.quantidade)")
if let primeiroItem = minhaLista.obter(indice: 0) {
    print("Primeiro item: \(primeiroItem)")
}

// MARK: - Protocol-Oriented Programming (POP) em Swift

// Protocol-Oriented Programming (POP) é um paradigma de programação
// que enfatiza a definição de comportamentos por meio de protocolos, em
// vez de herança de classes. Swift adota POP como um dos seus
// principais paradigmas, oferecendo maior flexibilidade, reutilização de
// código e testabilidade.

// MARK: - 1. Protocolos Definem o Comportamento

// Protocolos definem um contrato que os tipos (classes, structs, enums)
// devem seguir. Eles especificam as propriedades e métodos que os tipos
// conformantes devem implementar.

protocol Movivel {
    var velocidade: Double { get set }  // Propriedade (get e set)
    mutating func mover(distancia: Double)       // Método
}

// MARK: - 2. Tipos Conformantes Implementam o Protocolo

// Classes, structs e enums podem conformar a um protocolo,
// implementando os requisitos especificados:

struct Carro: Movivel {
    var velocidade: Double = 0.0

    mutating func mover(distancia: Double) {
        velocidade += distancia
        print("Carro moveu \(distancia) km. Velocidade atual: \(velocidade) km/h")
    }
}

class Bicicleta: Movivel {
    var velocidade: Double = 0.0

    func mover(distancia: Double) {
        velocidade += distancia
        print("Bicicleta moveu \(distancia) km. Velocidade atual: \(velocidade) km/h")
    }
}

// MARK: - 3. Protocol Extensions Fornecem Implementações Padrão

// Você pode adicionar implementações padrão aos protocolos usando
// "protocol extensions". Isso permite que você forneça um comportamento
// padrão para os tipos conformantes, reduzindo a duplicação de código
// e tornando o código mais flexível.

protocol Barulhento {
    func fazerBarulho()
}

extension Barulhento {
    func fazerBarulho() {
        print("Som genérico")  // Implementação padrão
    }
}

// Tipo que usa a implementação padrão
struct Apito: Barulhento {}

// Tipo que sobrescreve a implementação padrão
struct Sino: Barulhento {
    func fazerBarulho() {
        print("Ding Dong!")
    }
}

let apito = Apito()
apito.fazerBarulho()  // Imprime "Som genérico"

let sino = Sino()
sino.fazerBarulho()  // Imprime "Ding Dong!"

// MARK: - 4. Protocol Composition (Composição de Protocolos)

// Você pode combinar múltiplos protocolos usando "protocol composition"
// para criar um tipo que deve conformar a todos os protocolos
// especificados.

protocol Identificavel {
    var id: String { get }
}

protocol Nomeavel {
    var nome: String { get }
}

// Função que recebe um tipo que conforma a ambos os protocolos
func exibirInformacoes(objeto: Identificavel & Nomeavel) {
    print("ID: \(objeto.id), Nome: \(objeto.nome)")
}

struct Usuario: Identificavel, Nomeavel {
    let id: String
    let nome: String
}

let usuario = Usuario(id: "123", nome: "Carlos")
exibirInformacoes(objeto: usuario)  // Imprime "ID: 123, Nome: Carlos"

// MARK: - 5. Vantagens do Protocol-Oriented Programming

// - Flexibilidade: Você pode combinar protocolos de diferentes maneiras
//   para criar tipos complexos.
// - Reutilização de Código: Protocol extensions permitem que você
//   compartilhe implementações de métodos entre vários tipos.
// - Testabilidade: É mais fácil simular e testar tipos que conformam a
//   protocolos.
// - Evita os Problemas da Herança: POP evita os problemas associados à
//   herança de classes, como a rigidez e o "problema do diamante".
