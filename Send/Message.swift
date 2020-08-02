//
//  Message.swift
//  Send
//
//  Created by Tsznok Wong on 9/7/2016.
//  Copyright © 2016 Tsznok Wong. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    let key: String!
    let content: String!
    let sentByUser: String!
    let timeStamp: Double
    let itemRef: DatabaseReference?
    
    init(content: String, sentByUser: String, key: String = "") {
        self.content = content
        self.sentByUser = sentByUser
        self.key = key
        self.itemRef = nil
        self.timeStamp = Date().timeIntervalSince1970
        //NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .MediumStyle)
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        /*
         let snapshotValue = snapshot.value as? NSDictionary
         let name = snapshotValue["displayName"] as? String
         */
        let snapshotValue = snapshot.value as? NSDictionary
        if let messageContent = snapshotValue?["content"] as? String {
            content = messageContent
        } else {
            content = ""
        }
        
        if let messageUser = snapshotValue?["sentByUser"] as? String {
            sentByUser = messageUser
        } else {
            sentByUser = ""
        }
        
        if let messageTimeStamp = snapshotValue?["timeStamp"] as? Double {
            timeStamp = messageTimeStamp
        } else {
            timeStamp = 0
        }
    }
    
    func toAnyObject() -> AnyObject {
        let inputsOutputs = ["content": content, "sentByUser": sentByUser, "timeStamp": timeStamp] as [String : Any]
        return inputsOutputs as AnyObject
    }
}
