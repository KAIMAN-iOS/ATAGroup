//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit
import UIViewControllerExtension

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
        viewModel.deleteDelegate = self
        viewModel.photoDelegate = self
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
            self.viewModel.updateDocument(with: image)
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
        let alertController = UIAlertController(title: "Delete group".bundleLocale(), message: "Delete group warning".bundleLocale(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel".bundleLocale(), style: .cancel, handler: {_ in
            completion()
        }))
        alertController.addAction(UIAlertAction(title: "Delete".bundleLocale(), style: .default, handler: { [weak self] _ in
            self?.coordinatorDelegate?.delete(group: group) { _ in
                completion()
            }
        }))
        alertController.view.tintColor = GroupListViewController.configuration.palette.primary
        present(alertController, animated: true, completion: nil)
        
    }
}

extension GroupDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let delete = UIAction(title: "Delete".local(), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            if let member = self.viewModel.memeber(at: indexPath) {
                self.coordinatorDelegate?.delete(member: member, from: self.viewModel.group, completion: { [weak self] success in
                    if success {
                        self?.viewModel.delete(itemAt: indexPath)
                    }
                })
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "Actions".local(), children: [delete])
        }
    }
}
