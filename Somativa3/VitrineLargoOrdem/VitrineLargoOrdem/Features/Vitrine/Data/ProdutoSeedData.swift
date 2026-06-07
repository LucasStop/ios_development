import Foundation

/// Dados iniciais do catálogo da Feira do Largo da Ordem.
///
/// UUIDs fixos para serem determinísticos entre re-instalações
/// (facilita debugging e UITests que dependem de nomes específicos).
/// Quando V1 trouxer backend, o seed é descartado em favor de pull do Supabase.
enum ProdutoSeedData {

    static let produtos: [SeedProduto] = [
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000001",
            nome: "Escultura de Capivara em Madeira",
            artesao: "Sebastião Andrade",
            preco: 85.00,
            categoria: "Madeira",
            imagemNome: "leaf.fill",
            descricao: "Capivara entalhada à mão em madeira de imbuia reaproveitada, com acabamento em verniz natural. Cada peça é única e leva cerca de 8 horas para ficar pronta. Mede aproximadamente 20cm de comprimento.",
            estoque: 5
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000002",
            nome: "Quibe Frito Tradicional",
            artesao: "Família Saadi",
            preco: 12.00,
            categoria: "Comidas",
            imagemNome: "fork.knife",
            descricao: "Quibe libanês frito na hora, recheado com carne moída temperada com hortelã e cebola caramelizada. Receita herdada do bisavô, vendida na feira há mais de 40 anos. Acompanha limão siciliano.",
            estoque: 50
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000003",
            nome: "Tela Calçadas de Curitiba",
            artesao: "Marta Schneider",
            preco: 250.00,
            categoria: "Arte",
            imagemNome: "paintbrush.fill",
            descricao: "Pintura em acrílico sobre tela de algodão, retratando o famoso mosaico das calçadas curitibanas com pinhões dourados. Tamanho 30x40cm, assinada e datada. Vem com moldura em madeira pinus tratada.",
            estoque: 1
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000004",
            nome: "Manta de Tricô Colorida",
            artesao: "Dona Antônia",
            preco: 95.00,
            categoria: "Vestuário",
            imagemNome: "tshirt.fill",
            descricao: "Manta tricotada à mão com lã 100% natural em tons de azul, branco e verde — as cores do Paraná. Ideal para o inverno curitibano. Tamanho 1,20m x 1,80m, lavável à mão.",
            estoque: 3
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000005",
            nome: "Relógio de Bolso Antigo",
            artesao: "Antiquário do Sr. Otto",
            preco: 180.00,
            categoria: "Antiguidades",
            imagemNome: "clock.fill",
            descricao: "Relógio de bolso suíço da década de 1940, em estado funcional, com caixa de aço inoxidável e mostrador em porcelana. Acompanha corrente original e estojo de couro envelhecido.",
            estoque: 1
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000006",
            nome: "Cuia de Mate Esculpida",
            artesao: "Pedro Kovalski",
            preco: 45.00,
            categoria: "Madeira",
            imagemNome: "cup.and.saucer.fill",
            descricao: "Cuia de porongo natural com bocal em alpaca, esculpida com motivos do brasão de Curitiba. Tratamento interno com erva-mate envelhecida. Acompanha bomba de inox e saquinho de erva.",
            estoque: 8
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000007",
            nome: "Boneca de Pano Maria",
            artesao: "Coletivo Mãos de Pano",
            preco: 35.00,
            categoria: "Vestuário",
            imagemNome: "figure.dress.line.vertical.figure",
            descricao: "Boneca artesanal feita com tecidos de algodão e enchimento de fibra natural. Cabelo em lã preta, vestido florido confeccionado com retalhos. Cada boneca tem um rosto bordado único.",
            estoque: 12
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000008",
            nome: "Geleia Artesanal de Pinhão",
            artesao: "Sítio Araucária",
            preco: 22.00,
            categoria: "Comidas",
            imagemNome: "leaf.circle.fill",
            descricao: "Geleia de pinhão da Araucária angustifolia, produzida com frutos colhidos no inverno paranaense. Sem conservantes, adoçada com açúcar mascavo. Pote de 250g com tampa selada.",
            estoque: 20
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000009",
            nome: "Bijuteria com Pedras do Paraná",
            artesao: "Jaqueline Veiga",
            preco: 60.00,
            categoria: "Acessórios",
            imagemNome: "sparkles",
            descricao: "Colar feito com ametistas e quartzos rosados extraídos no norte do Paraná, engastados em prata 950. Comprimento de 45cm com fecho de mosquetão. Acompanha caixinha de presente em juta.",
            estoque: 4
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000010",
            nome: "Vaso de Cerâmica Pintado",
            artesao: "Ateliê Barro & Fogo",
            preco: 75.00,
            categoria: "Arte",
            imagemNome: "drop.fill",
            descricao: "Vaso decorativo modelado no torno e pintado à mão com motivos florais inspirados nas igrejas históricas do Largo da Ordem. Esmaltado para impermeabilizar. Altura de 22cm.",
            estoque: 6
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000011",
            nome: "Cinto de Couro Trabalhado",
            artesao: "Couro & Tradição",
            preco: 110.00,
            categoria: "Vestuário",
            imagemNome: "bag.fill",
            descricao: "Cinto de couro bovino curtido com cascas vegetais, com fivela de bronze fundida no formato do brasão de Curitiba. Largura de 4cm, disponível em tamanhos do M ao GG.",
            estoque: 7
        ),
        SeedProduto(
            id: "11111111-1111-1111-1111-000000000012",
            nome: "Sabonetes Naturais Trio",
            artesao: "Aroma da Mata",
            preco: 28.00,
            categoria: "Beleza",
            imagemNome: "bubbles.and.sparkles.fill",
            descricao: "Kit com três sabonetes artesanais à base de óleos vegetais e ervas locais: lavanda, erva-mate e mel com canela. Sem parabenos ou corantes artificiais. Embalagem reciclável em papel kraft.",
            estoque: 30
        )
    ]
}

/// Estrutura intermediária para o seed — convertida em `Produto` no boot.
struct SeedProduto {
    let id: String
    let nome: String
    let artesao: String
    let preco: Double
    let categoria: String
    let imagemNome: String
    let descricao: String
    let estoque: Int

    func toProduto() -> Produto {
        Produto(
            id: UUID(uuidString: id) ?? UUID(),
            nome: nome,
            artesao: artesao,
            preco: preco,
            categoria: categoria,
            imagemNome: imagemNome,
            descricao: descricao,
            estoque: estoque
        )
    }
}
