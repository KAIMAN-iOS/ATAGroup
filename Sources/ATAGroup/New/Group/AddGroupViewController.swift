//
//  File.swift
//  
//
//  Created by GG on 01/02/2021.
//

import UIKit
import TableViewExtension
import ActionButton
import UIViewControllerExtension

protocol AddGroupDelegate: NSObjectProtocol {
    func create(_ group: Group, completion: (() -> Void)?)
}

class AddGroupViewController: UIViewController {
    static func create(groupTypes: [GroupType], delegate: AddGroupDelegate) -> AddGroupViewController {
        let ctrl: AddGroupViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "AddGroupViewController") as! AddGroupViewController
        ctrl.delegate = delegate
        ctrl.groupTypes = groupTypes
        ctrl.viewModel = AddGroupViewModel(groupTypes: groupTypes)
        return ctrl
    }
    weak var delegate: AddGroupDelegate!
    var viewModel: AddGroupViewModel!  {
        didSet {
            viewModel.pickerDelegate = self
            viewModel.pickerDatasource = self
        }
    }

    private var groupTypes: [GroupType] = []
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "DisclaimerHeader", bundle: .module), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DisclaimerHeader")
        }
    }
    @IBOutlet weak var createButton: ActionButton!  {
        didSet {
            createButton.setTitle("create group".bundleLocale(), for: .normal)
            createButton.actionButtonType = .primary
            createButton.isEnabled = false
        }
    }

    @IBAction func createGroup() {
        createButton.isLoading = true
        delegate.create(viewModel.group) { [weak self] in
            self?.createButton.isLoading = false
        }
    }
    
    func updateCreateButtonState() {
        createButton.isEnabled = viewModel.group.isValid
    }
    
    var datasource: AddGroupViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "new group".bundleLocale().capitalized
        collectionView.collectionViewLayout = viewModel.layout()
        datasource = viewModel.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        viewModel.textDelegate = self
        viewModel.photoDelegate = self
        viewModel.applySnapshot(in: datasource)
    }
}

extension AddGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.updateCreateButtonState()
        }
    }
}

extension AddGroupViewController: PhotoDelegate {
    func choosePicture() {
        presentImagePickerChoice(delegate: self, tintColor: GroupListViewController.configuration.palette.primary)
    }
}

extension AddGroupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? GroupTextCell, cell.fieldType == .groupType, viewModel.selectPicker == true else { return }
        cell.textfield.becomeFirstResponder()
    }
}

extension AddGroupViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { groupTypes.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { groupTypes[row].name.uppercased() }
}

extension AddGroupViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard viewModel.selectPicker == true else { return }
        viewModel.update(groupTypes[row])
        updateCreateButtonState()
    }
}

extension AddGroupViewController: GroupTextCellDelegate {
    func willBecomeActive(_ field: GroupTextCell.FieldType) {
        switch field {
        case .groupType: viewModel.selectPicker = true
        default: ()
        }
    }
    
    func textChanged(_ text: String?, for field: GroupTextCell.FieldType) {
        viewModel.update(text, for: field)
        updateCreateButtonState()
    }
    
    func willResignActive() {
        viewModel.selectPicker = false
        updateCreateButtonState()
    }
}
