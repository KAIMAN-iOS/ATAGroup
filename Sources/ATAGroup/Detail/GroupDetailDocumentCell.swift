//
//  File.swift
//  
//
//  Created by GG on 11/03/2021.
//

import UIKit
import Ampersand
import LabelExtension
import ATAConfiguration
import DateExtension
import UIImageViewExtension
import Nuke
import ImageExtension

class GroupDetailDocumentCell: UICollectionViewCell {
    @IBOutlet weak var documentContainer: UIView!
    @IBOutlet weak var documentIcon: UIImageView!  {
        didSet {
            documentIcon.backgroundColor = GroupListViewController.configuration.palette.secondary
            documentIcon.cornerRadius = 10
            documentIcon.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var documentName: UILabel!
    @IBOutlet weak var documentUpdateDate: UILabel!
    
    @IBAction func chooseImage() {
        photoDelegate?.choosePicture()
    }
    weak var photoDelegate: PhotoDelegate?
    var imageTask: ImageTask?
    var image: CodableImage?  {
        didSet {
            guard let image = image else {
                documentIcon.image = UIImage(systemName: "photo.on.rectangle")
                documentIcon.contentMode = .center
                return
            }
            
            if let actualImage = image.image {
                documentIcon.image = actualImage
                documentIcon.contentMode = .scaleAspectFill
            } else if let url = image.imageURL {
                documentIcon.image = nil // remove the user documents image
                imageTask = documentIcon.downloadImage(from: url, placeholder: UIImage(systemName: "photo.on.rectangle"), activityColor: GroupListViewController.configuration.palette.primary)
                documentIcon.contentMode = .scaleAspectFill
            } else {
                documentIcon.image = UIImage(systemName: "photo.on.rectangle")
                documentIcon.contentMode = .center
            }
        }
    }

    override func prepareForReuse() {
        imageTask?.cancel()
        imageTask = nil
    }
    
    private var group: Group!
    func configure(_ group: Group) {
        contentView.backgroundColor = GroupListViewController.configuration.palette.background
        self.group = group
        image = group.image
        documentName.set(text: group.documentName, for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        documentUpdateDate.isHidden = group.updateDate == nil
        if let date = group.updateDate?.value {
            documentUpdateDate.set(text: DateFormatter.readableDateFormatter.string(from: date), for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        }
    }
}
