//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import KStorage
import UIKit

class ImageManager {
    private init() {}
    static let shared: ImageManager = ImageManager()
    private var storage = DataStorage()
    
    static func save(_ image: UIImage, imagePath: String? = nil) throws -> URL {
        if let path = imagePath {
            return try save(image, path: path)
        } else {
            return try save(image, path: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path)
        }
    }
    
    private static func save(_ image: UIImage, path: String) throws -> URL {
        try ImageManager.shared.storage.save(image, path: path)
    }
    
    static func fetchImage(with name: String) -> UIImage? {
        guard let url = URL(string: DataStorage.storageDirectoryPath + "/" + name) else { return nil }
        return try? ImageManager.shared.storage.fetchImage(at: url)
    }
}
