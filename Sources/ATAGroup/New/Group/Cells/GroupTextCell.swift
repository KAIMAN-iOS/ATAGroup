//
//  DocumentDetailTextCell.swift
//  taxi.Chauffeur
//
//  Created by GG on 04/11/2020.
//

import UIKit
import FontExtension
import LabelExtension
import TextFieldExtension
import Ampersand
import ATAViews

protocol GroupTextCellDelegate: NSObjectProtocol {
    func textChanged(_ text: String?, for field: GroupTextCell.FieldType)
    func willResignActive()
    func willBecomeActive(_ field: GroupTextCell.FieldType)
}

extension GroupTextCellDelegate {
    func textChanged(_ text: String?, for field: GroupTextCell.FieldType) {}
}

class GroupTextCell: UICollectionViewCell {
    enum FieldType {
        case groupName, groupType
        
        var placeholder: String {
            switch self {
            case .groupName: return "groupName".bundleLocale().uppercased()
            case .groupType: return "groupType".bundleLocale().uppercased()
            }
        }
        
        var keyboardType: UIKeyboardType? {
            switch self {
            case .groupType: return nil
            case .groupName: return .asciiCapable
            }
        }
        
        func inputView(textField: UITextField, target: UIView? = nil, viewColor: UIColor = UIColor.lightGray) -> UIView? {
            switch self {
            case .groupType:
                let screenWidth = UIScreen.main.bounds.width
                let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
                textField.inputView = picker
                textField.addKeyboardControlView(with: viewColor, target: target ?? textField, buttonStyle: .body)
                return picker
                
            default: return nil
            }
        }
    }
    
    @IBOutlet weak var ataTextfield: ATATextField!
//
//    @IBOutlet weak var textfield: UITextField!  {
//        didSet {
//            layoutTextfield()
//        }
//    }
//
//
//    func layoutTextfield() {
//        textfield.textColor = GroupListViewController.configuration.palette.mainTexts
//        textfield.backgroundColor = .white
//        textfield.setContentCompressionResistancePriority(.required, for: .vertical)
//        textfield.font = .applicationFont(forTextStyle: .body)
//        textfield.rightViewMode = .whileEditing
//        textfield.superview?.layer.borderWidth = 1.0
//        textfield.superview?.layer.borderColor = GroupListViewController.configuration.palette.inactive.cgColor
//        textfield.delegate = self
//    }
    
    weak var delegate: GroupTextCellDelegate?
    var fieldType: GroupTextCell.FieldType!
    func configure(configuration: GroupTextCell.FieldType) {
//        layoutTextfield()
        self.fieldType = configuration
        ataTextfield.textField.placeholder = configuration.placeholder
        let view = configuration.inputView(textField: ataTextfield.textField, target: self, viewColor: GroupListViewController.configuration.palette.secondary)
        ataTextfield.textField.inputView = view
        ataTextfield.textField.keyboardType = configuration.keyboardType ?? .asciiCapable
        ataTextfield.textField.delegate = self
        ataTextfield.textField.addKeyboardControlView(target: self, buttonStyle: .footnote)
    }
}

extension GroupTextCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.textChanged(ataTextfield.textField.text, for: fieldType)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.willBecomeActive(fieldType)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.willBecomeActive(fieldType)
        return true
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        delegate?.willResignActive()
        return super.endEditing(force)
    }
}
