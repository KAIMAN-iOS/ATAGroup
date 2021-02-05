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

class GroupDetailMemberCell: UICollectionViewCell {
    @IBOutlet weak var stateContainer: UIView!  {
        didSet {
            stateContainer.cornerRadius = 5
        }
    }
    @IBOutlet weak var separator: UIView!  {
        didSet {
            separator.backgroundColor = GroupListViewController.configuration.palette.lightGray
        }
    }

    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var vehicle: UILabel!
    @IBOutlet weak var location: UILabel!
    
    func configure(_ member: GroupMember) {
        stateContainer.backgroundColor = member.status.color
        state.set(text: member.status.title.uppercased(), for: .caption2, textColor: .white)
        email.set(text: member.email, for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        name.set(text: member.name ?? "-", for: .caption2, traits: [.traitBold], textColor: GroupListViewController.configuration.palette.mainTexts)
        vehicle.set(text: member.vehicle ?? "-", for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        location.set(text: member.location ?? "-", for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
    }
}
