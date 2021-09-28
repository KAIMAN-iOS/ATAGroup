//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import UIViewControllerExtension
import ATAConfiguration
import Ampersand

class GroupListViewController: UIViewController {
    static var configuration: ATAConfiguration!
    static func create(groups: [Group], configuration: ATAConfiguration, delegate: GroupCoordinatorDelegate, groupDataSource: GroupDatasource) -> GroupListViewController {
        GroupListViewController.configuration = configuration
        let ctrl: GroupListViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "GroupListViewController") as! GroupListViewController
        ctrl.viewModel = GroupListViewModel(groups: groups)
        ctrl.coordinatorDelegate = delegate
        ctrl.groupDataSource = groupDataSource
        return ctrl
    }
    weak var coordinatorDelegate: GroupCoordinatorDelegate?
    weak var groupDataSource: GroupDatasource?
    
    var viewModel: GroupListViewModel!
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "DisclaimerHeader", bundle: .module), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DisclaimerHeader")
            collectionView.backgroundColor = GroupListViewController.configuration.palette.background
        }
    }
    var datasource: GroupListViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupListViewController.configuration.palette.background
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "My groups".bundleLocale().capitalized
        hideBackButtonText = true
        collectionView.collectionViewLayout = viewModel.layout()
        datasource = viewModel.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        viewModel.applySnapshot(in: datasource)
        startLoading()
    }
    
    private func startLoading() {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.color = GroupListViewController.configuration.palette.primary
        activity.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
    }
    
    func refreshComplete() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ add new group".bundleLocale(), style: .plain, target: self, action: #selector(addNewGroup))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font : UIFont.applicationFont(ofSize: 16.0),
                                                                   .foregroundColor : GroupListViewController.configuration.palette.mainTexts], for: .normal)
    }
    
    func update(_ groups: [Group]) {
        viewModel.update(groups)
        refreshComplete()
    }
    
    @objc func addNewGroup() {
        coordinatorDelegate?.addNewGroup()
    }
    
    func didAdd(_ group: Group) {
        viewModel.didAdd(group)
    }
    
    func didUpdate(_ group: Group) {
        viewModel.didUpdate(group)
    }
    
    func delete(itemAt indexPath: IndexPath) {
        guard let group = datasource.itemIdentifier(for: indexPath) else { return }
        showDeleteConfirmation(with: "Delete group warning".bundleLocale(),
                               tintColor: GroupListViewController.configuration.palette.primary) { [weak self] shouldDelete in
            if shouldDelete {
                self?.coordinatorDelegate?.delete(group: group) { [weak self] success in
                    guard success == true else { return }
                    self?.didDelete(group)
                }
            } 
        }
    }
    
    func didDelete(_ group: Group) {
        viewModel.delete(group: group)
    }
    
    func didAdd(member: GroupMember, to group: Group) {
        viewModel.didAdd(member: member, to: group)
    }
    
    func didRemove(member: GroupMember, from group: Group) {
        viewModel.didRemove(member: member, from: group)
    }
}

extension GroupListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let group = datasource.itemIdentifier(for: indexPath) else { return }
        coordinatorDelegate?.showDetail(for: group)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let group = datasource.itemIdentifier(for: indexPath), group.adminEmail == groupDataSource?.currentUserEmail else { return nil }
        
        let delete = UIAction(title: "Delete".bundleLocale(), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            self?.delete(itemAt: indexPath)
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "Actions".bundleLocale(), children: [delete])
        }
    }
}

extension UIViewController {
    func showDeleteConfirmation(with message: String, tintColor: UIColor?, completion: @escaping ((Bool) -> Void)) {
        let alertController = UIAlertController(title: "Delete group".bundleLocale(), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel".bundleLocale(), style: .cancel, handler: {_ in
            completion(false)
        }))
        alertController.addAction(UIAlertAction(title: "Delete".bundleLocale(), style: .default, handler: { [weak self] _ in
            completion(true)
        }))
        alertController.view.tintColor = tintColor
        present(alertController, animated: true, completion: nil)
    }
}
