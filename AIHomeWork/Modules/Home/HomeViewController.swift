import UIKit

final class HomeViewController: BaseViewController {
    
    private let coordinator: HomeCoordinator
    private let viewModel = HomeViewModel()
    private let homeView = HomeView()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Subject>!
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = homeView
        
    }
    
    override func setupUI() {
        setupTargets()
        setupDataSource()
        applySnapshot()
        homeView.collectionView.delegate = self
        }
    
    override func setupTargets() {
        homeView.navigationBar.settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Subject>(collectionView: homeView.collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubjectCell.identifier, for: indexPath) as! SubjectCell
            cell.configure(with: item)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeaderAIChat {
                guard let aiChatHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: AIChatSectionView.identifier,
                    for: indexPath
                ) as? AIChatSectionView else {
                    fatalError("Could not dequeue AIChatSectionView")
                }
                aiChatHeader.chatButton.addTarget(self, action: #selector(self.chatButtonTapped), for: .touchUpInside)
                return aiChatHeader
            }
            else if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeaderView.identifier,
                    for: indexPath
                ) as? SectionHeaderView else {
                    fatalError("Could not dequeue SectionHeaderView")
                }
                let section = Section.allCases[indexPath.section]
                headerView.configure(with: section.title)
                return headerView
            }
            return nil
        }
    }

    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Subject>()
        
        for section in viewModel.sections {
            let items = viewModel.getItems(for: section)
            snapshot.appendSections([section])
            snapshot.appendItems(items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            navigateToDetail(for: item)
        }
    }
}

extension HomeViewController {
    private func navigateToDetail(for item: Subject) {
        
    }
    
    @objc
    private func chatButtonTapped() {
        
    }
    
    @objc
    private func settingsTapped() {
        coordinator.openSettings()
    }
}
