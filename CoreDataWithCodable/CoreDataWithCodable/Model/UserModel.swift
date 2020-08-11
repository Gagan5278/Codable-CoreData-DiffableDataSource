//
//  UserModel.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/10/20.
//

import Foundation
import CoreData

class UserModel: NSManagedObject, Codable {
    @NSManaged var avatarURL: String?
    @NSManaged var username: String?
    @NSManaged var role: String?
    
    enum CodingKeys: String, CodingKey  {
        case avatarURL = "avatar"
        case username
        case role
    }
    
    //MARK:- Encodable
    func encode(to encoder: Encoder) throws {

        var decoder = encoder.container(keyedBy: CodingKeys.self)
        try decoder.encode(self.avatarURL, forKey: .avatarURL)
        try decoder.encode(self.username, forKey: .username)
        try! decoder.encode(self.role, forKey: .role)

    }
    
    //MARK:- Decodable
    required convenience init(from decoder: Decoder) throws {

        guard let configKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext, let managedObjectContext = decoder.userInfo[configKeyManagedObjectContext] as? NSManagedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "UserModel", in: managedObjectContext) else {
            fatalError("unable to find context")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.avatarURL = try container.decode(String.self, forKey: .avatarURL)
        self.username = try container.decode(String.self, forKey: .username)
        self.role = try container.decode(String.self, forKey: .role)
    }
  
}
