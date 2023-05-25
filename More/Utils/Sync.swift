//
//  Sync.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Foundation

func synced(_ lock: AnyObject, closure: ()->()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
