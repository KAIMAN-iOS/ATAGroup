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
    @IBOutlet weak var documentUpdateDate: UILabel!
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
    @IBOutlet weak var documentContainer: UIView!
    @IBOutlet weak var documentIcon: UIImageView!  {
        didSet {
            documentIcon.backgroundColor = GroupListViewController.configuration.palette.secondary
            documentIcon.cornerRadius = 10
            documentIcon.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var documentName: UILabel!
    
    @IBAction func chooseImage() {
        photoDelegate?.choosePicture()
    }
    weak var photoDelegate: PhotoDelegate?
    var imageTask: ImageTask?
    var image: GroupImage?  {
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
        translatesAutoresizingMaskIntoConstraints = false
        contentView.subviews.first?.translatesAutoresizingMaskIntoConstraints = false
        self.group = group
        documentIcon.image = UIImage(systemName: "pencil")
        image = group.image
        stackView.setCustomSpacing(8, after: dateLabel.superview!)
        documentContainer.isHidden = group.type.mandatoryDocument == false
        stateContainer.backgroundColor = group.type.color
        state.set(text: group.type.name.uppercased(), for: .caption2, textColor: .white)
        dateLabel.set(text: String(format: "group creation date".bundleLocale(), DateFormatter.readableDateFormatter.string(from: group.creationDate.value)), for: .caption2, textColor: GroupListViewController.configuration.palette.secondaryTexts)
        
        guard group.type.mandatoryDocument == true else { return }
        documentName.set(text: group.documentName, for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        documentUpdateDate.isHidden = group.updateDate == nil
        if let date = group.updateDate?.value {
            documentUpdateDate.set(text: DateFormatter.readableDateFormatter.string(from: date), for: .caption2, textColor: GroupListViewController.configuration.palette.mainTexts)
        }
    }
}
