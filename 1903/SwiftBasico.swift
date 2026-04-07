// 🔹 Constantes (let) - valores imutáveis
let nome = "Alice"  // String
let idade = 25      // Int
let pi = 3.14159    // Double

// pi = 3.14 // ❌ Erro: constantes não podem ser alteradas

// 🔹 Variáveis (var) - valores mutáveis
var contador = 10
contador = 20  // ✅ Pode ser alterado

// 🔹 Inferência de Tipo
let linguagem = "Swift"  // Tipo inferido como String
var numero = 42          // Tipo inferido como Int

// 🔹 Declaração explícita de tipo
let altura: Double = 1.75
var mensagem: String = "Olá, Swift!"

// 🔹 Tipos Numéricos
let inteiro: Int = 100
let decimal: Float = 3.14
let preciso: Double = 3.1415926535

// 🔹 Booleanos (true ou false)
let estaChovendo: Bool = false
var concluido = true

// 🔹 Strings e Caracteres
let saudacao: String = "Olá, mundo!"
let letra: Character = "A"

// Concatenação de Strings
let nomeCompleto = "Mark" + " Joselli"

// Interpolação de Strings
let apresentacao = "\(saudacao). Meu nome é \(nomeCompleto)."

// 🔹 Optionals (valores que podem ser nil)
var apelido: String? = nil
apelido = "Beto"  // Agora possui um valor

// Desembrulhando um Optional
if let nomeApelido = apelido {
    print("O apelido é \(nomeApelido)")
}

// 🔹 Tuplas (agrupam múltiplos valores)
let tupla = (10, 20)
let soma = tupla.0 + tupla.1

// Tupla com nomes
let usuario = (nome: "João", idade: 30)
print(usuario.nome) // João


// 🔹 IF, ELSE IF, ELSE

if idade >= 18 {
    print("Você é maior de idade.")
} else {
    print("Você é menor de idade.")
}

// Com múltiplas condições
let temperatura = 25

if temperatura < 10 {
    print("Está frio!")
} else if temperatura < 25 {
    print("Clima agradável.")
} else {
    print("Está quente!")
}

// 🔹 Operador Ternário
let ehMaior = idade >= 18 ? "Sim" : "Não"
print(ehMaior) // "Sim"
let ehMaior2 = if (idade >= 18) { "Sim" } else { "Não" }

let ehMaior3: String
if (idade >= 18) {
    ehMaior3 = "Sim"
} else {
    ehMaior3 = "Não"
}


// 🔹 SWITCH - alternativa ao IF para múltiplos casos
let diaSemana = 3

switch diaSemana {
case 1:
    print("Domingo")
case 2:
    print("Segunda-feira")
case 3:
    print("Terça-feira")
case 4...6: // Intervalo de valores
    print("Meio da semana")
case 7:
    print("Sábado")
default:
    print("Dia inválido")
}

// 🔹 SWITCH com Tuplas
let coordenadas = (x: 10, y: 20)
switch coordenadas {
case (0, 0):
    print("Está na origem")
case (0, _):
    print("Está no eixo Y")
case (_, 0):
    print("Está no eixo X")
case (let x, let y) where x == y:
    print("Está na linha diagonal \(x), \(y)")
default:
    print("Coordenadas diferentes de zero")
}

// 🔹 GUARD - usado para early exit
func verificarNome(_ nome: String?) {
    guard let nome else {
        print("Nome inválido.")
        return
    }
    print("Olá, \(nome)!")
}

verificarNome(nil)    // "Nome inválido."
verificarNome("Ana")  // "Olá, Ana!"

// 🔹 FOR IN - Iterando sobre um range
for i in 1...5 {
    print("Número: \(i)")
}

// Iterando com step (pulando números)
for i in stride(from: 0, to: 10, by: 2) {
    print("Par: \(i)")
}

// 🔹 FOR IN - Iterando sobre um array
let nomes = ["Alice", "Bob", "Carlos"]
for nome in nomes {
    print("Olá, \(nome)!")
}

// 🔹 FOR IN - Iterando sobre um dicionário
let idades = ["Alice": 25, "Bob": 30]

for (nome, idade) in idades {
    print("\(nome) tem \(idade) anos.")
}

