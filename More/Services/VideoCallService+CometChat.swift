//
//  VideoCallService.swift
//  More
//
//  Created by Luko Gjenero on 06/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

// import Quickblox
// import QuickbloxWebRTC

import CometChatPro

class VideoCallService: NSObject, CometChatCallDelegate, CometChatGroupDelegate {
    struct Notifications {
        static let StartCall = NSNotification.Name(rawValue: "com.more.video.start")
        static let JoinCall = NSNotification.Name(rawValue: "com.more.video.join")
        static let LeaveCall = NSNotification.Name(rawValue: "com.more.video.leave")
        static let RejectCall = NSNotification.Name(rawValue: "com.more.video.reject")
        static let AcceptCall = NSNotification.Name(rawValue: "com.more.video.accept")
    }
    
    static let shared = VideoCallService()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        toForeground()
        
        // QBRTCClient.instance().add(self)
        // QBRTCConferenceClient.instance().add(self)
    }
    
    // MARK: - state management
    
    @objc private func toForeground() {
        // nop
    }
    
    @objc private func toBackground() {
        // nop
        endCall(complete: nil)
    }
    
    // MARK: - API
    
    private var chat: Chat?
    private var groupId: String?
    private var call: Call?
    
    private var completeJoin: ((_ success: Bool, _ errorMsg: String?)->())?
    private var joinView: UIView?
    
    private var incomingCalls: [Call] = []
    
    // private var chatDialogID: String?
    // private var session: QBRTCSession?
    
    func startCall(chat: Chat, in view: UIView, complete: ((_ id: String?, _ errorMsg: String?)->())?) {

        //  get or create public call group
        
        let guid = chat.videoCall?.id ?? chat.id;
        let groupName = chat.id;
        let group = Group(guid: guid, name: groupName, groupType: .public, password: nil)

        CometChat.getGroup(GUID: guid, onSuccess: { [weak self] (group) in
            if group.hasJoined {
                self?.internalStartCall(group, chat, view, complete)
            } else {
                CometChat.joinGroup(GUID: guid, groupType: .public, password: nil, onSuccess: { (group) in
                    self?.internalStartCall(group, chat, view, complete)
                }, onError: { (error) in
                    complete?(nil, error?.errorDescription)
                })
            }
        }, onError: { [weak self] (error) in
            CometChat.createGroup(group: group, onSuccess: { (group) in
                self?.internalStartCall(group, chat, view, complete)
            }, onError: { (error) in
                complete?(nil, error?.errorDescription)
            })
        })
    }
    
    private func internalStartCall(_ group: Group, _ chat: Chat, _ view: UIView, _ complete: ((_ id: String?, _ errorMsg: String?)->())?) {
        
        self.groupId = group.guid
        self.chat = chat
        
        let call = Call(receiverId: group.guid, callType: .video, receiverType: .group)
        CometChat.initiateCall(call: call, onSuccess: { [weak self] (call) in
            if let call = call, let sessionId = call.sessionID {
                self?.call = call
                ChatService.shared.addVideoCall(to: chat, id: group.guid, sessionId: sessionId) { [weak self] (success, errorMsg) in
                    if success {
                        self?.internalStartActualCall(group.guid, sessionId, view) { (success, errorMsg) in
                            if success {
                                complete?(group.guid, nil)
                            } else {
                                complete?(nil, "Unable to join call")
                            }
                        }
                    } else {
                        self?.dataCleanup()
                        complete?(nil, errorMsg)
                    }
                }
            } else {
                complete?(nil, "Error initializing the call")
            }
        }, onError: { (error) in
            complete?(nil, error?.errorDescription)
        })
    }
    
    func joinCall(chat: Chat, in view: UIView, complete: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let videoCall = chat.videoCall else {
            complete?(false, "Missing video call")
            return
        }
        
        self.groupId = videoCall.id
        self.chat = chat
        
        CometChat.getGroup(GUID: videoCall.id, onSuccess: { [weak self] (group) in
            if group.hasJoined {
                self?.internalJoinCall(videoCall.sessionId, view, complete)
            } else {
                CometChat.joinGroup(GUID: videoCall.id, groupType: .public, password: nil, onSuccess: { (group) in
                    self?.internalJoinCall(videoCall.sessionId, view, complete)
                }, onError: { (error) in
                    CometChat.leaveGroup(GUID: videoCall.id, onSuccess: { _ in }, onError: { _ in })
                    self?.dataCleanup()
                    complete?(false, error?.errorDescription)
                })
            }
        }, onError: { [weak self] (error) in
            self?.dataCleanup()
            complete?(false, error?.errorDescription)
        })

//        CometChat.joinGroup(GUID: videoCall.id, groupType: .public, password: nil, onSuccess: { [weak self] (group) in
//            self?.internalJoinCall(videoCall.sessionId, view, complete)
//        }, onError: { (error) in
//            ERR_ALREADY_JOINED
//
//            CometChat.leaveGroup(GUID: videoCall.id, onSuccess: { _ in }, onError: { _ in })
//            complete?(false, error?.errorDescription)
//        })
    }
    
    private func internalJoinCall(_ sessionId: String, _ view: UIView, _ complete: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let chat = chat, let guid = chat.videoCall?.id else { return }
        CometChat.acceptCall(sessionID: sessionId, onSuccess: { [weak self] (call) in
            guard let call = call else {
                complete?(false, "Error joining the call")
                return
            }

            self?.call = call
            complete?(true, nil)

            self?.internalStartActualCall(guid, sessionId, view, nil)

        }, onError: { [weak self] (error) in
            self?.cleanup(sessionId, guid, chat)
            print("Accepting call failed with error: \(error?.errorDescription)")
            complete?(false, "Error joining the call")
        })
    }
    
    private func internalStartActualCall(_ guid: String, _ sessionId: String, _ view: UIView, _ complete: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let chat = chat else { return }
        
        startVideoCallTimer(chat)
        
        CometChat.startCall(sessionID: sessionId, inView: view, userJoined: { [weak self] (user) in
            
            guard let me = ProfileService.shared.profile else { return }
            if user?.uid == me.id {
                print("Joined ME")
            } else {
                print("Joined User: \(user?.stringValue())")
            }
            
        }, userLeft: { [weak self, weak view] (user) in

            guard let me = ProfileService.shared.profile else { return }
            if user?.uid == me.id.lowercased() {
                self?.cleanup(sessionId, guid, chat, view)
                print("Left ME")
            } else {
                print("Left User: \(user?.stringValue())")
            }
            
        }, onError: { [weak self] (error) in
            
            self?.cleanup(sessionId, guid, chat, view)
            print("Connection error with error: \(error?.errorDescription)");
            
        }, callEnded: { [weak self] (call) in
            self?.cleanup(sessionId, guid, chat)
            print("Call ended successfully. \(call?.stringValue())");
        });
    }
    
    private func dataCleanup() {
        self.chat = nil
        self.groupId = nil
        self.call = nil
    }
    
    private func cleanup(_ sessionId: String, _ guid: String, _ chat: Chat, _ view: UIView? = nil) {
//        CometChat.leaveGroup(GUID: guid, onSuccess: { _ in
//            CometChat.endCall(sessionID: sessionId, onSuccess: { _ in }, onError: { e in print("Error: \(e?.errorDescription)") })
//        }, onError: { e in print("Error: \(e?.errorDescription)") })
//        ChatService.shared.removeMeFromVideoCall(to: chat, complete: nil)
        
        CometChat.endCall(sessionID: sessionId, onSuccess: { _ in }, onError: { _ in })
        CometChat.leaveGroup(GUID: guid, onSuccess: { _ in }, onError: { _ in })
        ChatService.shared.removeMeFromVideoCall(chat: chat, complete: nil)
        
        dataCleanup()
        stopVideoCallTimer()
        
        guard view != nil else { return }
        
        DispatchQueue.main.async {
            if let view = view {
                var toRemove: [UIView] = []
                for view in view.subviews {
                    if String(describing: type(of: view)).starts(with: "Jitsi") {
                        toRemove.append(view)
                    }
                }
                toRemove.forEach { $0.removeFromSuperview() }
            }
        }
    }
    
    func endCall(complete: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let chat = chat, let guid = chat.videoCall?.id else { return }
        guard let call = call, let sessionID = call.sessionID else { return }
        
        CometChat.endCall(sessionID: sessionID, onSuccess: { [weak self] (call) in
            self?.cleanup(sessionID, guid, chat)
            complete?(true, nil)
        }, onError: { (error) in
            complete?(false, error?.errorDescription)
        })
    }
    
    
    
    var audioEnabled: Bool {
        get {
            return false
            // return call?. session?.localMediaStream.audioTrack.isEnabled ?? false
        }
        set {
            // session?.localMediaStream.audioTrack.isEnabled = newValue
        }
    }
    
    var videoEnabled: Bool {
        get {
            return false
            // return session?.localMediaStream.videoTrack.isEnabled ?? false
        }
        set {
            // session?.localMediaStream.videoTrack.isEnabled = newValue
        }
    }
    
    // MARK: - chat keep alive
    
    private var videoCallTimer: Timer?
    
    private func startVideoCallTimer(_ chat: Chat) {
        videoCallTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (timer) in
            ChatService.shared.videoCallTick(for: chat)
        }
    }
    
    private func stopVideoCallTimer() {
        videoCallTimer?.invalidate()
        videoCallTimer = nil
    }
    
    // MARK: - CometChatCallDelegate
    
    func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
//        if let incomingCall = incomingCall {
//            incomingCalls.append(incomingCall)
//
//            if incomingCall.receiverType == .group,
//                incomingCall.receiverUid == chat?.videoCall?.id,
//                let view = joinView {
//                call = incomingCall
//                internalJoinCall(incomingCall, view, completeJoin)
//
//                joinView = nil
//                completeJoin = nil
//            }
//        }
    }

    func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
        
    }

    func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
        
    }

    func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
        if let canceledCall = canceledCall {
            
        }
    }
    
    // MARK: - CometChatGroupDelegate

    func onGroupMemberJoined(action: CometChatPro.ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
        
    }

    func onGroupMemberLeft(action: CometChatPro.ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
        
    }

    func onGroupMemberKicked(action: CometChatPro.ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
        
    }

    func onGroupMemberBanned(action: CometChatPro.ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
        
    }

    func onGroupMemberUnbanned(action: CometChatPro.ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        
    }

    func onGroupMemberScopeChanged(action: CometChatPro.ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        
    }

    func onMemberAddedToGroup(action: CometChatPro.ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        
    }
    
}
