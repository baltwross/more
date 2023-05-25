//
//  TestUtils.swift
//  MoreTests
//
//  Created by Luko Gjenero on 09/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func sleep(for time: TimeInterval) {
        let sleep = XCTestExpectation(description: "sleep")
        _ = XCTWaiter.wait(for: [sleep], timeout: time)
    }
}