// 🔹 WHILE - Executa enquanto a condição for verdadeira
var counter = 3

while counter > 0 {
    print("Contagem: \(counter)")
    counter -= 1
}

// 🔹 REPEAT WHILE - Executa pelo menos uma vez
var senhaCorreta = false
var tentativas = 0

repeat {
    print("Tentando acessar...")
    tentativas += 1
    senhaCorreta = tentativas == 3 // Simula acerto na 3ª tentativa
} while !senhaCorreta

print("Acesso concedido após \(tentativas) tentativas.")

// 🔹 BREAK - Interrompe o loop
for numero in 1...10 {
    if numero == 5 {
        print("Interrompendo no número \(numero)")
        break
    }
    print(numero)
}

// 🔹 CONTINUE - Pula para a próxima iteração
for numero in 1...5 {
    if numero == 3 {
        continue  // Pula o número 3
    }
    print(numero)
}

// Funções em Swift: Uma Introdução Passo a Passo

// Definição Básica de uma Função

// A sintaxe básica para definir uma função é:
// func nomeDaFuncao(parametro1: Tipo1, parametro2: Tipo2) -> TipoDeRetorno {
//     // Corpo da função (o código que será executado)
//     return valorDeRetorno
// }

// Exemplo: Uma função simples que não recebe parâmetros e não retorna nada.
func saudacaoSimples() {
    print("Olá, mundo!")
}

// Chamando a função:
saudacaoSimples() // Imprime "Olá, mundo!"

// Funções com Parâmetros

// Funções podem receber valores de entrada, chamados parâmetros.

func saudacaoPersonalizada(nome: String) {
    print("Olá, \(nome)!")
}

// Chamando a função com um argumento:
saudacaoPersonalizada(nome: "Alice") // Imprime "Olá, Alice!"
saudacaoPersonalizada(nome: "Bob")   // Imprime "Olá, Bob!"

// Funções com Retorno

// Funções podem retornar um valor após a execução.  O tipo do valor retornado é especificado após a seta `->`.
func dobro(numero: Int) -> Int {
    let resultado = numero * 2
    return resultado
}

// Chamando a função e armazenando o valor de retorno:
let meuNumero = 5
let dobroDoMeuNumero = dobro(numero: meuNumero)
print("O dobro de \(meuNumero) é \(dobroDoMeuNumero)") // Imprime "O dobro de 5 é 10"

// Funções com Múltiplos Parâmetros

// Funções podem receber múltiplos parâmetros.

func somar(a: Int, b: Int) -> Int {
    return a + b
}

// Chamando a função com dois argumentos:
let resultadoDaSoma = somar(a: 3, b: 7)
print("A soma de 3 e 7 é \(resultadoDaSoma)") // Imprime "A soma de 3 e 7 é 10"

// Funções com Nomes Externos e Internos de Parâmetros

// Por padrão, o nome do parâmetro usado na definição da função também é usado ao chamar a função.
// Podemos especificar um nome externo diferente para o parâmetro, que será usado ao chamar a função,
// enquanto o nome interno é usado dentro do corpo da função.

func calcularArea(largura l: Int, altura a: Int) -> Int {
    // 'l' e 'a' são os nomes internos dos parâmetros
    return l * a
}

// Chamando a função usando os nomes externos 'largura' e 'altura':
let area = calcularArea(largura: 10, altura: 5) // O nome externo é usado aqui
print("A área é \(area)") // Imprime "A área é 50"

// Se você não quer um nome externo, use `_`:

func imprimir(_ mensagem: String) {
    print(mensagem)
}

imprimir("Esta é uma mensagem.") // Mais conciso!

// Funções com Valores Padrão para Parâmetros

// Podemos definir valores padrão para os parâmetros. Se o argumento não for fornecido ao chamar a função,
// o valor padrão será usado.

func saudacao(nome: String, saudacaoPersonalizada: String = "Olá") {
    print("\(saudacaoPersonalizada), \(nome)!")
}

saudacao(nome: "Carlos") // Usa o valor padrão "Olá": Imprime "Olá, Carlos!"
saudacao(nome: "Ana", saudacaoPersonalizada: "Boas vindas") // Usa o valor especificado: Imprime "Boas vindas, Ana!"

