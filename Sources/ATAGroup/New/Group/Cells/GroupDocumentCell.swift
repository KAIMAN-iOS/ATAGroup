//
//  File.swift
//  
//
//  Created by GG on 01/02/2021.
//

import UIKit
import LabelExtension
import Ampersand
import UIImageViewExtension
import Nuke

protocol PhotoDelegate: class {
    func choosePicture(from imageView: GroupDocumentCell)
}

class GroupDocumentCell: UICollectionViewCell {
    weak var textDelegate: GroupTextCellDelegate?
    @IBOutlet weak var disclaimer: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.textColor = GroupListViewController.configuration.palette.mainTexts
            textField.backgroundColor = .white
            textField.setContentCompressionResistancePriority(.required, for: .vertical)
            textField.font = .applicationFont(forTextStyle: .callout)
            textField.rightViewMode = .whileEditing
            textField.placeholder = "document name".bundleLocale().uppercased()
            textField.superview?.layer.borderWidth = 1.0
            textField.superview?.layer.borderColor = GroupListViewController.configuration.palette.inactive.cgColor
            textField.delegate = self
        }
    }
    weak var photoDelegate: PhotoDelegate?
    @IBOutlet weak var documentImage: UIImageView!
    
    @IBAction func choosePicture() {
        photoDelegate?.choosePicture(from: self)
    }
    var imageTask: ImageTask?
    var image: GroupImage?  {
        didSet {
            guard let image = image else {
                documentImage.image = UIImage(systemName: "photo.on.rectangle")
                documentImage.contentMode = .center
                documentImage.backgroundColor = GroupListViewController.configuration.palette.secondary
                return
            }
            
            if let image = image.image {
                documentImage.image = image
                documentImage.contentMode = .scaleAspectFill
            } else if let url = image.imageURL {
                documentImage.image = nil // remove the user documents image
                imageTask = documentImage.downloadImage(from: url, placeholder: UIImage(systemName: "photo.on.rectangle"), activityColor: GroupListViewController.configuration.palette.primary)
                documentImage.contentMode = .scaleAspectFill
            } else {
                documentImage.image = UIImage(systemName: "photo.on.rectangle")
                documentImage.contentMode = .center
            }
            documentImage.backgroundColor = GroupListViewController.configuration.palette.secondary
        }
    }

    override func prepareForReuse() {
        imageTask?.cancel()
        imageTask = nil
    }
    
    func configure(_ group: Group) {
        textField.set(text: group.documentName, for: .callout, textColor: GroupListViewController.configuration.palette.mainTexts)
        image = group.image
    }
}

extension GroupDocumentCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textDelegate?.textChanged(textField.text, for: .documentName)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textDelegate?.willBecomeActive(.documentName)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textDelegate?.willBecomeActive(.documentName)
        return true
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        textDelegate?.willResignActive()
        return super.endEditing(force)
    }
}

struct GroupImage: Codable, Hashable {
    static func == (lhs: GroupImage, rhs: GroupImage) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var image: UIImage?  {
        didSet {
            guard let image = image,
                let url = try? ImageManager.save(image) else {
                return
            }
            imageURL = url
        }
    }

    var imageURL: URL?
    var position: Int
    
    init(index: Int) {
        position = index
    }
    
    init?(_ image: UIImage, at index: Int) {
        self.image = image
        position = index
    }
    
    enum CodingKeys: String, CodingKey {
        case imageURL
        case position
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        if let str = try container.decodeIfPresent(String.self, forKey: .imageURL) {
            imageURL = URL(string: str)
        }
        try position = container.decode(Int.self, forKey: .position)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encodeIfPresent(imageURL?.absoluteString, forKey: .imageURL)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
}
