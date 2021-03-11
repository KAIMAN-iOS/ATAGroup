//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import Ampersand
import LabelExtension
import ColorExtension
import ATAConfiguration
import UIViewExtension

class GroupListCell: UICollectionViewCell {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupType: UILabel!
    @IBOutlet weak var groupTypeContainer: UIView!  {
        didSet {
            groupTypeContainer.cornerRadius = 5
        }
    }
    @IBOutlet weak var pendinggInvitations: UILabel!
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var separator: UIView!  {
        didSet {
            separator.backgroundColor = GroupListViewController.configuration.palette.lightGray
        }
    }

    
    func configure(_ group: Group) {
        groupTypeContainer.backgroundColor = group.type.color
        groupType.set(text: group.type.name.uppercased(), for: .caption2, textColor: .white)
        groupName.set(text: group.name, for: .body, textColor: GroupListViewController.configuration.palette.mainTexts)
        pendinggInvitations.set(text: String(format: "nb invitation format".bundleLocale(), group.pendingMembers.count), for: .caption1, textColor: GroupListViewController.configuration.palette.inactive)
        numberOfMembers.set(text: String(format: "nb members format".bundleLocale(), group.activeMembers.count), for: .body, textColor: GroupListViewController.configuration.palette.mainTexts)
    }
}
