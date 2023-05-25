//
//  ApiTests.swift
//  More
//
//  Created by Luko Gjenero on 09/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import XCTest
import CoreLocation
import Firebase
@testable import More

private let phoneNumber = "+1(212) 555-5555"
private let code = "123456"

class ApiTests: XCTestCase {
    
    
    
    override class func setUp() {
        Services.initialize()
        
        /*
        // logout
        let logout = XCTestExpectation(description: "logout")
        ProfileService.shared.logout { (success, _) in
            if success {
                logout.fulfill()
            }
        }
        _ = XCTWaiter.wait(for: [logout], timeout: 2.0)
        */
        
        guard ProfileService.shared.profile == nil else { return }
        
        // login
        let login = XCTestExpectation(description: "login")
        ProfileService.shared.verifyPhoneNumber(phoneNumber: phoneNumber, formattedPhoneNumber: phoneNumber) { (success, _) in
            if success {
                ProfileService.shared.signIn(verificationCode: code, complete: { (success, _) in
                    if success {
                        login.fulfill()
                    }
                })
            }
        }
        let loginResult = XCTWaiter.wait(for: [login], timeout: 10.0)
        if loginResult != .completed {
            XCTFail("Unable to login")
        }
        
        SignalingService.shared.startTrackingAroundMe()
        
    }
    
    override class func tearDown() {
        
    }
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    private var signalId: String = ""
    
    private var requestId: String = ""
    
    func testCreateSignal() {
        
        guard let me = ProfileService.shared.profile else {
            XCTFail("Not logged in")
            return
        }
        
        // Create
        
        let location = GeoPoint(latitude: 0, longitude: 0)
        LocationService.shared.testLocation(location.coordinates())
        
        let signal = Signal(id: "Test", text: "Test", imageUrls: [""], type: .adventurous, createdAt: Date(), expiresAt: Date(timeIntervalSinceNow: 1800), location: GeoPoint, destination: nil, destinationName: nil, destinationAddress: nil, creator: me.user)
        
        // need to receive by GPS
        let signalEntered = XCTestExpectation(description: "signalEntered")
        observe(name: SignalingService.Notifications.SignalEnteredRegion) { [unowned self] (notice) in
            if let signal = notice.userInfo?["signal"] as? Signal, signal.id == self.signalId {
                signalEntered.fulfill()
            }
        }
        
        // need to load
        let signalLoaded = XCTestExpectation(description: "signalLoaded")
        observe(name: SignalTrackingService.Notifications.SignalLoaded) { [unowned self] (notice) in
            if let signal = notice.userInfo?["signal"] as? Signal, signal.id == self.signalId {
                signalLoaded.fulfill()
            }
        }
        
        let signalCreated = XCTestExpectation(description: "signalCreated")
        SignalingService.shared.createSignal(from: signal) { [unowned self] (signalId, _) in
            if let signalId = signalId {
                self.signalId = signalId
                signalCreated.fulfill()
            }
        }
        
        wait(for: [signalCreated, signalEntered, signalLoaded], timeout: 20)
        
        if SignalTrackingService.shared.updatedSignalData(for: signalId) == nil {
            XCTFail("Signal cache for tracking does not exist!")
        }
        
        let userActiveSignal = XCTestExpectation(description: "userActiveSignal")
        Firestore.firestore().collection("users").child(me.id).child("signals").child("active").child(signalId).observeSingleEvent(
            of: .value,
            with: { [unowned self] (snapshot) in
                if snapshot.exists(), snapshot.key == self.signalId,
                    let shortSignal = ShortSignal.fromSnapshot(snapshot),
                    shortSignal.id == self.signalId {
                    userActiveSignal.fulfill()
                }
            }, withCancel: nil)
    
        wait(for: [userActiveSignal], timeout: 5)

        // Delete
        
        // need to receive by GPS
        let signalExited = XCTestExpectation(description: "signalExited")
        observe(name: SignalingService.Notifications.SignalExitedRegion) { [unowned self] (notice) in
            if let signalId = notice.userInfo?["signalId"] as? String, signalId == self.signalId {
                signalExited.fulfill()
            }
        }
        
        // need to expire
        let signalExpired = XCTestExpectation(description: "signalExpired")
        observe(name: SignalTrackingService.Notifications.SignalExpired) { [unowned self] (notice) in
            if let signalId = notice.userInfo?["signalId"] as? String, signalId == self.signalId {
                signalExpired.fulfill()
            }
        }
        
        let signalDeleted = XCTestExpectation(description: "signalDeleted")
        SignalingService.shared.deleteSignal(signalId: signalId) { (success, _) in
            if success {
                signalDeleted.fulfill()
            }
        }
        
        wait(for: [signalDeleted, signalExited, signalExpired], timeout: 10)
        
        if SignalTrackingService.shared.updatedSignalData(for: signalId) != nil {
            XCTFail("Signal cache for tracking does exist!")
        }
        
        let userActiveSignalRemoved = XCTestExpectation(description: "userActiveSignalRemoved")
        Firestore.firestore().collection("users").child(me.id).child("signals").child("active").child(signalId).observeSingleEvent(
            of: .value,
            with: { (snapshot) in
                if !snapshot.exists() {
                    userActiveSignalRemoved.fulfill()
                }
            }, withCancel: nil)
        
        wait(for: [userActiveSignalRemoved], timeout: 5)
        
    }
    
