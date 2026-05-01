import UIKit

final class DetalheObraViewController: UIViewController {

    private let obra: ObraDeArte

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let imagemView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let tituloLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let artistaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()

    private let metadadosLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let descricaoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    init(obra: ObraDeArte) {
        self.obra = obra
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = obra.titulo
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(compartilharTapped)
        )

        setupHierarchy()
        setupConstraints()
        configurar()
    }

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        [imagemView, tituloLabel, artistaLabel, metadadosLabel, descricaoLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func setupConstraints() {
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -32),

            stackView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor, constant: -32),

            imagemView.heightAnchor.constraint(equalTo: imagemView.widthAnchor),
        ])
    }

    private func configurar() {
        let size = CGSize(width: 600, height: 600)
        imagemView.image = PlaceholderImageGenerator.image(for: obra, size: size)
        tituloLabel.text = obra.titulo
        artistaLabel.text = obra.artista
        metadadosLabel.text = "\(obra.estilo) • \(obra.ano)"
        descricaoLabel.text = obra.descricao
    }

    @objc private func compartilharTapped() {
        let texto = "\(obra.titulo) — por \(obra.artista). Conheça mais artistas curitibanos!"
        let imagem = imagemView.image
        var itens: [Any] = [texto]
        if let imagem = imagem {
            itens.append(imagem)
        }
        let activity = UIActivityViewController(activityItems: itens, applicationActivities: nil)
        activity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activity, animated: true)
    }
}
