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
import ImageExtension
import ATAViews

protocol PhotoDelegate: NSObjectProtocol {
    func choosePicture()
}

class GroupDocumentCell: UICollectionViewCell {
    weak var textDelegate: GroupTextCellDelegate?
    @IBOutlet weak var disclaimer: UILabel!  {
        didSet {
            disclaimer.set(text: "legal document".bundleLocale().uppercased(), for: .footnote, textColor: GroupListViewController.configuration.palette.inactive)
        }
    }

    weak var photoDelegate: PhotoDelegate?
    @IBOutlet weak var documentImage: UIImageView!
    
    @IBAction func choosePicture() {
        photoDelegate?.choosePicture()
    }
    var imageTask: ImageTask?
    var image: CodableImage?  {
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
        image = group.image
    }
}

public struct GroupImage: Codable, Hashable {
    public static func == (lhs: GroupImage, rhs: GroupImage) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var image: UIImage?  {
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
    
    public init?(_ image: UIImage, at index: Int) {
        self.image = image
        position = index
    }
    
    public enum CodingKeys: String, CodingKey {
        case imageURL
        case position
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //mandatory
        if let str = try container.decodeIfPresent(String.self, forKey: .imageURL) {
            imageURL = URL(string: str)
        }
        try position = container.decode(Int.self, forKey: .position)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encodeIfPresent(imageURL?.absoluteString, forKey: .imageURL)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
}
