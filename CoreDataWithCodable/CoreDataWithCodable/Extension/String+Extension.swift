//
//  String+Extension.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
extension String {
    
    static func emptyIfNull(optionnalValue: String?) -> String {
        if let isValue = optionnalValue {
            return isValue
        }
        else {
            return "N/A"
        }
    }
}