// Funções com Número Variável de Argumentos

// Uma função pode receber um número variável de argumentos do mesmo tipo.

func somarMuitosNumeros(numeros: Int...) -> Int {
    var total = 0
    for numero in numeros {
        total += numero
    }
    return total
}

let soma1 = somarMuitosNumeros(numeros: 1, 2, 3) // Passa 3 argumentos
let soma2 = somarMuitosNumeros(numeros: 10, 20, 30, 40, 50) // Passa 5 argumentos
let soma3 = somarMuitosNumeros() // Passa nenhum argumento

print("Soma 1: \(soma1)") // Imprime "Soma 1: 6"
print("Soma 2: \(soma2)") // Imprime "Soma 2: 150"
print("Soma 3: \(soma3)") // Imprime "Soma 3: 0"

// Funções como Tipos de Dados

// Em Swift, funções são cidadãos de primeira classe. Isso significa que podemos tratá-las como qualquer outro tipo de dado.
// Podemos atribuí-las a variáveis, passá-las como argumentos para outras funções e retorná-las de funções.

// Definindo uma função que aceita outra função como parâmetro:
func aplicarOperacao(a: Int, b: Int, operacao: (Int, Int) -> Int) -> Int {
    return operacao(a, b)
}

// Definindo algumas funções de operação:
func multiplicar(a: Int, b: Int) -> Int {
    return a * b
}

func dividir(a: Int, b: Int) -> Int {
    return a / b
}

// Usando a função 'aplicarOperacao' com diferentes operações:
let resultadoMultiplicacao = aplicarOperacao(a: 5, b: 4, operacao: multiplicar)
let resultadoDivisao = aplicarOperacao(a: 10, b: 2, operacao: dividir)
let resultadoSoma = aplicarOperacao(a: 10, b: 2,operacao: { a, b in
    a + b
})

print("Resultado da Multiplicação: \(resultadoMultiplicacao)") // Imprime "Resultado da Multiplicação: 20"
print("Resultado da Divisão: \(resultadoDivisao)") // Imprime "Resultado da Divisão: 5"

// Funções Aninhadas

// Funções podem ser definidas dentro de outras funções.  Elas são visíveis apenas dentro da função onde são definidas.

func operacaoComplexa(numero: Int) -> Int {
    func adicionarCinco(n: Int) -> Int {
        return n + 5
    }

    let numeroComCinco = adicionarCinco(n: numero)
    return numeroComCinco * 2
}

let resultadoComplexo = operacaoComplexa(numero: 3)
print("Resultado complexo: \(resultadoComplexo)") //Imprime "Resultado complexo: 16"

// 10. Retornando Múltiplos Valores (Tuplas)

// Funções podem retornar múltiplos valores usando tuplas.

func obterNomeCompleto() -> (primeiroNome: String, ultimoNome: String) {
    return ("João", "Silva")
}

let nomeCompletoTupla = obterNomeCompleto()
print("Primeiro Nome: \(nomeCompletoTupla.primeiroNome)") // Imprime "Primeiro Nome: João"
print("Último Nome: \(nomeCompletoTupla.ultimoNome)")   // Imprime "Último Nome: Silva"

// Ou, desestruturar a tupla na atribuição:
let (primeiroNome, ultimoNome) = obterNomeCompleto()
print("Primeiro Nome: \(primeiroNome)") // Imprime "Primeiro Nome: João"
print("Último Nome: \(ultimoNome)")   // Imprime "Último Nome: Silva"

// Um exemplo mais prático (e mais legível):
func minMax(array: [Int]) -> (min: Int, max: Int)? {
    if array.isEmpty { return nil } // Evitar erros se o array estiver vazio
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}

if let bounds = minMax(array: [8, -6, 2, 109, 3, 71]) {
    print("min is \(bounds.min) and max is \(bounds.max)")
}
// Prints "min is -6 and max is 109"

if let bounds = minMax(array: []) {
    print("min is \(bounds.min) and max is \(bounds.max)")
} else {
    print ("Array vazio")
}
//Prints "Array vazio"

// Arrays e Dicionários em Swift: Uma Exploração Detalhada

