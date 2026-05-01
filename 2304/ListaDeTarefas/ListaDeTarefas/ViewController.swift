import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var tarefaTextField: UITextField!
    @IBOutlet weak var adicionarButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var tarefas: [Tarefa] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lista de Tarefas"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TarefaCell.self, forCellReuseIdentifier: TarefaCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(ordenarTapped)
        )

        tarefaTextField.delegate = self
    }

    @IBAction func adicionarTapped(_ sender: UIButton) {
        guard let texto = tarefaTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !texto.isEmpty else { return }

        tarefas.insert(Tarefa(titulo: texto), at: 0)
        tarefaTextField.text = ""
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }

    @objc private func ordenarTapped() {
        let alert = UIAlertController(title: "Ordenar tarefas",
                                      message: "Escolha o critério",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Por status (pendentes primeiro)", style: .default) { [weak self] _ in
            self?.tarefas.sort { !$0.concluida && $1.concluida }
            self?.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Alfabética", style: .default) { [weak self] _ in
            self?.tarefas.sort { $0.titulo.localizedCaseInsensitiveCompare($1.titulo) == .orderedAscending }
            self?.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Mais recentes primeiro", style: .default) { [weak self] _ in
            self?.tarefas.sort { $0.criadaEm > $1.criadaEm }
            self?.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func editarTarefa(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Editar tarefa",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.text = self?.tarefas[indexPath.row].titulo
            textField.placeholder = "Título da tarefa"
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Salvar", style: .default) { [weak self] _ in
            guard let novoTitulo = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !novoTitulo.isEmpty else { return }
            self?.tarefas[indexPath.row].titulo = novoTitulo
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })

        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tarefas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TarefaCell.reuseId, for: indexPath) as! TarefaCell
        cell.configure(with: tarefas[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tarefas[indexPath.row].concluida.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let excluir = UIContextualAction(style: .destructive, title: "Excluir") { [weak self] _, _, completion in
            self?.tarefas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completion(true)
        }
        excluir.image = UIImage(systemName: "trash")

        let editar = UIContextualAction(style: .normal, title: "Editar") { [weak self] _, _, completion in
            self?.editarTarefa(at: indexPath)
            completion(true)
        }
        editar.image = UIImage(systemName: "pencil")
        editar.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [excluir, editar])
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        adicionarTapped(adicionarButton)
        return true
    }
}
