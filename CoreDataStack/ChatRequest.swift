//
//  ChatRequest.swift
//  CoreDataStack
//
//  Created by Наталья Мирная on 24.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import CoreData

struct ChatRequest {
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func makeRequest() {
        coreDataStack.performSave { context in
            let message1 = Message_db(content: "Qwe qwe qwe",
                                      created: Date(),
                                      senderId: "qweqwe",
                                      senderName: "qwe",
                                      in: context)
            let message2 = Message_db(content: "Foo foo foo",
                                      created: Date(timeIntervalSince1970: 0),
                                      senderId: "foofoo",
                                      senderName: "foo",
                                      in: context)
            let message3 = Message_db(content: "Bar bar bar",
                                      created: Date(),
                                      senderId: "barbar",
                                      senderName: "bar",
                                      in: context)
            let channel1 = Channel_db(identifier: "ch1",
                                      name: "channel1 2 messages",
                                      lastMessage: "hello",
                                      lastActivity: Date(),
                                      in: context)
            [message1, message2].forEach { channel1.addToMessages($0) }
            let channel2 = Channel_db(identifier: "ch2",
                                      name: "channel2 1 messages",
                                      lastMessage: "hello",
                                      lastActivity: Date(),
                                      in: context)
            channel2.addToMessages(message3)
            let channel3 = Channel_db(identifier: "ch3",
                                      name: "channel3 0 messages",
                                      lastMessage: "",
                                      lastActivity: Date(),
                                      in: context)
        }
    }
}
