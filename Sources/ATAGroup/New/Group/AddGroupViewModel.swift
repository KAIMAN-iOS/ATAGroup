//
//  File.swift
//  
//
//  Created by GG on 01/02/2021.
//

import UIKit

class AddGroupViewModel {
    enum Section: Int, Hashable {
        case textFields, document
    }
    
    enum CellType: Hashable {
        static func == (lhs: CellType, rhs: CellType) -> Bool {
            switch (lhs, rhs) {
            case (.groupName, .groupName): return true
            case (.groupType, .groupType): return true
            case (.document, .document): return true
            default: return false
            }
        }
        case groupName(_: String), groupType(_: GroupType), document
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .groupName(let name): hasher.combine(name)
            case .groupType(let groupType): hasher.combine(groupType.name)
            case .document: hasher.combine("DocumentGroup%*¨*¨*")
            }
        }
    }
    
    weak var pickerDatasource: UIPickerViewDataSource!
    weak var pickerDelegate: UIPickerViewDelegate!
    weak var textDelegate: GroupTextCellDelegate!
    weak var photoDelegate: PhotoDelegate?
    // MARK: - DataSource Diffable
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    private var sections: [Section] = []
    private var cellTypes: [CellType] = []
    lazy var group: Group = Group(type: groupTypes.first!, name: "", documentUrl: nil, documentName: nil, creationDate: Date(), members: [])
    private var selectedRow: Int = 0
    
    func updateDocument(with image: UIImage) {
        group.add(image)
        var snap = dataSource.snapshot()
        snap.reloadItems([.document])
        dataSource.apply(snap, animatingDifferences: true, completion: nil)
    }
    
    func update(_ groupType: GroupType) {
        group.type = groupType
        var snap = dataSource.snapshot()
        if snap.itemIdentifiers.contains(.groupType(groupType)) {
            // Fix pour la disparition du placeholder
            if #available(iOS 15.0, *) {
                snap.reconfigureItems([.groupType(groupType)])
            } else {
                // Fallback on earlier versions
                snap.reloadItems([.groupType(groupType)])
            }
        }
        if snap.sectionIdentifiers.contains(.document) && groupType.mandatoryDocument == false {
            snap.deleteSections([.document])
        } else if snap.sectionIdentifiers.contains(.document) == false && groupType.mandatoryDocument == true {
            snap.appendSections([.document])
            snap.appendItems([.document], toSection: .document)
        }
        selectedRow = groupTypes.firstIndex(where: { $0.name == group.type.name }) ?? 0
        dataSource.apply(snap, animatingDifferences: true, completion: nil)
    }
    
    var selectPicker: Bool = false
    func update(_ text: String?, for field: GroupTextCell.FieldType) {
        switch field {
        case .groupName:
            if let text = text {
                group.name = text
            }
        case .groupType: ()
        }
    }

    private var groupTypes: [GroupType] = []
    init(groupTypes: [GroupType]) {
        self.groupTypes = groupTypes
        group.type = groupTypes.first!
    }
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch model {
            case .groupName:
                guard let cell: GroupTextCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(configuration: .groupName)
                cell.delegate = self.textDelegate
                return cell
                
            case .groupType:
                guard let cell: GroupTextCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(configuration: .groupType)
                cell.ataTextfield.textField.text = self.group.type.name.uppercased()
                cell.delegate = self.textDelegate
                (cell.ataTextfield.textField.inputView as? UIPickerView)?.dataSource = self.pickerDatasource
                (cell.ataTextfield.textField.inputView as? UIPickerView)?.delegate = self.pickerDelegate
                (cell.ataTextfield.textField.inputView as? UIPickerView)?.selectRow(self.selectedRow, inComponent: 0, animated: false)
                return cell
                
            case .document:
                guard let cell: GroupDocumentCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.group)
                cell.textDelegate = self.textDelegate
                cell.photoDelegate = self.photoDelegate
                return cell
            }
        }
        let provider: UICollectionViewDiffableDataSource<Section, Group>.SupplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
              return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: "DisclaimerHeader",
                                                                       for: indexPath) as! DisclaimerHeader
            view.configure("new group disclaimer".bundleLocale())
            return view
        }
        dataSource.supplementaryViewProvider = provider
        return dataSource
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .estimated(100))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                              elementKind: UICollectionView.elementKindSectionHeader,
                                                                              alignment: .top)
        return layoutSectionHeader
    }
    
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = false, completion: (() -> Void)? = nil) {
        var snap = SnapShot()
        snap.deleteAllItems()
        sections.removeAll()
        snap.appendSections([.textFields])
        snap.appendItems([.groupType(group.type), .groupName(group.name)], toSection: .textFields)
        if group.type.mandatoryDocument {
            snap.appendSections([.document])
            snap.appendItems([.document], toSection: .document)
        }
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
        guard let sectionType = Section(rawValue: section) else { return nil }
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .estimated(sectionType == .textFields ? 62 : 143)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                          heightDimension: .estimated(sectionType == .textFields ? 62 : 143)),
                                                       subitem: fullItem, count: 1)
        let groupSection = NSCollectionLayoutSection(group: group)
        if sectionType == .textFields {
            groupSection.boundarySupplementaryItems = [createSectionHeader()]
        }
        return groupSection
    }
}
