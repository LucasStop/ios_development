import UIKit

final class ObraCollectionViewCell: UICollectionViewCell {

    static let reuseId = "ObraCollectionViewCell"

    private let imagemView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let tituloLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let artistaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }

    private func setupViews() {
        contentView.addSubview(imagemView)
        contentView.addSubview(tituloLabel)
        contentView.addSubview(artistaLabel)

        NSLayoutConstraint.activate([
            imagemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imagemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imagemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imagemView.heightAnchor.constraint(equalTo: imagemView.widthAnchor),

            tituloLabel.topAnchor.constraint(equalTo: imagemView.bottomAnchor, constant: 8),
            tituloLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            tituloLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            artistaLabel.topAnchor.constraint(equalTo: tituloLabel.bottomAnchor, constant: 2),
            artistaLabel.leadingAnchor.constraint(equalTo: tituloLabel.leadingAnchor),
            artistaLabel.trailingAnchor.constraint(equalTo: tituloLabel.trailingAnchor),
            artistaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
        ])
    }

    func configure(with obra: ObraDeArte) {
        tituloLabel.text = obra.titulo
        artistaLabel.text = obra.artista
        // Tenta carregar a imagem real do Asset Catalog; cai para placeholder se não existir.
        if let imagem = UIImage(named: obra.imagemNome) {
            imagemView.image = imagem
        } else {
            let imageSize = CGSize(width: 300, height: 300)
            imagemView.image = PlaceholderImageGenerator.image(for: obra, size: imageSize)
        }
    }
}
