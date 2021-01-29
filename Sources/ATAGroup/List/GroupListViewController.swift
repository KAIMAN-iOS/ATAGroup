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
    static func create(groups: [Group], configuration: ATAConfiguration) -> GroupListViewController {
        GroupListViewController.configuration = configuration
        let ctrl: GroupListViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "GroupListViewController") as! GroupListViewController
        ctrl.viewModel = GroupListViewModel(groups: groups)
        return ctrl
    }
    
    var viewModel: GroupListViewModel!
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
        }
    }
    var datasource: GroupListViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBackButtonText = true
        collectionView.collectionViewLayout = viewModel.layout()
        datasource = viewModel.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        viewModel.applySnapshot(in: datasource)
    }
}

extension GroupListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
