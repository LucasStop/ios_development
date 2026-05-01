import UIKit

final class TarefaCell: UITableViewCell {

    static let reuseId = "TarefaCell"

    private let tituloLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(tituloLabel)

        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 28),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 28),

            tituloLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 12),
            tituloLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            tituloLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            tituloLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with tarefa: Tarefa) {
        let symbol = tarefa.concluida ? "checkmark.circle.fill" : "circle"
        checkmarkImageView.image = UIImage(systemName: symbol)
        checkmarkImageView.tintColor = tarefa.concluida ? .systemGreen : .systemGray3

        let attributes: [NSAttributedString.Key: Any] = tarefa.concluida
            ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
               .foregroundColor: UIColor.secondaryLabel]
            : [.foregroundColor: UIColor.label]
        tituloLabel.attributedText = NSAttributedString(string: tarefa.titulo, attributes: attributes)
    }
}
