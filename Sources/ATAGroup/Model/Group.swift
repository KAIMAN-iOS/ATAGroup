//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import ColorExtension

enum MemberStatus: Int, CaseIterable, Codable {
    case pending = 0, validated, deleted
}

struct GroupMember: Codable {
    var email: String
    var name: String?
    var vehicle: String?
    var location: String?
    var status: MemberStatus
}

extension GroupMember: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
}

extension GroupMember: Comparable {
    static func < (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.name < rhs.name
    }
    
    static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.email == rhs.email
    }
}

enum GroupStatus: Int, CaseIterable, Codable {
    case pending = 0, validated, deleted
}

struct GroupType: Codable {
    var hexColor: String
    var name: String
    var sortIndex: Int
    var mandatoryDocument: Bool
    var color: UIColor {
        UIColor.init(hexString: hexColor, defaultReturn: UIColor.random())
    }
}

struct Group: Codable {
    var type: GroupType
    var name: String
    var status: GroupStatus = .pending
    var documentUrl: URL?
    var documentName: String?
    var creationDate: Date = Date()
    var members: [GroupMember] = []
    var pendingMembers: [GroupMember] {members.filter({ $0.status == .pending })  }
    var activeMembers: [GroupMember] {members.filter({ $0.status == .validated })  }
}

extension Group: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.name)
        hasher.combine(type.hexColor)
        hasher.combine(name)
        hasher.combine(members)
    }
}

extension Group: Comparable {
    static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.type.sortIndex < rhs.type.sortIndex
            || lhs.type.name < rhs.type.name
            || lhs.name < rhs.name
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.type.sortIndex == rhs.type.sortIndex
            && lhs.type.name == rhs.type.name
            && lhs.name == rhs.name
    }
}
