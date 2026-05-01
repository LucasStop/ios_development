import UIKit

protocol HistoryViewControllerDelegate: AnyObject {
    func historyDidSelect(_ item: HistoricoItem)
    func historyDidRequestClear()
}

final class HistoryViewController: UIViewController {

    weak var delegate: HistoryViewControllerDelegate?
    private var itens: [HistoricoItem]
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(itens: [HistoricoItem]) {
        self.itens = itens
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurarNavegacao()
        configurarTabela()
    }

    private func configurarNavegacao() {
        title = "Histórico"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Fechar", style: .plain, target: self, action: #selector(fechar)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Limpar", style: .plain, target: self, action: #selector(limpar)
        )
        navigationItem.rightBarButtonItem?.isEnabled = !itens.isEmpty
    }

    private func configurarTabela() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoricoCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        if itens.isEmpty {
            let vazio = UILabel()
            vazio.text = "Nenhum cálculo ainda"
            vazio.textColor = UIColor(white: 1, alpha: 0.5)
            vazio.font = .systemFont(ofSize: 18, weight: .regular)
            vazio.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(vazio)
            NSLayoutConstraint.activate([
                vazio.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                vazio.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
    }

    @objc private func fechar() { dismiss(animated: true) }

    @objc private func limpar() {
        delegate?.historyDidRequestClear()
        itens.removeAll()
        tableView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { itens.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoricoCell
        cell.configurar(com: itens[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.historyDidSelect(itens[indexPath.row])
        dismiss(animated: true)
    }
}

// MARK: - Célula

private final class HistoricoCell: UITableViewCell {
    private let lblExpr = UILabel()
    private let lblResult = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .gray

        lblExpr.textColor = UIColor(white: 1, alpha: 0.6)
        lblExpr.font = .systemFont(ofSize: 16, weight: .regular)
        lblExpr.textAlignment = .right
        lblExpr.numberOfLines = 1
        lblExpr.adjustsFontSizeToFitWidth = true
        lblExpr.minimumScaleFactor = 0.5

        lblResult.textColor = .white
        lblResult.font = .systemFont(ofSize: 28, weight: .regular)
        lblResult.textAlignment = .right
        lblResult.numberOfLines = 1
        lblResult.adjustsFontSizeToFitWidth = true
        lblResult.minimumScaleFactor = 0.4

        let stack = UIStackView(arrangedSubviews: [lblExpr, lblResult])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configurar(com item: HistoricoItem) {
        lblExpr.text = item.expressao
        lblResult.text = item.resultado
    }
}
