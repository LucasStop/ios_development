import UIKit

final class GaleriaViewController: UIViewController {

    private let todasObras: [ObraDeArte] = ObrasMockData.todas
    private var obrasFiltradas: [ObraDeArte] = ObrasMockData.todas

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.alwaysBounceVertical = true
        cv.register(ObraCollectionViewCell.self, forCellWithReuseIdentifier: ObraCollectionViewCell.reuseId)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Artistas Curitibanos"

        setupCollectionView()
        setupSearch()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar por título ou artista"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

extension GaleriaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return obrasFiltradas.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ObraCollectionViewCell.reuseId,
            for: indexPath
        ) as! ObraCollectionViewCell
        cell.configure(with: obrasFiltradas[indexPath.item])
        return cell
    }
}

extension GaleriaViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let larguraDisponivel = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right

        let colunas: CGFloat = traitCollection.horizontalSizeClass == .regular ? 3 : 2
        let espacamentoTotal = layout.minimumInteritemSpacing * (colunas - 1)
        let larguraCelula = floor((larguraDisponivel - espacamentoTotal) / colunas)

        let alturaImagem = larguraCelula
        let alturaTextos: CGFloat = 44
        return CGSize(width: larguraCelula, height: alturaImagem + alturaTextos)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obra = obrasFiltradas[indexPath.item]

        guard let cell = collectionView.cellForItem(at: indexPath) else {
            navegarParaDetalhe(obra)
            return
        }

        UIView.animate(withDuration: 0.12,
                       animations: { cell.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) }) { _ in
            UIView.animate(withDuration: 0.12,
                           animations: { cell.transform = .identity }) { _ in
                self.navegarParaDetalhe(obra)
            }
        }
    }

    private func navegarParaDetalhe(_ obra: ObraDeArte) {
        let detalhe = DetalheObraViewController(obra: obra)
        navigationController?.pushViewController(detalhe, animated: true)
    }
}

extension GaleriaViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let texto = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if texto.isEmpty {
            obrasFiltradas = todasObras
        } else {
            obrasFiltradas = todasObras.filter {
                $0.titulo.localizedCaseInsensitiveContains(texto) ||
                $0.artista.localizedCaseInsensitiveContains(texto)
            }
        }
        collectionView.reloadData()
    }
}
