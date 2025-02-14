import UIKit

final class HomeView: BlurredGradientView {
    
    let navigationBar = HomeNavigationBar()
    
    private let aiChatView = AIChatSectionView()
    
    let collectionView: UICollectionView
    
    var onChatTapped: (() -> Void)?
    
    var onSettingsTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return HomeView.createSectionLayout(for: Section.allCases[sectionIndex])
        }
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.register(AIChatSectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeaderAIChat,
                                withReuseIdentifier: AIChatSectionView.identifier)
        
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.identifier)
        
        
        addSubview(navigationBar)
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110), // 110
            collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -90)
        ])
        print(iphoneWithButton)
        print("Screen size: \(screenSize.height)")
    }
    
    static func createSectionLayout(for section: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(155),
            heightDimension: .absolute(145)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(155 * 3),
            heightDimension: .absolute(145)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.interGroupSpacing = 10
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10)
        
        var headers: [NSCollectionLayoutBoundarySupplementaryItem] = []
        
        if section.rawValue == 0 {
            let aiChatHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
            let aiChatHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: aiChatHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeaderAIChat,
                alignment: .top
            )
            aiChatHeader.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
            headers.append(aiChatHeader)
        }
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10)
        headers.append(sectionHeader)
        
        sectionLayout.boundarySupplementaryItems = headers
        
        return sectionLayout
    }
}
