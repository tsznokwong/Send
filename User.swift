//
//  User.swift
//  Send
//
//  Created by Tsznok Wong on 9/7/2016.
//  Copyright © 2016 Tsznok Wong. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(userData: User) {
        uid = userData.uid
        email = userData.email
    }
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
