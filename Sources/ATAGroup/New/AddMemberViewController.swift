//
//  File.swift
//  
//
//  Created by GG on 01/02/2021.
//

import UIKit
import ActionButton
import PromiseKit

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
        }
    }

    @IBOutlet weak var addButton: ActionButton!  {
        didSet {
            addButton.setTitle("add member button".bundleLocale(), for: .normal)
        }
    }
    private var group: Group!
    weak var delegate: AddMemberDelegate!
    
    static func create(group: Group, delegate: AddMemberDelegate) -> AddMemberViewController {
        let ctrl: AddMemberViewController = UIStoryboard(name: "ATAGroup", bundle: Bundle.module).instantiateViewController(identifier: "AddMemberViewController") as! AddMemberViewController
        ctrl.group = group
        ctrl.delegate = delegate
        return ctrl
    }
    
    @IBAction func addMember() {
        addButton.isLoading = true
        delegate.add(textField.text!, to: group) { [weak self] in
            self?.addButton.isLoading = false
        }
    }
}
