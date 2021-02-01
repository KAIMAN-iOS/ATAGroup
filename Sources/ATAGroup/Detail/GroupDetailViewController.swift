//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit

class GroupDetailViewController: UIViewController {
    
    static func create(group: Group, delegate: GroupCoordinatorDelegate) -> GroupDetailViewController {
        let ctrl: GroupDetailViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "GroupDetailViewController") as! GroupDetailViewController
        ctrl.viewModel = GroupDetailViewModel(group: group)
        ctrl.coordinatorDelegate = delegate
        ctrl.title = group.name
        return ctrl
    }
    weak var coordinatorDelegate: GroupCoordinatorDelegate?
    var viewModel: GroupDetailViewModel!
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
        }
    }
    var datasource: GroupDetailViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = viewModel.layout()
        datasource = viewModel.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        viewModel.applySnapshot(in: datasource)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add member".bundleLocale(), style: .plain, target: self, action: #selector(addMember))
    }
    
    @objc private func addMember() {
        coordinatorDelegate?.addNewMember(in: viewModel.group)
    }
    
    func didAdd(_ member: GroupMember) {
        viewModel.didAdd(member)
    }
}

extension GroupDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let delete = UIAction(title: "Delete".local(), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            self?.viewModel.delete(itemAt: indexPath)
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "Actions".local(), children: [delete])
        }
    }
}
