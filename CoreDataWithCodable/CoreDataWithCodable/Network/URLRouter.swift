//
//  URLRouter.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
enum URLRouter {
    static let pageSize = 25
    
    static func urlString(for userID: Int) -> String {
        return  Constatnts.URLConstatnts.baseURLString + "users?id=\(userID)&count=\(URLRouter.pageSize)"
    }
}