// Arrays: Coleções Ordenadas de Elementos

// 1. Criação de Arrays

// Um array vazio de inteiros:
var numeros: [Int] = []  // Sintaxe explícita
// ou, usando inferência de tipo:
var outrosNumeros = [Int]() // Sintaxe mais curta

// Um array de strings com valores iniciais:
var grupo: [String] = ["Alice", "Bob", "Charlie"]

// Usando inferência de tipo:
var cores = ["Vermelho", "Verde", "Azul"]

// Criando um array com um determinado tamanho e valor padrão (pouco comum):
var zeros = Array(repeating: 0.0, count: 10) // 10 elementos, todos iguais a 0.0

// 2. Acessando Elementos

// Acessando elementos por índice (o primeiro elemento está no índice 0):
let primeiroDoGrupo = grupo[0] // "Alice"
let segundoDoGrupo = grupo[1] // "Bob"

// Importante: Tenha cuidado para não acessar um índice fora dos limites do array.
// Isso causará um erro em tempo de execução.
// Exemplo: nomes[3]  // ERRO!  O índice 3 não existe.

// Para acessar de forma segura, verifique o tamanho do array:
if grupo.count > 3 {
    let quarto = grupo[3]
    print(quarto)
} else {
    print("Não há um quarto nome no array.")
}

// 3. Modificando Arrays

// Adicionando um elemento ao final do array:
grupo.append("David") // nomes agora é ["Alice", "Bob", "Charlie", "David"]

// Inserindo um elemento em um índice específico:
grupo.insert("Eve", at: 1) // nomes agora é ["Alice", "Eve", "Bob", "Charlie", "David"]

// Removendo um elemento em um índice específico:
grupo.remove(at: 2) // nomes agora é ["Alice", "Eve", "Charlie", "David"]

// Removendo o último elemento:
grupo.removeLast() // nomes agora é ["Alice", "Eve", "Charlie"]

// Substituindo um elemento em um índice específico:
grupo[0] = "Alison" // nomes agora é ["Alison", "Eve", "Charlie"]

// 4. Iterando sobre um Array

// Usando um loop for...in:
for nome in grupo {
    print("Olá, \(nome)!")
}

// Usando um loop for...in com índice:
for (indice, nome) in grupo.enumerated() {
    print("Índice \(indice): \(nome)")
}

// Usando um loop for tradicional:
for i in 0..<grupo.count {
    print("Elemento no índice \(i): \(grupo[i])")
}

// 5. Propriedades e Métodos Úteis

// Obtendo o número de elementos no array:
let numeroDeNomes = grupo.count // 3

// Verificando se o array está vazio:
let arrayVazio = grupo.isEmpty // false

// Invertendo a ordem dos elementos no array:
grupo.reverse() // nomes agora é ["Charlie", "Eve", "Alison"]

// Ordenando o array (para arrays de strings):
grupo.sort() // nomes agora é ["Alison", "Charlie", "Eve"]

// Outros métodos úteis: contains, filter, map, reduce, etc.

// Dicionários: Coleções Não Ordenadas de Pares Chave-Valor

// 1. Criação de Dicionários

// Um dicionário vazio onde as chaves são strings e os valores são inteiros:
var vazio: [String: Int] = [:] // Sintaxe explícita

// Usando inferência de tipo:
var vazioInfer = [String: Int]()

// Um dicionário com valores iniciais:
var paises: [String: String] = ["BR": "Brasil", "US": "Estados Unidos", "CA": "Canadá"]

// Usando inferência de tipo:
var capitais = ["Brasil": "Brasília", "Estados Unidos": "Washington, D.C.", "Canadá": "Ottawa"]

// 2. Acessando Valores

// Acessando um valor por chave:
let capitalBrasil = capitais["Brasil"] // "Brasília" (é um opcional String?)
let capitalFranca = capitais["França"] // nil (a chave não existe)

// Importante: Acesso por chave retorna um opcional. Você precisa desembrulhar o opcional
// para obter o valor real ou lidar com o caso em que a chave não existe (nil).

if let capital = capitais["Brasil"] {
    print("A capital do Brasil é \(capital).")
} else {
    print("A capital do Brasil não foi encontrada.")
}

