//
//  AudioCallProvider.swift
//  More
//
//  Created by Luko Gjenero on 08/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//


import CallKit
import Quickblox
import QuickbloxWebRTC

class AudioCallProvider: NSObject {
    
    static let shared = AudioCallProvider()
    
    private let callController: CXCallController
    private let provider: CXProvider
    
    private weak var session: QBRTCSession?
    
    private var callStarted: Bool = false
    private var actionCompletionBlock: (()->())?
    private var onAcceptActionBlock: (()->())?
    var onMicrophoneMuteAction: (()->())?
    
    override init() {
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        callController = CXCallController(queue: DispatchQueue.main)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "More"
        let providerConfiguration = CXProviderConfiguration(localizedName: appName)
        
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        
        providerConfiguration.supportedHandleTypes = [.generic]
        
        return providerConfiguration
    }
    
    func startCall(with userId: String, name: String, session: QBRTCSession, uuid: UUID) {
        self.session = session
        let handle = self.handle(for: userId, name: name)
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.contactIdentifier = name
        
        let transaction = CXTransaction(action: action)
        requestTransaction(transaction) { [weak self] (_) in
            
            let update = CXCallUpdate()
            update.remoteHandle = handle
            update.localizedCallerName = name
            update.supportsHolding = false
            update.supportsGrouping = false
            update.supportsUngrouping = false
            update.supportsDTMF = false
            update.hasVideo = false
            
            self?.provider.reportCall(with: uuid, updated: update)
        }
        
    }
    
    func endCall(with uuid: UUID, completion: (()->())?) {
        guard session != nil else { return }
        
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        
        dispatchOnMainThread { [weak self] in
            self?.requestTransaction(transaction, completion: nil)
        }
        
        actionCompletionBlock = completion
    }
    
    func reportIncomingCall(with userId: String, name: String, session: QBRTCSession, uuid: UUID, onAccept: (()->())?, completion: ((_ success: Bool)->())?) {
        guard self.session == nil else { return }
        
        self.session = session
        onAcceptActionBlock = onAccept
        
        let update = CXCallUpdate()
        update.remoteHandle = handle(for: userId, name: name)
        update.localizedCallerName = name
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = false
        
        let audioSession = QBRTCAudioSession.instance()
        audioSession.useManualAudio = true
        session.recorder?.isLocalAudioEnabled = false
        
        if !audioSession.isInitialized {
            audioSession.initialize { (configuration) in
                configuration.categoryOptions.insert(.allowBluetooth)
                configuration.categoryOptions.insert(.allowBluetoothA2DP)
            }
        }
        
        provider.reportNewIncomingCall(with: uuid, update: update) { (error) in
            let silent = (error as NSError?)?.domain == CXErrorDomainIncomingCall && (error as NSError?)?.code == CXErrorCodeIncomingCallError.filteredByDoNotDisturb.rawValue
            
            dispatchOnMainThread {
                completion?(silent)
            }
        }
    }
    
    func updateCall(with uuid: UUID, connectingAt date: Date) {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: date)
    }
    
    func updateCall(with uuid: UUID, connectedAt date: Date) {
        provider.reportOutgoingCall(with: uuid, connectedAt: date)
    }
}

// MARK: - CXProviderDelegate

extension AudioCallProvider: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard session != nil else {
            action.fail()
            return
        }
        
        dispatchOnMainThread { [weak self] in
            self?.session?.startCall(nil)
            self?.callStarted = true
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard session != nil else {
            action.fail()
            return
        }
        
        dispatchOnMainThread { [weak self] in
            self?.session?.acceptCall(nil)
            self?.callStarted = true
            action.fulfill()
            
            self?.onAcceptActionBlock?()
            self?.onAcceptActionBlock = nil
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let cachedSession = session else {
            action.fail()
            return
        }
        
        session = nil
        
        dispatchOnMainThread { [weak self] in
            let audioSession = QBRTCAudioSession.instance()
            audioSession.isAudioEnabled = false
            audioSession.useManualAudio = false
            
            if self?.callStarted == true {
                cachedSession.hangUp(nil)
                self?.callStarted = false
            } else {
                cachedSession.rejectCall(nil)
            }
            
            action.fulfill(withDateEnded: Date())
            
            self?.actionCompletionBlock?()
            self?.actionCompletionBlock = nil
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard session != nil else {
            action.fail()
            return
        }
        
        dispatchOnMainThread { [weak self] in
            self?.session?.localMediaStream.audioTrack.isEnabled = !action.isMuted
            action.fulfill()
            
            self?.onMicrophoneMuteAction?()
        }
    }
    
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        let rtcAudioSession = QBRTCAudioSession.instance()
        rtcAudioSession.audioSessionDidActivate(audioSession)
        rtcAudioSession.isAudioEnabled = true
        session?.recorder?.isLocalAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        let rtcAudioSession = QBRTCAudioSession.instance()
        rtcAudioSession.audioSessionDidDeactivate(audioSession)
        if rtcAudioSession.isInitialized {
            rtcAudioSession.deinitialize()
        }
    }
}

// MARK: - Permissions

extension AudioCallProvider {
    
    func requestMicrophonePermissions(_ completion: ((_ granted: Bool)->())?) {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            dispatchOnMainThread {
                completion?(granted)
            }
        }
    }
}


// MARK: - Helpers

extension AudioCallProvider {
    
    func handle(for userId: String, name: String) -> CXHandle {
        return CXHandle(type: .generic, value: userId)
    }
    
    func requestTransaction(_ transaction: CXTransaction, completion: ((_ success: Bool)->())?) {
        callController.request(transaction) { (error) in
            completion?(error == nil)
        }
    }
    
}
