//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit

class GroupDetailViewModel {
    enum Section: Int, Hashable, CaseIterable {
        case header = 0, invitation, member
        
        var height: CGFloat {
            switch self {
            case .header: return 134
            case .invitation: return 75
            case .member: return 84
            }
        }
    }
    
    enum CellType: Hashable {
        static func == (lhs: CellType, rhs: CellType) -> Bool {
            switch (lhs, rhs) {
            case (.header(let leftGroup), .header(let rightGroup)): return leftGroup == rightGroup
            case (.invitation(let leftGroup), .invitation(let rightGroup)): return leftGroup == rightGroup
            case (.member(let leftMember), .member(let rightMember)): return leftMember == rightMember
            default: return false
            }
        }
        case header(_: Group)
        case invitation(_: Group)
        case member(_: GroupMember)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .invitation: hasher.combine("invitation")
            case .header: hasher.combine("header")
            case .member(let member):
                hasher.combine("member")
                hasher.combine(member)
            }
        }
    }
    private(set) var group: Group!
    init(group: Group) {
        self.group = group
    }
    
    // MARK: - DataSource Diffable
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    weak var deleteDelegate: DetailGroupDeleteDelegate?
    weak var photoDelegate: PhotoDelegate?
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch model {
            case .header(let group):
                guard let cell: GroupDetailHeaderCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(group)
                cell.deleteDelegate = self.deleteDelegate
                cell.photoDelegate = self.photoDelegate
                return cell
                
            case .invitation(let group):
                guard let cell: GroupDetailInvitationStateCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(group)
                return cell
                
            case .member(let member):
                guard let cell: GroupDetailMemberCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(member)
                return cell
            }
        }
        return dataSource
    }
    
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        var snap = SnapShot()
        snap.deleteAllItems()
        snap.appendSections(Section.allCases)
        snap.appendItems([.header(group)], toSection: .header)
        snap.appendItems([.invitation(group)], toSection: .invitation)
        let members = group.members.sorted().compactMap({ CellType.member($0) })
        snap.appendItems(members, toSection: .member)
        // add items here
        dataSource.apply(snap, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    // MARK: - CollectionView Layout Modern API
    func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            return self.generateLayout(for: section, environnement: env)
        }
        return layout
    }
    
    private func generateLayout(for section: Int, environnement: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        guard let sectionModel = Section(rawValue: section) else { return nil }
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(sectionModel.height)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(sectionModel.height)),
                                                       subitem: fullItem, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func memeber(at indexPath: IndexPath) -> GroupMember? {
        guard let cellType = dataSource.itemIdentifier(for: indexPath) else { return nil }
        switch cellType {
        case .member(let member): return member
        default: return nil
        }
    }
    
    func delete(itemAt indexPath: IndexPath) {
        guard let cellType = dataSource.itemIdentifier(for: indexPath) else { return }
        switch cellType {
        case .member(let member):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var snap = self.dataSource.snapshot()
                snap.deleteItems([cellType])
                self.group.members.removeAll(where: { $0.email == member.email })
                self.applySnapshot(in: self.dataSource)
            }
            
        default: ()
        }
    }
    
    func didAdd(_ member: GroupMember) {
        group.members.append(member)
        applySnapshot(in: dataSource)
    }
    
    func updateDocument(with image: UIImage) {
        group.add(image)
        var snap = dataSource.snapshot()
        snap.deleteItems([.header(group)])
        snap.insertItems([.header(group)], beforeItem: .invitation(group))
        dataSource.apply(snap, animatingDifferences: true, completion: nil)
    }
}