// 3. Modificando Dicionários

// Adicionando um novo par chave-valor:
capitais["França"] = "Paris" // capitais agora contém ["Brasil": "Brasília", "Estados Unidos": "Washington, D.C.", "Canadá": "Ottawa", "França": "Paris"]

// Atualizando o valor de uma chave existente:
capitais["Estados Unidos"] = "Washington D.C." // capitais agora contém ["Brasil": "Brasília", "Estados Unidos": "Washington D.C.", "Canadá": "Ottawa", "França": "Paris"]

// Removendo um par chave-valor:
capitais.removeValue(forKey: "Canadá") // capitais agora contém ["Brasil": "Brasília", "Estados Unidos": "Washington D.C.", "França": "Paris"]

// Definindo o valor para nil também remove a chave:
capitais["França"] = nil // capitais agora contém ["Brasil": "Brasília", "Estados Unidos": "Washington D.C."]

// 4. Iterando sobre um Dicionário

// Usando um loop for...in:
for (pais, capital) in capitais {
    print("A capital de \(pais) é \(capital).")
}

// Acessando apenas as chaves:
for pais in capitais.keys {
    print("País: \(pais)")
}

// Acessando apenas os valores:
for capital in capitais.values {
    print("Capital: \(capital)")
}

// 5. Propriedades e Métodos Úteis

// Obtendo o número de pares chave-valor no dicionário:
let numeroDePaises = capitais.count // 2

// Verificando se o dicionário está vazio:
let dicionarioVazio = capitais.isEmpty // false

// Criando um array das chaves:
let arrayDePaises = Array(capitais.keys)

// Criando um array dos valores:
let arrayDeCapitais = Array(capitais.values)

// 6. Diferenças Chave entre Arrays e Dicionários

// Ordem: Arrays são ordenados (a ordem dos elementos é mantida). Dicionários não são ordenados.
// Acesso: Arrays acessam elementos por índice. Dicionários acessam valores por chave.
// Chaves: Dicionários requerem que as chaves sejam únicas. Arrays não têm restrição de unicidade.
// Uso: Arrays são ideais para armazenar listas de elementos onde a ordem é importante.
// Dicionários são ideais para armazenar associações entre chaves e valores, como um mapa.

// Exemplo de uso combinado: Uma lista de contatos, onde cada contato é um dicionário
var contatos: [[String: String]] = [
    ["nome": "Alice", "telefone": "123-456-7890"],
    ["nome": "Bob", "telefone": "987-654-3210"],
    ["nome": "Charlie", "telefone": "555-123-4567"]
]

// Acessando o telefone de Alice:
if let alice = contatos.first(where: { $0["nome"] == "Alice" }), let telefone = alice["telefone"] {
    print("O telefone de Alice é \(telefone)")
}

// Adicionando um novo contato:
contatos.append(["nome": "David", "telefone": "111-222-3333"])

// Removendo o contato de Bob:
contatos.removeAll(where: { $0["nome"] == "Bob" })

// Mais exemplos de métodos avançados (Arrays):

// **Map:**  Transforma cada elemento do array usando uma função.

let numerosEmString = [1, 2, 3, 4, 5].map { String($0) } // ["1", "2", "3", "4", "5"]
print(numerosEmString)

// **Filter:** Cria um novo array contendo apenas os elementos que satisfazem uma condição.

let numerosPares = [1, 2, 3, 4, 5, 6].filter { $0 % 2 == 0 } // [2, 4, 6]
print(numerosPares)

// **Reduce:** Combina todos os elementos do array em um único valor.

let somaDosNumeros = [1, 2, 3, 4, 5].reduce(0, { $0 + $1 }) // 15
print(somaDosNumeros)

// Exemplo de reduce para concatenar strings:
let palavras = ["Olá", " ", "mundo", "!"]
let fraseCompleta = palavras.reduce("", { $0 + $1 }) // "Olá mundo!"
print(fraseCompleta)

// Usando `compactMap` para remover valores nulos e converter ao mesmo tempo:

let stringsOpcionais: [String?] = ["1", nil, "3", nil, "5"]
let numerosInteiros = stringsOpcionais.compactMap { Int($0 ?? "") } // [1, 3, 5]
print(numerosInteiros)


