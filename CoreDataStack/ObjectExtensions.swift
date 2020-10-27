//
//  ObjectExtensions.swift
//  CoreDataStack
//
//  Created by Наталья Мирная on 25.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

@objc(Channel_db)
public class Channel_db: NSManagedObject {
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var messages: NSSet?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel_db> {
        NSFetchRequest<Channel_db>(entityName: "Channel_db")
    }
}

extension Channel_db {
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message_db)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message_db)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

extension Channel_db {
    convenience init(identifier: String,
                     name: String,
                     lastMessage: String?,
                     lastActivity: Date?,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    var about: String {
        return self.identifier + "\t" + self.name
    }
}

@objc(Message_db)
public class Message_db: NSManagedObject {
    @NSManaged public var content: String
    @NSManaged public var created: Date
    @NSManaged public var senderId: String
    @NSManaged public var senderName: String
    @NSManaged public var channel: Channel_db?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message_db> {
        NSFetchRequest<Message_db>(entityName: "Message_db")
    }
}

extension Message_db {
    convenience init(content: String,
                     created: Date,
                     senderId: String,
                     senderName: String,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
    
    var about: String {
        return self.content
    }
}
