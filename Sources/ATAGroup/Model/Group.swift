//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import ColorExtension
import ATAConfiguration
import DateExtension
import Alamofire
import CodableExtension
import ImageExtension

public enum MemberStatus: Int, CaseIterable, Codable {
    case pending = 0, validated, deleted, suspended, incomplete
    public static var random: MemberStatus { MemberStatus.init(rawValue: Int.random(in: 0...2)) ?? .pending }
    
    public var title: String {
        switch self {
        case .pending: return "pending".bundleLocale()
        case .validated: return "validated".bundleLocale()
        case .deleted: return "deleted".bundleLocale()
        case .suspended: return "suspended".bundleLocale()
        case .incomplete: return "incomplete".bundleLocale()
        }
    }
    
    public var color: UIColor? {
        switch self {
        case .pending: return GroupListViewController.configuration.palette.action
        case .validated: return GroupListViewController.configuration.palette.confirmation
        case .deleted: return  GroupListViewController.configuration.palette.primary
        case .suspended: return  GroupListViewController.configuration.palette.backgroundDark
        case .incomplete: return  GroupListViewController.configuration.palette.inactive
        }
    }
}

public struct GroupMember: Codable {
    public var id: String
    public var email: String
    public var name: String?
    public var vehicle: String?
    public var location: String?
    public var city: String?
    public var status: MemberStatus
    var isAdmin: Bool?
    var isOwner: Bool { isAdmin ?? false }
    
    public init(email: String,
                name: String? = nil,
                vehicle: String? = nil,
                location: String? = nil,
                city: String? = nil,
                status: MemberStatus = .pending) {
        self.id = UUID().uuidString
        self.email = email
        self.name = name
        self.vehicle = vehicle
        self.location = location
        self.city = city
        self.status = status
    }
    
    var displayName: String? { (!isOwner) ? name : "\(name ?? "-") - (\("owner".bundleLocale().capitalizingFirstLetter()))" }
}

extension GroupMember: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
}

extension GroupMember: Comparable {
    public static func < (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.name ?? "" < rhs.name ?? ""
    }
    
    public static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.email == rhs.email
    }
}

public enum GroupStatus: Int, CaseIterable, Codable {
    case pending = 0, validated, deleted, suspended, incomplete, closed
    public static var random: GroupStatus { GroupStatus.init(rawValue: Int.random(in: 0...5)) ?? .pending }
}

public struct GroupType: Codable {
    public var id: Int
    var hexColor: String
    public var name: String
    public var sortIndex: Int
    var mandatoryDocument: Bool
    public var isAlertGroup: Bool
    public var color: UIColor {
        UIColor.init(hexString: hexColor, defaultReturn: UIColor.random())
    }
    
    public init(id: Int,
                hexColor: String,
                name: String,
                sortIndex: Int,
                mandatoryDocument: Bool,
                isAlertGroup: Bool = false) {
        self.id = id
        self.hexColor = hexColor
        self.name = name
        self.sortIndex = sortIndex
        self.mandatoryDocument = mandatoryDocument
        self.isAlertGroup = isAlertGroup
    }
    
    public static var GroupType1: GroupType { GroupType(id: 1, hexColor: "#307BF6", name: "groupement juridique", sortIndex: 0, mandatoryDocument: true) }
    public static var GroupType2: GroupType { GroupType(id: 2, hexColor: "#EFB749", name: "Collègues", sortIndex: 1, mandatoryDocument: false) }
    public static var GroupType3: GroupType { GroupType(id: 3, hexColor: "#DA5264", name: "Alerte", sortIndex: 3, mandatoryDocument: false, isAlertGroup: true) }
}

public struct Group: Codable {
    public var id: String
    public var type: GroupType
    public var name: String
    public var status: GroupStatus = .pending
//    public var documentName: String?
    public var creationDate: CustomDate<ISOMillisecondsDateFormatterDecodable> = CustomDate<ISOMillisecondsDateFormatterDecodable>.init(date: Date())
    public var updateDate: CustomDate<ISOMillisecondsDateFormatterDecodable>?
    @DecodableDefault.EmptyList public var members: [GroupMember]
    public var pendingMembers: [GroupMember] {members.filter({ $0.status == .pending })  }
    public var activeMembers: [GroupMember] {members.filter({ $0.status == .validated })  }
    public var image: CodableImage?
    public var isAlertGroup: Bool { type.isAlertGroup }
    public var channelId: String
    public var docId: Int?
    
    init(type: GroupType,
         name: String,
         documentUrl: URL?,
         documentName: String?,
         creationDate: Date,
         members: [GroupMember],
         channelId: String = "") {
        self.id = UUID().uuidString
        self.type = type
        self.name = name
        self.status = GroupStatus.random
        self.creationDate = CustomDate<ISOMillisecondsDateFormatterDecodable>.init(date: creationDate)
        self.image = CodableImage()
        self.image?.imageURL = documentUrl
        self.channelId = ""
        self.channelId = channelId
        self.members = members
    }
    
    public mutating func add(_ image: UIImage) {
        self.image = CodableImage(image)
    }
    
    public mutating func add(_ image: CodableImage) {
        self.image = image
    }
    
    public var isValid: Bool {
        name.isEmpty == false
            && (type.mandatoryDocument == false || image != nil)
    }
    
    public var multipartData: MultipartFormData? {
        let data = MultipartFormData()
        try? data.encode(id, for: "id")
        try? data.encode(type.id, for: "typeId")
        try? data.encode(name, for: "name")
        try? data.encode(status, for: "status")
        try? data.encode(creationDate, for: "creationDate")
        if members.count > 0 {
            try? data.encode(members, for: "members")
        }
        if let image = image?.image,
           let imageData = image.scalePreservingAspectRatio(targetSize: CGSize(width: 800, height: 800)).jpegData(compressionQuality: 0.7),
           let imageName = self.image?.imageName {
            data.append(imageData, withName: imageName, fileName: imageName, mimeType: "image/jpg")
        }
        return data
    }
}

extension Group: Hashable {
    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
        hasher.combine(type.name)
        hasher.combine(type.hexColor)
        hasher.combine(name)
        hasher.combine(docId)
       // hasher.combine(members)
     //   hasher.combine(image)
    }
}

extension Group: Comparable {
    public static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.type.sortIndex < rhs.type.sortIndex || (lhs.type.sortIndex == rhs.type.sortIndex && lhs.name < rhs.name)
    }
    
    public static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
//        lhs.type.sortIndex == rhs.type.sortIndex
//            && lhs.type.name == rhs.type.name
//            && lhs.name == rhs.name
//            && lhs.image == rhs.image
    }
}

public class UpdateGroupDoc: Codable {
    
    var groupId: String = ""
    var doc_id: Int? = nil
    var image: CodableImage? = nil
    
    public init() {}
    
    public init(groupId: String, doc_id: Int?, image: CodableImage? = nil) {
        self.groupId = groupId
        self.doc_id = doc_id
        self.image = image
    }
    
    public var multipartData: MultipartFormData? {
        let data = MultipartFormData()
        try? data.encode(groupId, for: "group_id")
        try? data.encode(doc_id, for: "doc_id")
        
        if let image = image?.image,
           let imageData = image.scalePreservingAspectRatio(targetSize: CGSize(width: 800, height: 800)).jpegData(compressionQuality: 0.7),
           let imageName = self.image?.imageName {
            data.append(imageData, withName: imageName, fileName: imageName, mimeType: "image/jpg")
        }
        return data
    }
}