// Sets em Swift: Coleções Não Ordenadas de Elementos Únicos

// Sets são coleções que armazenam elementos do mesmo tipo, mas de forma não ordenada e sem duplicatas.
// Eles são otimizados para verificar a existência de um elemento e realizar operações de conjunto.

// 1. Criação de Sets

// Criando um set vazio de Strings:
var colors: Set<String> = [] // Sintaxe explícita

// Usando inferência de tipo:
var outrosCores = Set<String>()

// Criando um set com valores iniciais:
var frutas: Set<String> = ["Maçã", "Banana", "Laranja"]

// Usando inferência de tipo (cuidado: se você usar [], o Swift criará um array, não um set):
var numbers: Set = [1, 2, 3, 4, 5] // Set<Int>

// Criando um set a partir de um array:
let arrayDeNumeros = [1, 2, 2, 3, 4, 4, 5] // Array com duplicatas
let setDeNumeros = Set(arrayDeNumeros) // Set sem duplicatas: {5, 2, 3, 1, 4} (ordem não garantida)

// 2. Acessando Elementos

// Sets não são ordenados, então você não pode acessar elementos por índice.
// A principal operação é verificar se um elemento existe no set.

// Verificando se um elemento existe no set:
let temMaca = frutas.contains("Maçã") // true
let temUva = frutas.contains("Uva") // false

// 3. Modificando Sets

// Inserindo um elemento:
colors.insert("Vermelho") // cores agora é {"Vermelho"}

// Inserindo múltiplos elementos:
colors.insert("Verde")
colors.insert("Azul") // cores agora é {"Vermelho", "Verde", "Azul"} (ordem não garantida)

// Removendo um elemento:
colors.remove("Vermelho") // cores agora é {"Verde", "Azul"}
colors.remove("Roxo") // Não faz nada, pois "Roxo" não está no set

// Removendo todos os elementos:
cores.removeAll() // cores agora está vazio: []

// 4. Iterando sobre um Set

// Usando um loop for...in:
for fruta in frutas {
    print(fruta) // Imprime "Maçã", "Banana", "Laranja" (em ordem não garantida)
}

// Sets não fornecem um índice porque não são ordenados.

// 5. Propriedades e Métodos Úteis

// Obtendo o número de elementos no set:
let numeroDeFrutas = frutas.count // 3

// Verificando se o set está vazio:
let setVazio = frutas.isEmpty // false

// Operações de Conjunto (Set Algebra)

// Criando sets para os exemplos:
let setA: Set = [1, 2, 3, 4, 5]
let setB: Set = [4, 5, 6, 7, 8]

// União (Union): Todos os elementos de ambos os sets.
let uniao = setA.union(setB) // {1, 2, 3, 4, 5, 6, 7, 8}

// Intersecção (Intersection): Elementos que estão em ambos os sets.
let interseccao = setA.intersection(setB) // {5, 4}

// Subtração (Subtracting): Elementos que estão no primeiro set, mas não no segundo.
let subtracao = setA.subtracting(setB) // {2, 3, 1}

// Diferença Simétrica (Symmetric Difference): Elementos que estão em um ou outro set, mas não em ambos.
let diferencaSimetrica = setA.symmetricDifference(setB) // {2, 3, 6, 7, 1, 8}

// Verificando relações entre sets:

let setC: Set = [1, 2, 3]
let setD: Set = [1, 2, 3, 4, 5]

// isSubset(of:): Verifica se um set é subconjunto de outro.
let eSubconjunto = setC.isSubset(of: setD) // true

// isSuperset(of:): Verifica se um set é superconjunto de outro.
let eSuperconjunto = setD.isSuperset(of: setC) // true

// isStrictSubset(of:): Verifica se um set é subconjunto próprio de outro (não é igual).
let eSubconjuntoProprio = setC.isStrictSubset(of: setD) // true

// isStrictSuperset(of:): Verifica se um set é superconjunto próprio de outro (não é igual).
let eSuperconjuntoProprio = setD.isStrictSuperset(of: setC) // true

