//
//  File.swift
//  
//
//  Created by GG on 30/01/2021.
//

import UIKit
import Ampersand
import LabelExtension
import ATAConfiguration
import DateExtension
import UIImageViewExtension
import Nuke
import ImageExtension

protocol DetailGroupDeleteDelegate: NSObjectProtocol {
    func delete(_ group: Group, completion: @escaping (() -> Void))
}

class GroupDetailHeaderCell: UICollectionViewCell {
    @IBOutlet weak var stateContainer: UIView!  {
        didSet {
            stateContainer.cornerRadius = 5
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var deleteButton: UIButton!  {
        didSet {
            deleteButton.setTitle("delete group".bundleLocale(), for: .normal)
            deleteButton.setTitleColor(GroupListViewController.configuration.palette.primary, for: .normal)
            deleteButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 12)
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    weak var deleteDelegate: DetailGroupDeleteDelegate?
    @IBAction func delete() {
        loader.startAnimating()
        loader.isHidden = false
        deleteButton.isHidden = true
        deleteDelegate?.delete(group) { [weak self] in
            self?.loader.stopAnimating()
            self?.deleteButton.isHidden = false
        }
    }
    @IBOutlet weak var loader: UIActivityIndicatorView!  {
        didSet {
            loader.color = GroupListViewController.configuration.palette.primary
            loader.hidesWhenStopped = true
            loader.isHidden = true
        }
    }

    private var group: Group!
    func configure(_ group: Group) {
        self.group = group
        stackView.setCustomSpacing(8, after: dateLabel.superview!)
        stateContainer.backgroundColor = group.type.color
        state.set(text: group.type.name.uppercased(), for: .caption2, textColor: .white)
        dateLabel.set(text: String(format: "group creation date".bundleLocale(), DateFormatter.readableDateFormatter.string(from: group.creationDate.value)), for: .caption2, textColor: GroupListViewController.configuration.palette.secondaryTexts)
    }
}
