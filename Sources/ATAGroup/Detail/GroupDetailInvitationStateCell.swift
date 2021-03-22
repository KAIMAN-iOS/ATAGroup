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

class GroupDetailInvitationStateCell: UICollectionViewCell {
    @IBOutlet weak var invitations: UILabel!
    @IBOutlet weak var members: UILabel!
    @IBOutlet weak var card: UIView!
    
    func configure(_ group: Group) {
        contentView.backgroundColor = GroupListViewController.configuration.palette.background
        card.backgroundColor = GroupListViewController.configuration.palette.lightGray
        // members
        let memberFormatString : String = NSLocalizedString("NumberOfMember", bundle: .module, comment: "NumberOfMember")
        let memberResultString : String = String.localizedStringWithFormat(memberFormatString, group.activeMembers.count)
        members.set(text: memberResultString.uppercased(), for: .footnote, textColor: GroupListViewController.configuration.palette.secondaryTexts)
        // invitation
        let invitationFormatString : String = NSLocalizedString("NumberOfInvitation", bundle: .module, comment: "NumberOfInvitation")
        let invitationResultString : String = String.localizedStringWithFormat(invitationFormatString, group.pendingMembers.count)
        invitations.set(text: invitationResultString.uppercased(), for: .footnote, textColor: GroupListViewController.configuration.palette.secondaryTexts)
    }
}
