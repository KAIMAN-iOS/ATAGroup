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
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var documentContainer: UIView!
    @IBOutlet weak var documentIcon: UIImageView!  {
        didSet {
            documentIcon.backgroundColor = GroupListViewController.configuration.palette.secondary
            documentIcon.cornerRadius = 10
        }
    }

    @IBOutlet weak var updateDocumentButton: UIButton!  {
        didSet {
            updateDocumentButton.backgroundColor = GroupListViewController.configuration.palette.secondary
            updateDocumentButton.titleLabel?.font = .applicationFont(forTextStyle: .footnote)
            updateDocumentButton.setTitle("update document".bundleLocale().uppercased(), for: .normal)
        }
    }
    @IBOutlet weak var documentName: UILabel!
    
    @IBAction func chooseImage() {
        
    }
    
    @IBAction func updateDocument() {
        
    }
    
    func configure(_ group: Group) {
        stackView.setCustomSpacing(8, after: dateLabel.superview!)
        documentContainer.isHidden = group.type.mandatoryDocument == false
        stateContainer.backgroundColor = group.type.color
        state.set(text: group.type.name.uppercased(), for: .caption2, textColor: .white)
        dateLabel.set(text: String(format: "group creation date".bundleLocale(), DateFormatter.readableDateFormatter.string(from: group.creationDate.value)), for: .caption2, textColor: GroupListViewController.configuration.palette.secondaryTexts)
        
        guard group.type.mandatoryDocument == true else { return }
        documentName.set(text: group.documentName, for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
    }
}