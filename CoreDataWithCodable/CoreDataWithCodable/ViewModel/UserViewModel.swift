//
//  UserViewModel.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
struct UserViewModel: Hashable {
    let id = UUID()
    let name: String
    let avatar: String
    let role: Role
    
    init(user: UserModel) {
        self.name = String.emptyIfNull(optionnalValue: user.username)
        self.avatar = String.emptyIfNull(optionnalValue: user.avatarURL)
        let role = String.emptyIfNull(optionnalValue: user.role)
        self.role = Role(rawValue: role) ?? Role.notAvailable
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

enum Role: String {
    case Admin = "Admin"
    case User = "User"
    case Owner = "Owner"
    case notAvailable = "N/A"
}
