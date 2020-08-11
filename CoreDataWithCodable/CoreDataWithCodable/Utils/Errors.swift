//
//  Error+Extension.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation

enum CutomError: Error {
    case invalidURL
    case emptyValue
    case decoding
    case other(Error)

    
    static func map(error: Error) -> CutomError {
        return (error as? CutomError) ??  other(error)
    }
}

enum CoreDataFetchError: Error {
    case limitReached
    case anyFetchError
}
