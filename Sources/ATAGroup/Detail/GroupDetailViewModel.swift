//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit
import Alamofire
import ImageExtension

class GroupDetailViewModel {
    enum Section: Int, Hashable, CaseIterable {
        case header = 0, documentImage, invitation, member
        
        var height: CGFloat {
            switch self {
            case .header: return 50
            case .documentImage: return 111
            case .invitation: return 65
            case .member: return 84
            }
        }
        
        var dimension: NSCollectionLayoutDimension {
            switch self {
            case .documentImage: return .absolute(height)
            default: return .estimated(height)
            }
        }
    }
    
    enum CellType: Hashable {
        static func == (lhs: CellType, rhs: CellType) -> Bool {
            switch (lhs, rhs) {
            case (.header(let leftGroup), .header(let rightGroup)): return leftGroup == rightGroup
            case (.documentImage(let leftGroup), .documentImage(let rightGroup)): return true
            case (.invitation(let leftGroup), .invitation(let rightGroup)): return leftGroup == rightGroup
            case (.member(let leftMember), .member(let rightMember)): return leftMember == rightMember
            default: return false
            }
        }
        case header(_: Group)
        case documentImage(_: String)
        case invitation(_: Group)
        case member(_: GroupMember)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .invitation: hasher.combine("invitation")
            case .header: hasher.combine("header")
            case .documentImage(let imageName):
                hasher.combine("documentImage")
                hasher.combine(imageName)
            case .member(let member):
                hasher.combine("member")
                hasher.combine(member)
            }
        }
    }
    private(set) var group: Group!
    var isAdmin: Bool = false
    private var sections: [Section] = []
    init(group: Group, isAdmin: Bool) {
        self.group = group
        self.isAdmin = isAdmin
    }
    
    // MARK: - DataSource Diffable
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    weak var deleteDelegate: DetailGroupDeleteDelegate?
    weak var photoDelegate: PhotoDelegate?
    weak var memberDelegate: AddMemberDelegate!
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch model {
            case .header(let group):
                guard let cell: GroupDetailHeaderCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(group, isAdmin: self.isAdmin)
                cell.deleteDelegate = self.deleteDelegate
                return cell
                
            case .documentImage:
                guard let cell: GroupDetailDocumentCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.group)
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
    
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = false, completion: (() -> Void)? = nil) {
        var snap = SnapShot()
        snap.deleteAllItems()
        sections.append(contentsOf: [.header, .invitation, .member])
        snap.appendSections([.header])
        snap.appendItems([.header(group)], toSection: .header)
        if group.type.mandatoryDocument {
            sections.insert(.documentImage, at: 1)
            snap.appendSections([.documentImage])
            snap.appendItems([.documentImage(group.image?.imageName ?? "")], toSection: .documentImage)
        }
        snap.appendSections([.invitation])
        snap.appendItems([.invitation(group)], toSection: .invitation)
        snap.appendSections([.member])
        let members = group
            .members
            .sorted()
            .compactMap({ CellType.member($0) })
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
        guard section < sections.count, let sectionModel = Optional.some(sections[section]) else { return nil }
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionModel.dimension))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionModel.dimension),
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
    
    func update(_ group: Group) {
        self.group = group
        self.group.members = group.members
        applySnapshot(in: dataSource)
    }
    
    func updateDocument(with image: UIImage, groupDataSource: GroupDatasource? = nil, completion: @escaping (() -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snap = self.dataSource.snapshot()
//            snap.deleteItems([.documentImage(self.group)])
            self.group.add(image)
            snap.reloadSections([.documentImage])
//            snap.insertItems([.documentImage(self.group.image.imageName)], afterItem: .header(self.group))
            self.dataSource.apply(snap, animatingDifferences: false, completion: completion)
        }
    }
    
    func shouldShowMenuForCell(at indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath), isAdmin else {
            return false
        }
        switch item {
        case .member: return true
        default: return false
        }
    }
}