// isDisjoint(with:): Verifica se dois sets não têm elementos em comum.
let setE: Set = [6, 7, 8]
let saoDisjuntos = setC.isDisjoint(with: setE) // true

// 6. Quando Usar Sets

// Use sets quando:
// - Você precisa armazenar uma coleção de elementos únicos.
// - A ordem dos elementos não é importante.
// - Você precisa verificar a existência de elementos rapidamente.
// - Você precisa realizar operações de conjunto (união, intersecção, etc.).

// Exemplo prático: Rastrear IDs únicos de usuários que visitaram uma página.

var usuariosVisitantes: Set<Int> = []

func registrarVisita(idUsuario: Int) {
    if !usuariosVisitantes.contains(idUsuario) {
        usuariosVisitantes.insert(idUsuario)
        print("Usuário \(idUsuario) registrado como visitante.")
    } else {
        print("Usuário \(idUsuario) já registrado como visitante.")
    }
}

registrarVisita(idUsuario: 123)
registrarVisita(idUsuario: 456)
registrarVisita(idUsuario: 123) // Não será adicionado novamente

print("Total de visitantes únicos: \(usuariosVisitantes.count)")


// Optionals em Swift: Lidando com a Ausência de Valores

// Optionals são um recurso fundamental em Swift que permite que uma variável ou constante
// contenha um valor ou a ausência de um valor (nil). Isso ajuda a evitar erros comuns
// causados por variáveis não inicializadas ou valores inesperados.

// 1. O que é um Optional?

// Um optional é um tipo que pode conter um valor do tipo especificado ou nil.
// Um optional é indicado por um ponto de interrogação (?) após o tipo.

// Exemplo:

var optional: String? // 'nome' pode ser uma String ou nil

// Por padrão, optionals não são inicializados automaticamente com um valor.
// Se você não atribuir um valor, eles serão automaticamente definidos como nil.

print(optional)   // Imprime "nil"

// 2. Atribuindo Valores a Optionals

// Você pode atribuir um valor do tipo especificado ao optional:

optional = "Alice"

print(optional)   // Imprime "Optional("Alice")"

// Note que a saída mostra "Optional(valor)". Isso indica que 'nome' e 'idade'
// são optionals e contêm um valor.

// Você também pode atribuir nil a um optional para indicar a ausência de um valor:

optional = nil

print(optional)   // Imprime "nil"

// 3. Desembrulhando Optionals (Unwrapping)

// Antes de usar o valor contido em um optional, você precisa "desembrulhá-lo".
// Desembrulhar significa extrair o valor do optional.
// Existem várias maneiras de desembrulhar optionals de forma segura:

// a) Forced Unwrapping (Desembrulhamento Forçado) - CUIDADO!

// Você pode usar o operador de exclamação (!) para forçar o desembrulhamento de um optional.
// No entanto, se o optional for nil, isso causará um erro em tempo de execução.

// Exemplo:

var possivelmenteUmNumero: Int? = 42

//Se voce tem certeza que a variavel tem um valor, pode forçar o desembrulho
let numeroDesembrulhado = possivelmenteUmNumero! // 42

//Cuidado! Se possivelmenteUmNumero for nil, o código abaixo vai travar!
//possivelmenteUmNumero = nil
//let outroNumeroDesembrulhado = possivelmenteUmNumero! //Erro!

// b) Optional Binding (Ligação Opcional) - Maneira Segura e Recomendada

// Optional binding usa as construções `if let` ou `guard let` para verificar
// se um optional contém um valor e, se sim, atribui o valor a uma nova constante
// ou variável.

// Exemplo com `if let`:

var sobrenome: String? = "Silva"

if let sobrenomeDesembrulhado = sobrenome {
    // 'sobrenomeDesembrulhado' contém o valor de 'sobrenome' (se não for nil)
    print("O sobrenome é \(sobrenomeDesembrulhado)") // Imprime "O sobrenome é Silva"
} else {
    // 'sobrenome' é nil
    print("O sobrenome é desconhecido")
}

// Exemplo com `guard let`:

