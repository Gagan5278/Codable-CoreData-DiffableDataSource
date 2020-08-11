//
//  UserModel+CoreData.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
import CoreData
extension UserModel {
    @nonobjc public class func userFetchRequest() -> NSFetchRequest<UserModel> {
        return NSFetchRequest<UserModel>(entityName: "UserModel")
    }

    static var entityNameString: String {
        return "UserModel"
    }
}

