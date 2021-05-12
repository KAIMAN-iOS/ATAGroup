//
//  File.swift
//  
//
//  Created by GG on 01/02/2021.
//

import UIKit
import ActionButton
import PromiseKit
import StringExtension

protocol AddMemberDelegate: NSObjectProtocol {
    func add(_ email: String, to group: Group, completion: (() -> Void)?)
}

class AddMemberViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!  {
        didSet {
            titleLabel.set(text: "add member title".bundleLocale().uppercased(), for: .title3, textColor: .white)
        }
    }

    @IBOutlet weak var textField: UITextField!  {
        didSet {
            textField.placeholder = "email".bundleLocale().uppercased()
            textField.delegate = self
        }
    }

    @IBOutlet weak var addButton: ActionButton!  {
        didSet {
            addButton.setTitle("add member button".bundleLocale(), for: .normal)
            addButton.actionButtonType = .confirmation
            addButton.isEnabled = isValid
        }
    }
    private var group: Group!
    weak var delegate: AddMemberDelegate!
    var isValid: Bool = false  {
        didSet {
            guard addButton != nil else { return }
            addButton.isEnabled = isValid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addKeyboardControlView(target: self.view, buttonStyle: .footnote)
    }

    static func create(group: Group, delegate: AddMemberDelegate) -> AddMemberViewController {
        let ctrl: AddMemberViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "AddMemberViewController") as! AddMemberViewController
        ctrl.group = group
        ctrl.view.backgroundColor = GroupListViewController.configuration.palette.backgroundDark
        ctrl.delegate = delegate
        return ctrl
    }
    
    @IBAction func addMember() {
        textField.resignFirstResponder()
        addButton.isLoading = true
        delegate.add(textField.text!, to: group) { [weak self] in
            self?.addButton.isLoading = false
        }
    }
}

extension AddMemberViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let actualText = textField.text,
              let textRange = Range(range, in: actualText) else {
            isValid = false
            return true
        }
        let updatedText = actualText.replacingCharacters(in: textRange, with: string)
        isValid = updatedText.isValidEmail
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // perform action if needed
        if textField.text?.isValidEmail ?? false == true {
            addMember()
        }
        return true
    }
}
