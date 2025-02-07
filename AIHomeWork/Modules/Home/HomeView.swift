import UIKit

final class HomeView: BaseView {
    
    let collectionView: UICollectionView
    
    override init(frame: CGRect) {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            return HomeView.createSectionLayout(for: Section.allCases[sectionIndex])
        }
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
    }
    
    override func setupUI() {
        backgroundColor = .black
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        collectionView.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.identifier)
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    static func createSectionLayout(for section: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = 10
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        
        return sectionLayout
    }
}
