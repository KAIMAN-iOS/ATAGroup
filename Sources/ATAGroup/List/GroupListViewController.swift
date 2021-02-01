//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import UIViewControllerExtension
import ATAConfiguration

class GroupListViewController: UIViewController {
    static var configuration: ATAConfiguration!
    static func create(groups: [Group], configuration: ATAConfiguration, delegate: GroupCoordinatorDelegate) -> GroupListViewController {
        GroupListViewController.configuration = configuration
        let ctrl: GroupListViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "GroupListViewController") as! GroupListViewController
        ctrl.viewModel = GroupListViewModel(groups: groups)
        ctrl.coordinatorDelegate = delegate
        return ctrl
    }
    weak var coordinatorDelegate: GroupCoordinatorDelegate?
    
    var viewModel: GroupListViewModel!
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
        }
    }
    var datasource: GroupListViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    func update(_ groups: [Group]) {
        viewModel.update(groups)
        refreshComplete()
    }
    
    @objc func addNewGroup() {
        
    }
}

extension GroupListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let group = datasource.itemIdentifier(for: indexPath) else { return }
        coordinatorDelegate?.showDetail(for: group)
    }
}