    func testCreateRequest() {
        
        guard let me = ProfileService.shared.profile else {
            XCTFail("Not logged in")
            return
        }
        
        let location = GeoPoint(latitude: 0, longitude: 0)
        LocationService.shared.testLocation(location.coordinates())
        
        let other = User(id: "--xxx--",
                         name: "Test",
                         avatar:"",
                         location: GeoPoint)
        
        // Create
        
        let signal = Signal(id: "Test", text: "Test", imageUrls: [""], type: .adventurous, createdAt: Date(), expiresAt: Date(timeIntervalSinceNow: 1800), location: GeoPoint, destination: nil, destinationName: nil, destinationAddress: nil, creator: other)
        
        // need to receive by GPS
        let signalEntered = XCTestExpectation(description: "signalEntered")
        observe(name: SignalingService.Notifications.SignalEnteredRegion) { [unowned self] (notice) in
            if let signal = notice.userInfo?["signal"] as? Signal, signal.id == self.signalId {
                signalEntered.fulfill()
            }
        }
        
        let signalCreated = XCTestExpectation(description: "signalCreated")
        SignalingService.shared.createSignal(from: signal) { [unowned self] (signalId, _) in
            if let signalId = signalId {
                self.signalId = signalId
                signalCreated.fulfill()
            }
        }
        
        wait(for: [signalCreated, signalEntered], timeout: 20)
        
        // removing this check for now, the Explre view is loading it
        /*
        if SignalTrackingService.shared.updatedSignalData(for: signalId) != nil {
            XCTFail("Signal cache for tracking does exist!")
        }
        */
        
        let userActiveRequestEmpty = XCTestExpectation(description: "userActiveRequestEmpty")
        Firestore.firestore().collection("users").child(me.id).child("signals").child("requests").child(signalId).observeSingleEvent(
            of: .value,
            with: { (snapshot) in
                if !snapshot.exists() {
                    userActiveRequestEmpty.fulfill()
                }
            }, withCancel: nil)
        
        wait(for: [userActiveRequestEmpty], timeout: 5)
        
        // need to load
        let signalLoaded = XCTestExpectation(description: "signalLoaded")
        observe(name: SignalTrackingService.Notifications.SignalLoaded) { [unowned self] (notice) in
            if let signal = notice.userInfo?["signal"] as? Signal, signal.id == self.signalId {
                signalLoaded.fulfill()
            }
        }
        
        let requestCreated = XCTestExpectation(description: "signalCreated")
        SignalingService.shared.requestTime(for: signalId, message: nil) { (requestId, _) in
            if let requestId = requestId {
                self.requestId = requestId
                requestCreated.fulfill()
            }
        }
        
        wait(for: [requestCreated, signalLoaded], timeout: 20)
        
        if SignalTrackingService.shared.updatedSignalData(for: signalId) == nil {
            XCTFail("Signal cache for tracking does not exist!")
        }
        
        sleep(for: 2)
                
        let userActiveRequest = XCTestExpectation(description: "userActiveRequest")
        Firestore.firestore().collection("users").child(me.id).child("signals").child("requests").child(signalId).observeSingleEvent(
            of: .value,
            with: { [unowned self] (snapshot) in
                if snapshot.exists(), snapshot.key == self.signalId,
                    let shortSignal = ShortSignal.fromSnapshot(snapshot),
                    shortSignal.id == self.signalId {
                    userActiveRequest.fulfill()
                }
            },
            withCancel: { (error) in
                print(error.localizedDescription)
            })
        
        wait(for: [userActiveRequest], timeout: 5)
        
        // Delete
        
        // need to expire
        let requestExpired = XCTestExpectation(description: "requestExpired")
        observe(name: SignalTrackingService.Notifications.SignalResponse) { [unowned self] (notice) in
            if let signal = notice.userInfo?["signal"] as? Signal, signal.id == self.signalId,
               let request = notice.userInfo?["request"] as? Request, request.id == self.requestId {
                requestExpired.fulfill()
            }
        }
        
        let requestDeleted = XCTestExpectation(description: "requestDeleted")
        SignalingService.shared.cancelRequest(requestId, in: signalId) { (success, _) in
            if success {
                requestDeleted.fulfill()
            }
        }
        
        wait(for: [requestDeleted, requestExpired], timeout: 10)
        
        
        
        if SignalTrackingService.shared.updatedSignalData(for: signalId) != nil {
            XCTFail("Signal cache for tracking does exist!")
        }
        
        let userActiveRequestRemoved = XCTestExpectation(description: "userActiveRequestRemoved")
        
        let signalDeleted = XCTestExpectation(description: "signalDeleted")
        SignalingService.shared.deleteSignal(signalId: signalId) { (success, _) in
            if success {
                signalDeleted.fulfill()
                
                self.sleep(for: 2)
                Firestore.firestore().collection("users").child(me.id).child("signals").child("requests").child(self.signalId).observeSingleEvent(
                    of: .value,
                    with: { (snapshot) in
                        if !snapshot.exists() {
                            userActiveRequestRemoved.fulfill()
                        }
                }, withCancel: nil)
            }
        }
        
        wait(for: [signalDeleted, userActiveRequestRemoved], timeout: 15)
        
    }
    
