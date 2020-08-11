//
//  UserController.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
import Combine


//Fetch data
protocol UserControllerProtocol {
    var items: [UserViewModel] {get}
    var itemsCount: Int {get}
    func items(at index: Int) -> UserViewModel?
    func fetchItems(at index: Int)
}

extension UserControllerProtocol {
    var items: [UserViewModel] {
        return items
    }
    
    var itemsCount: Int {
        return items.isEmpty ? 0 : items.count
    }
    
    func items(at index: Int) -> UserViewModel? {
        if index < self.itemsCount {
            return self.items[index]
        }
        return nil
    }
}

class UserController: UserControllerProtocol {
    var currentPage: Int = -1
    var lastPage: Int = -1
    var items: [UserViewModel] = []
    let networkRequest = NetworkRequest()
    let passthroughSubecjtForFetchReload = PassthroughSubject<Bool, Never>()
    var cancellable: AnyCancellable?
    //local data management
    let localDataFetcher = LoadLocalData()
    var pageOffsetForLocalDataPaging: Int = 0
    var isSavedDataFetchLimitReached: Bool = false
    
    //MARK:- Init
    init() {
        self.loadNextItemIfApplicable(at: 0)
    }
    
    var itemsCount: Int {
        return items.isEmpty ? 0 : items.count
    }
    
    func items(at index: Int) -> UserViewModel? {
        if index < self.itemsCount {
            return self.items[index]
        }
        return nil
    }
    
    func fetchItems(at index: Int) {
        self.loadNextItemIfApplicable(at: index)
    }
    
    //MARK:- set managed object Context
    fileprivate func createTopLevelDecoder() -> JSONDecoder {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to retrieve managed object context")
        }
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[codingUserInfoKeyManagedObjectContext] = CoreDataStack.managedObjectContext
        return jsonDecoder
    }
    
    //MARK:- Save Context after fetching from server
    fileprivate func saveFetchedUserFromServerInDatabase() {
        do {
            try CoreDataStack.managedObjectContext.save()
        }
        catch {
            print("**************************************************** \(error) ****************************************************")
        }
    }
}

extension UserController {
    
    func loadNextItemIfApplicable(at index: Int) {
        //1.
        let targetIndex = currentPage < 0 ? 0 : ((currentPage + 1) * (URLRouter.pageSize)) - 1
        //2.
        guard index == targetIndex else {
            return
        }
        print("EQUAL INDEX")

        currentPage += 1
        self.pageOffsetForLocalDataPaging = ((currentPage + 1) * (URLRouter.pageSize))
        if !isSavedDataFetchLimitReached {
            self.tryForLocalDataFecthIfAvailable(index)
        }
        else {
            self.loadFromServereAt(index)
        }
    }
    
    //MARK:- Fetch from server
    fileprivate func loadFromServereAt(_ index: Int) {
        self.cancellable = networkRequest.fetchRequest(from: URLRouter.urlString(for: index), model: [UserModel].self, topLevelDecoder: self.createTopLevelDecoder())
            .sink(receiveCompletion: {print($0)}) { [weak self](user) in
                if !user.isEmpty {
                    //1. Save
                    self?.saveFetchedUserFromServerInDatabase()
                    //2. append item
                    self?.items += user.map{UserViewModel(user: $0)}
                    //3. send signal to reciever
                    self?.passthroughSubecjtForFetchReload.send(true)
                }
            }
    }
    
    //MARK:- Check for local data base if entry is available
    fileprivate func tryForLocalDataFecthIfAvailable(_ index: Int) {
        localDataFetcher.load(fetchLimit: URLRouter.pageSize + 1 , fetchOffset: self.pageOffsetForLocalDataPaging) { [weak self](result) in
            switch result {
            case .success(let usersModel):
                //1. itterate over values
                usersModel?.forEach({ (user) in
                    self?.items.append(UserViewModel(user: user))
                })
                //2. send signal to reciever
                DispatchQueue.main.async {
                    self?.passthroughSubecjtForFetchReload.send(true)
                }
            case .failure(_):
                //1. fetch limit reached
                self?.isSavedDataFetchLimitReached = true
                //2. Go to server and call service
                self?.loadFromServereAt(index)
            }
        }
    }
}