func imprimirNomeCompleto(primeiroNome: String, sobrenomeOpcional: String?) {
    guard let sobrenome = sobrenomeOpcional else {
        print("Sobrenome não fornecido.")
        return // Sai da função se 'sobrenomeOpcional' for nil
    }

    // 'sobrenome' contém o valor de 'sobrenomeOpcional' (e não é nil aqui)
    print("Nome completo: \(primeiroNome) \(sobrenome)")
}

imprimirNomeCompleto(primeiroNome: "João", sobrenomeOpcional: "Oliveira") // Imprime "Nome completo: João Oliveira"
imprimirNomeCompleto(primeiroNome: "Maria", sobrenomeOpcional: nil)        // Imprime "Sobrenome não fornecido."

// c) Nil-Coalescing Operator (Operador de Coalescência Nula)

// O operador de coalescência nula (??) fornece um valor padrão caso o optional seja nil.

// Exemplo:

var user: String? = nil
let nomeExibido = user ?? "Convidado" // Se 'apelido' for nil, 'nomeExibido' será "Convidado"

print("Bem-vindo, \(nomeExibido)!") // Imprime "Bem-vindo, Convidado!"

user = "Al"
let nomeExibido2 = user ?? "Convidado" // 'apelido' não é nil, então 'nomeExibido2' será "Al"
print("Bem-vindo, \(nomeExibido2)!")

// d) Optional Chaining (Encadeamento Opcional)
// Permite acessar propriedades e chamar métodos em um optional que pode ser nil.  Se o optional for nil, a expressão inteira retorna nil.

class Pessoa {
    var residencia: Residencia?
}

class Residencia {
    var numeroDeQuartos = 1
}

let joao = Pessoa()

//O código abaixo vai causar um erro porque joao.residencia é nil
let numeroDeQuartos = joao.residencia!.numeroDeQuartos

//Com optional chaining, o código abaixo retorna nil em vez de travar.
if let numeroDeQuartos = joao.residencia?.numeroDeQuartos {
    print ("O numero de quartos é \(numeroDeQuartos)")
} else {
    print ("Não foi possivel obter o número de quartos.")
}

//Agora podemos atribuir um valor para residencia e o código vai funcionar
joao.residencia = Residencia()

if let numeroDeQuartos = joao.residencia?.numeroDeQuartos {
    print ("O numero de quartos é \(numeroDeQuartos)") //Irá imprimir "O numero de quartos é 1"
} else {
    print ("Não foi possivel obter o número de quartos.")
}

// 4. Optionals Implícitos (Implicitly Unwrapped Optionals) - Usar com Cautela!

// Um optional implicitamente desembrulhado é um optional que pode ser usado como se
// não fosse um optional. Ele é declarado com um ponto de exclamação (!) em vez de um
// ponto de interrogação (?).

// Exemplo:

var msg: String! = "Olá!" // 'mensagem' é um optional implicitamente desembrulhado

print(msg) // Imprime "Olá!" (não precisa desembrulhar explicitamente)

msg = nil // Pode ser definido como nil

// Se você tentar acessar um optional implicitamente desembrulhado que é nil,
// isso causará um erro em tempo de execução. Portanto, use-os com extrema cautela.
// É geralmente preferível usar optionals regulares e desembrulhá-los de forma segura.

// 5. Quando Usar Optionals

// Use optionals quando:
// - Uma variável pode não ter um valor em determinado momento.
// - Uma função pode não ser capaz de retornar um valor em todos os casos.
// - Você precisa representar a ausência de um valor de forma clara e segura.

// Exemplo prático: Converter uma string para um inteiro.

func converterStringParaInteiro(string: String) -> Int? {
    if let inteiro = Int(string) {
        return inteiro
    } else {
        return nil // Retorna nil se a string não puder ser convertida
    }
}

let numeroString = "123"
let numeroInteiro = converterStringParaInteiro(string: numeroString)

if let numero = numeroInteiro {
    print("O número é \(numero)") // Imprime "O número é 123"
} else {
    print("A string não pôde ser convertida para um número.")
}

let stringInvalida = "abc"
let numeroInvalido = converterStringParaInteiro(string: stringInvalida)

if let numero = numeroInvalido {
    print("O número é \(numero)")
} else {
    print("A string não pôde ser convertida para um número.") // Imprime "A string não pôde ser convertida para um número."
}
