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

public enum MemberStatus: Int, CaseIterable, Codable {
    case pending = 0, validated, deleted
    public static var random: MemberStatus { MemberStatus.init(rawValue: Int.random(in: 0...2)) ?? .pending }
    
    public var title: String {
        switch self {
        case .pending: return "pending".bundleLocale()
        case .validated: return "validated".bundleLocale()
        case .deleted: return "deleted".bundleLocale()
        }
    }
    
    public var color: UIColor? {
        switch self {
        case .pending: return GroupListViewController.configuration.palette.action
        case .validated: return GroupListViewController.configuration.palette.confirmation
        case .deleted: return  GroupListViewController.configuration.palette.primary
        }
    }
}

public struct GroupMember: Codable {
    public var id: String
    public var email: String
    public var name: String?
    public var vehicle: String?
    public var location: String?
    public var status: MemberStatus
    
    public init(email: String,
         name: String? = nil,
         vehicle: String? = nil,
         location: String? = nil,
         status: MemberStatus = .pending) {
        self.id = UUID().uuidString
        self.email = email
        self.name = name
        self.vehicle = vehicle
        self.location = location
        self.status = status
    }
    
    public static var member1: GroupMember { GroupMember(email: "test@test.fr", name: nil, vehicle: nil, location: nil, status: .pending) }
    public static var member2: GroupMember { GroupMember(email: "seb@ata.fr", name: nil, vehicle: nil, location: nil, status: .pending) }
    public static var member3: GroupMember { GroupMember(email: "p.berveiller@ata.fr", name: "Philippe Berveiller", vehicle: "Peugeot 205 GTI", location: "10 Marseille", status: .validated) }
    public static var member4: GroupMember { GroupMember(email: "s.andrieu@ata.fr", name: "Sébastien Andrieu", vehicle: "Porshe Caiman", location: "13 Bouc Bel Air", status: .validated) }
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
    case pending = 0, validated, deleted
    public static var random: GroupStatus { GroupStatus.init(rawValue: Int.random(in: 0...2)) ?? .pending }
}

public struct GroupType: Codable {
    var hexColor: String
    public var name: String
    var sortIndex: Int
    var mandatoryDocument: Bool
    public var isAlertGroup: Bool
    public var color: UIColor {
        UIColor.init(hexString: hexColor, defaultReturn: UIColor.random())
    }
    
    init (hexColor: String,
          name: String,
          sortIndex: Int,
          mandatoryDocument: Bool,
          isAlertGroup: Bool = false) {
        self.hexColor = hexColor
        self.name = name
        self.sortIndex = sortIndex
        self.mandatoryDocument = mandatoryDocument
        self.isAlertGroup = isAlertGroup
    }
    
    public static var GroupType1: GroupType { GroupType(hexColor: "#307BF6", name: "groupement juridique", sortIndex: 0, mandatoryDocument: true) }
    public static var GroupType2: GroupType { GroupType(hexColor: "#EFB749", name: "Collègues", sortIndex: 1, mandatoryDocument: false) }
    public static var GroupType3: GroupType { GroupType(hexColor: "#DA5264", name: "Alerte", sortIndex: 3, mandatoryDocument: false, isAlertGroup: true) }
}

public struct Group: Codable {
    public var id: String
    public var type: GroupType
    public var name: String
    public var status: GroupStatus = .pending
    public var documentUrl: URL?
    public var documentName: String?
    public var creationDate: CustomDate<ISODateFormatterDecodable> = CustomDate<ISODateFormatterDecodable>.init(date: Date())
    public var members: [GroupMember] = []
    public var pendingMembers: [GroupMember] {members.filter({ $0.status == .pending })  }
    public var activeMembers: [GroupMember] {members.filter({ $0.status == .validated })  }
    public var image: GroupImage?
    
    init(type: GroupType,
         name: String,
         documentUrl: URL?,
         documentName: String?,
         creationDate: Date,
         members: [GroupMember]) {
        self.id = UUID().uuidString
        self.type = type
        self.name = name
        self.status = GroupStatus.random
        self.documentUrl = documentUrl
        self.documentName = documentName
        self.creationDate = CustomDate<ISODateFormatterDecodable>.init(date: creationDate)
        self.members = members
    }
    
    public static var testGroup1: Group { Group(type: GroupType.GroupType1, name: "TAXI RADIO AIXOIS", documentUrl: URL(string: "https://images.pcastuces.com/adj/5169-10.png"), documentName: "Document légal", creationDate: Date(), members: [GroupMember.member1, GroupMember.member4]) }
    public static var testGroup2: Group { Group(type: GroupType.GroupType2, name: "LES COLlègues", documentUrl: nil, documentName: nil, creationDate: Date(), members: [GroupMember.member2]) }
    public static var testGroup3: Group { Group(type: GroupType.GroupType3, name: "Groupe d'alerte", documentUrl: nil, documentName: nil, creationDate: Date(), members: []) }
    public static var testGroup4: Group { Group(type: GroupType.GroupType2, name: "L'estaque Plage", documentUrl: nil, documentName: nil, creationDate: Date(), members: [GroupMember.member3, GroupMember.member4]) }
    
    public mutating func add(_ image: UIImage) {
        if let img = GroupImage(image, at: 0) {
            self.image = img
        }
    }
    
    public mutating func add(_ image: GroupImage) {
        self.image = image
    }
    
    public var isValid: Bool {
        name.isEmpty == false
            && (type.mandatoryDocument == false ||
                    (documentName?.isEmpty == false && image != nil))
    }
    
    public var multipartData: MultipartFormData? {
        let data = MultipartFormData()
        try? data.encode(id, for: "id")
        try? data.encode(type, for: "type")
        try? data.encode(name, for: "name")
        try? data.encode(status, for: "status")
        if let url = documentUrl {
            try? data.encode(url, for: "documentUrl")
        }
        if let name = documentName {
            try? data.encode(name, for: "documentName")
        }
        try? data.encode(creationDate, for: "creationDate")
        try? data.encode(members, for: "members")
        if let image = image {
            try? data.encode(image, for: "image")
        }
        return data
    }
}

extension Group: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type.name)
        hasher.combine(type.hexColor)
        hasher.combine(name)
        hasher.combine(members)
        hasher.combine(image)
    }
}

extension Group: Comparable {
    public static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.type.sortIndex < rhs.type.sortIndex || (lhs.type.sortIndex == rhs.type.sortIndex && lhs.name < rhs.name)
    }
    
    public static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.type.sortIndex == rhs.type.sortIndex
            && lhs.type.name == rhs.type.name
            && lhs.name == rhs.name
//            && lhs.image == rhs.image
    }
}
