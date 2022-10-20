//
//  CoreDataService.swift
//  Virtual Tourist
//
//  Created by minhdat on 20/10/2022.
//

import Foundation
import CoreData

class CoreDataService {
    class func sharedInstance() -> CoreDataService {
        struct Singleton {
            static var sharedInstance = CoreDataService(modelName: "CryptoData")
        }
        return Singleton.sharedInstance
    }
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var fetchedData:NSFetchedResultsController<CoinData>?
    
    var backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completeion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completeion?()
        }
    }
    
    func fetchedData(_ id: Any) {
        let fetchRequest:NSFetchRequest<CoinData> = CoinData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "uuid", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedData = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewContext, sectionNameKeyPath: nil, cacheName: "uuid")
        fetchedData?.delegate = id as? NSFetchedResultsControllerDelegate
        
        try? fetchedData?.performFetch()
    }
    
    func fetchedCoin(uuid: String, symbol: String) -> [CoinData] {
        let predicate = NSPredicate(format: "uuid == %@ AND symbol == %@", uuid, symbol)
        let fetchRequest:NSFetchRequest<CoinData> = CoinData.fetchRequest()
        fetchRequest.predicate = predicate
        if let coins = try? self.viewContext.fetch(fetchRequest) {
            return coins
        }
        return []
    }
}

extension CoreDataService {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        guard interval > 0 else {
            print("cannot set negative autsave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
