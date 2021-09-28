//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit
import UIViewControllerExtension
import Ampersand

class GroupDetailViewController: UIViewController {
    
    static func create(group: Group, delegate: GroupCoordinatorDelegate, memberDelegate: AddMemberDelegate, groupDataSource: GroupDatasource) -> GroupDetailViewController {
        let ctrl: GroupDetailViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "GroupDetailViewController") as! GroupDetailViewController
        ctrl.viewModel = GroupDetailViewModel(group: group, isAdmin: groupDataSource.currentUserEmail == group.adminEmail)
        ctrl.viewModel.memberDelegate = memberDelegate
        ctrl.coordinatorDelegate = delegate
        ctrl.title = group.name
        return ctrl
    }
    weak var groupDataSource: GroupDatasource?
    weak var coordinatorDelegate: GroupCoordinatorDelegate?
    var viewModel: GroupDetailViewModel!
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
            collectionView.backgroundColor = GroupListViewController.configuration.palette.background
        }
    }
    var datasource: GroupDetailViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupListViewController.configuration.palette.background
        collectionView.collectionViewLayout = viewModel.layout()
        datasource = viewModel.dataSource(for: collectionView)
        viewModel.deleteDelegate = self
        viewModel.photoDelegate = self
        collectionView.dataSource = datasource
        viewModel.applySnapshot(in: datasource)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add member".bundleLocale(), style: .plain, target: self, action: #selector(addMember))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font : UIFont.applicationFont(ofSize: 16.0),
                                                                   .foregroundColor : GroupListViewController.configuration.palette.mainTexts], for: .normal)
    }
    
    @objc private func addMember() {
        coordinatorDelegate?.addNewMember(in: viewModel.group)
    }
    
    func didAdd(_ member: GroupMember) {
        viewModel.didAdd(member)
    }
}

extension GroupDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
                return
            }
            self.viewModel.updateDocument(with: image) { [weak self] in
                self?.collectionView.scrollRectToVisible(CGRect(origin: CGPoint(x: 0, y: -1), size: .zero), animated: true)
            }
        }
    }
}

extension GroupDetailViewController: PhotoDelegate {
    func choosePicture() {
        presentImagePickerChoice(delegate: self, tintColor: GroupListViewController.configuration.palette.primary)
    }
}

extension GroupDetailViewController: DetailGroupDeleteDelegate {
    func delete(_ group: Group, completion: @escaping (() -> Void)) {
        delete(with: "Delete group warning".bundleLocale()) { shouldDelete in
            if shouldDelete {
                self.coordinatorDelegate?.delete(group: group) { _ in
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    func delete(with message: String, completion: @escaping ((Bool) -> Void)) {
        showDeleteConfirmation(with: message,
                               tintColor: GroupListViewController.configuration.palette.primary,
                               completion: completion)
    }
}

extension GroupDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard viewModel.shouldShowMenuForCell(at: indexPath) else { return nil }
        
        let delete = UIAction(title: "Delete".bundleLocale(), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            if let member = self.viewModel.memeber(at: indexPath) {
                self.delete(with: "Delete member warning".bundleLocale()) { [weak self] shouldDelete in
                    guard let self = self else { return }
                    if shouldDelete {
                        self.coordinatorDelegate?.delete(member: member, from: self.viewModel.group, completion: { [weak self] success in
                            if success {
                                self?.viewModel.delete(itemAt: indexPath)
                            }
                        })
                    }
                }
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "Actions".bundleLocale(), children: [delete])
        }
    }
}