    func testDeleteSignal() {
        
        guard ProfileService.shared.profile != nil else {
            XCTFail("Not logged in")
            return
        }
        
        let location = GeoPoint(latitude: 0, longitude: 0)
        LocationService.shared.testLocation(location.coordinates())
        
        let userIds = ["--aa--", "--bb--", "--cc--", "--dd--"]
        let users = userIds.map { User(id: $0, name: "Test", avatar:"", location: GeoPoint) }
        
        var signalIds = ["A", "B", "C", "D", "E", "F", "G", "H"]
        let signals = signalIds.map {
            Signal(id: $0, text: "Test", imageUrls: [""], type: .adventurous, createdAt: Date(), expiresAt: Date(timeIntervalSinceNow: 1800), location: GeoPoint, destination: nil, destinationName: nil, destinationAddress: nil, creator: users[(signalIds.firstIndex(of: $0)! % users.count)])
        }
        
        // create users
        var createUsers: [XCTestExpectation] = []
        for user in users {
            let userCreated = XCTestExpectation(description: "userCreated_" + user.id)
            createUsers.append(userCreated)
            Firestore.firestore().collection("users").child(user.id).setValue(user.json, withCompletionBlock: { (error, _) in
                if error == nil {
                    userCreated.fulfill()
                }
            })
        }
        wait(for: createUsers, timeout: 20)
        
        // create signals
        var createSignals: [XCTestExpectation] = []
        for (idx, signal) in signals.enumerated() {
            let signalCreated = XCTestExpectation(description: "signalCreated_" + signal.id)
            createSignals.append(signalCreated)
            SignalingService.shared.createSignal(from: signal) { (signalId, _) in
                if let signalId = signalId {
                    signalIds[idx] = signalId
                    signalCreated.fulfill()
                }
            }
        }
        wait(for: createSignals, timeout: 20)
        
        var testSignalId: String? = nil
        var testRequestId: String? = nil
        var testCreatorId: String? = nil
        var testRequesterId: String? = nil
        
        // requests
        var requests: [XCTestExpectation] = []
        for user in users {
            for (idx, signal) in signals.enumerated() {
                if signal.creator.id != user.id {
                    
                    let requestCreated = XCTestExpectation(description: "requestCreated_" + signalIds[idx] + "_" + user.id)
                    requests.append(requestCreated)
                    
                    let now = Date()
                    let expiration = Date(timeIntervalSinceNow: 300)
                    let request = Request(
                        id: "---",
                        createdAt: now,
                        expiresAt: expiration,
                        sender: user,
                        accepted: nil)
                    
                    let requestValue = request.json
                    
                    Firestore.firestore().collection("signals").child("active").child(signalIds[idx]).child("requestList").childByAutoId().setValue(requestValue) { (error, reference) in
                        
                        guard error == nil else { return }
                        
                        requestCreated.fulfill()
                        
                        if testSignalId == nil,
                            let firstRequestId = reference.key {
                            testSignalId = signalIds[idx]
                            testRequestId = firstRequestId
                            testCreatorId = signal.creator.id
                            testRequesterId = user.id
                        }
                    }
                }
            }
        }
        wait(for: requests, timeout: 60)
        
        sleep(for: 5)
        
        // accept one
        
        if let testSignalId = testSignalId,
            let testRequestId = testRequestId,
            testCreatorId != nil,
            testRequesterId != nil {
            
            let requestAccepted = XCTestExpectation(description: "requestAccepted")
            Firestore.firestore().collection("signals").child("active").child(testSignalId).child("requestList").child(testRequestId).child("accepted").setValue(true) { (error, reference) in
                if error == nil {
                    requestAccepted.fulfill()
                }
            }
            wait(for: [requestAccepted], timeout: 5)
            
        } else {
            XCTFail("Something went wrong")
        }
        
        sleep(for: 2)
        
        // verify status
        
        var status: [XCTestExpectation] = []
        for (idx, signal) in signals.enumerated() {
            
            let signalId = signalIds[idx]
            
            if signal.creator.id == testCreatorId || signal.creator.id == testRequesterId {
                let removedSignal = XCTestExpectation(description: "removedSignal_" + signalId)
                status.append(removedSignal)
                Firestore.firestore().collection("signals").child("active").child(signalId).observeSingleEvent(
                    of: .value,
                    with: { (snapshot) in
                        if !snapshot.exists() {
                            removedSignal.fulfill()
                        }
                    }, withCancel: nil)
            }
            
            else {
                let signalExists = XCTestExpectation(description: "signalExists")
                status.append(signalExists)
                Firestore.firestore().collection("signals").child("active").child(signalId).observeSingleEvent(
                    of: .value,
                    with: { (snapshot) in
                        if snapshot.exists(),
                            let signal = Signal.fromSnapshot(snapshot) {
                            
                            var ok = true
                            if let requests = signal.requests, requests.count == 3 {
                                for request in requests {
                                    if request.sender.id == testCreatorId || request.sender.id == testRequesterId {
                                        if request.accepted != false {
                                            ok = false
                                            XCTFail("Signal \(signal.id) created by \(signal.creator.id) request \(request.id) from user \(request.sender.id) is not closed")
                                        }
                                    } else if request.accepted != nil {
                                        ok = false
                                        XCTFail("Signal \(signal.id) created by \(signal.creator.id) request \(request.id) from user \(request.sender.id) is not open for acceptance")
                                    }
                                }
                            } else {
                                ok = false
                                XCTFail("Signal \(signal.id) created by \(signal.creator.id) has wrong number of requests \(signal.requests?.count ?? -1)")
                            }
                            
                            if ok {
                                signalExists.fulfill()
                            }
                        }
                }, withCancel: nil)
                
                
            }
            
        }
        wait(for: status, timeout: 20)
        
        // check time
        
        if let testSignalId = testSignalId {
            let timeExists = XCTestExpectation(description: "timeExists")
            Firestore.firestore().collection("times").child("active").child(testSignalId).observeSingleEvent(
                of: .value,
                with: { (snapshot) in
                    if snapshot.exists() {
                        timeExists.fulfill()
                    }
            }, withCancel: nil)
            wait(for: [timeExists], timeout: 5)
            
            let timeDelete = XCTestExpectation(description: "timeDelete")
            Firestore.firestore().collection("times").child("active").child(testSignalId).removeValue(completionBlock: { (error, _) in
                if error == nil {
                    timeDelete.fulfill()
                }
            })
            wait(for: [timeDelete], timeout: 5)
        }
        
        // delete users and signals
        
        var delete: [XCTestExpectation] = []
        for id in signalIds {
            let deleteSignal = XCTestExpectation(description: "deleteSignal_" + id)
            delete.append(deleteSignal)
            SignalingService.shared.deleteSignal(signalId: id) { (success, errorMsg) in
                if success {
                    deleteSignal.fulfill()
                }
            }
        }
        wait(for: delete, timeout: 20)
        
        
        delete = []
        for user in users {
            let deleteUser = XCTestExpectation(description: "deleteUser_" + user.id)
            delete.append(deleteUser)
            Firestore.firestore().collection("users").child(user.id).removeValue { (error, _) in
                if error == nil {
                    deleteUser.fulfill()
                }
            }
        }
        wait(for: delete, timeout: 20)
        
    }
    
    // MARK: - notification observers
    
    typealias ObserverBlock = (_ notice: Notification) -> ()
    
    private var observers: [Notification.Name: ObserverBlock] = [:]
    
    private func observe(name: Notification.Name, block: @escaping ObserverBlock) {
        observers[name] = block
        
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: name, object: nil)
    }
    
    @objc private func notificationReceived(_ notice: Notification) {
        observers[notice.name]?(notice)
    }


}
