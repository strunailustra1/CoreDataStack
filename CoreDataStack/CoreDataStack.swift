//
//  CoreDataStack.swift
//  CoreDataStack
//
//  Created by Наталья Мирная on 23.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var didUpdateDataBase: ((CoreDataStack) -> Void)?
    
    private var storeURL: URL = {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask).last
            else {
                fatalError("documentPath not found")
        }
        return documentsUrl.appendingPathComponent("Chat.sqlite")
    }()
    
    private let dataNameModel = "Chat"
    private let dataModelExtension = "momd"
    
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.dataNameModel,
                                             withExtension: self.dataModelExtension)
            else {
                fatalError("model not found")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("managedObjectModel couldn't be created")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
            do {
                //todo советуют отдельную очередь 36:15
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                   configurationName: nil,
                                                   at: self.storeURL,
                                                   options: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        return coordinator
    }()
    
    private lazy var writterContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writterContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
    
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func performSave(_ block: (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                do { try performSave(in: context) }
                catch { assertionFailure(error.localizedDescription) }
            }
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        if let parent = context.parent { try performSave(in: parent)}
    }
    
    func enableObservers() {
        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(managedObjectContextObjectsDidChange(notification:)),
                                 name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                 object: mainContext)
    }
    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        didUpdateDataBase?(self)
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            inserts.count > 0 {
            print("Добавлено объектов: \(inserts.count)")
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updates.count > 0 {
            print("Обновлено объектов: \(updates.count)")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletes.count > 0 {
            print("Удалено объектов: \(deletes.count)")
        }
    }
    
    func printDataBaseStatistice() {
        mainContext.perform {
            do {
                let count = try self.mainContext.count(for: Channel_db.fetchRequest())
                print("\(count) чатов")
                let array = try self.mainContext.fetch(Channel_db.fetchRequest()) as? [Channel_db] ?? []
                array.forEach {
                    print($0.about)
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
