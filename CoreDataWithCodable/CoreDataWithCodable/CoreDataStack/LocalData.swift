//
//  LocalData.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
import CoreData


typealias LocalDataFetchCompletion = (Result<[UserModel]?, CoreDataFetchError>) -> Void
//LOCAL Data Base handling
protocol LoadData {
    func load(fetchLimit: Int, fetchOffset: Int, completion: @escaping LocalDataFetchCompletion)
}

class LoadLocalData: LoadData {
    func load(fetchLimit: Int = 10, fetchOffset: Int, completion : @escaping LocalDataFetchCompletion) {
        self.loadLocalData(fetchLimit: fetchLimit, fetchOffset: fetchOffset, completionHandler: completion)
    }
    
    //MARK:- Fecth from local data with
    fileprivate func loadLocalData(fetchLimit: Int, fetchOffset: Int, completionHandler: @escaping LocalDataFetchCompletion)  {
        //1.
        let context = CoreDataStack.managedObjectContext
        //2.
        let fetchRequestObject = UserModel.userFetchRequest()
        fetchRequestObject.fetchLimit = fetchLimit
        fetchRequestObject.fetchOffset = fetchOffset
        let entityDesc =  NSEntityDescription.entity(forEntityName: UserModel.entityNameString , in: context)
        fetchRequestObject.entity = entityDesc
        //3.
        do {
            let fetchedUsers = try context.fetch(fetchRequestObject)
            if !fetchedUsers.isEmpty{
                completionHandler(.success(fetchedUsers))
            }
            else {
                completionHandler(.failure(CoreDataFetchError.limitReached))
            }
        }
        catch {
            completionHandler(.failure(CoreDataFetchError.anyFetchError))
        }
    }
}
