//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import TableViewExtension

class GroupListViewModel {
    var groups: [Group] = []
    init(groups: [Group]) {
        self.groups = groups
    }
    
    enum Section: Int, Hashable {
        case main
    }
    
    // MARK: - DataSource Diffable
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Group>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, Group>
    private var dataSource: DataSource!
    private var sections: [Section] = []
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { (collection, indexPath, model) -> UICollectionViewCell? in
            guard let cell: GroupListCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
            cell.configure(model)
            return cell
        }
        let provider: UICollectionViewDiffableDataSource<Section, Group>.SupplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
              return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: "DisclaimerHeader",
                                                                       for: indexPath) as! DisclaimerHeader
            return view
        }
        dataSource.supplementaryViewProvider = provider
        return dataSource
    }
    
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        var snap = SnapShot()
        snap.deleteAllItems()
        sections.removeAll()
        snap.appendSections([.main])
        // add items here
        snap.appendItems(groups.sorted(), toSection: .main)
        dataSource.apply(snap, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    func update(_ groups: [Group]) {
        self.groups = groups
        applySnapshot(in: dataSource)
    }
    
   private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
       let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(100))
       let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                             elementKind: UICollectionView.elementKindSectionHeader,
                                                                             alignment: .top)
       return layoutSectionHeader
   }
    
    // MARK: - CollectionView Layout Modern API
    func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            return self.generateLayout(for: section, environnement: env)
        }
        return layout
    }
    
    private func generateLayout(for section: Int, environnement: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(77)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(77)),
                                                       subitem: fullItem, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
}
