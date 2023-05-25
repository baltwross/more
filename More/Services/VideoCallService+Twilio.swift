//
//  VideoCallService+Twilio.swift
//  More
//
//  Created by Luko Gjenero on 17/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import TwilioVideo

class VideoCallService: NSObject, RoomDelegate, RemoteParticipantDelegate, CameraSourceDelegate {
    
    struct Notifications {
        static let StartCall = NSNotification.Name(rawValue: "com.more.video.start")
        static let JoinCall = NSNotification.Name(rawValue: "com.more.video.join")
        static let LeaveCall = NSNotification.Name(rawValue: "com.more.video.leave")
        static let RejectCall = NSNotification.Name(rawValue: "com.more.video.reject")
        static let AcceptCall = NSNotification.Name(rawValue: "com.more.video.accept")
        
        static let VideoSettingsChanged = NSNotification.Name(rawValue: "com.more.video.videosettings")
        static let AudioSettingsChanged = NSNotification.Name(rawValue: "com.more.video.audiosettings")
        static let CameraChanged = NSNotification.Name(rawValue: "com.more.video.camera")
        static let MembersChanged = NSNotification.Name(rawValue: "com.more.video.members")
        static let CallEnded = NSNotification.Name(rawValue: "com.more.video.end")
    }
    
    static let shared = VideoCallService()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        toForeground()
    }
    
    // MARK: - state management
    
    @objc private func toForeground() {
        // nop
    }
    
    @objc private func toBackground() {
        // nop
        endCall(complete: nil)
    }
    
    // MARK: - call data
    
//    private var completeJoin: ((_ success: Bool, _ errorMsg: String?)->())?
//    private var joinView: UIView?
    
    private var chat: Chat?
    private var room: Room?
    private var participants: [RemoteParticipant] = []
    
    private var completeJoin: ((_ success: Bool, _ errorMsg: String?)->())?
    
    private var localAudioTrack: LocalAudioTrack?
    private var localDataTrack: LocalDataTrack?
    private var localVideoTrack: LocalVideoTrack?
    private var cameraSource: CameraSource?
    
    // MARK: - API
    
    func joinCall(chat: Chat, in view: UIView, complete: ((_ success: Bool, _ errorMsg: String?)->())?) {

        guard let accessToken = TwilioService.shared.token else {
            complete?(false, "Twilio token not available")
            return
        }
        
        //  get or create public call group
        
        let guid = chat.videoCall?.id ?? chat.id
        
        localAudioTrack = LocalAudioTrack()
        localDataTrack = LocalDataTrack()
        createVideoSource()
        
        let connectOptions = ConnectOptions(token: accessToken) { [weak self] (builder) in
            builder.region = "us1"
            builder.roomName = guid
            builder.isNetworkQualityEnabled = true

            if let audioTrack = self?.localAudioTrack {
                builder.audioTracks = [ audioTrack ]
            }
            if let dataTrack = self?.localDataTrack {
                builder.dataTracks = [ dataTrack ]
            }
            if let videoTrack = self?.localVideoTrack {
                builder.videoTracks = [ videoTrack ]
            }
        }
        
        self.chat = chat
        completeJoin = complete
        self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }

    private func dataCleanup() {
        self.chat = nil
        self.room = nil
        self.participants.removeAll()
        
        self.localAudioTrack = nil
        self.localDataTrack = nil
        self.localVideoTrack = nil
    }
    
    private func cleanup(_ chat: Chat, _ view: UIView? = nil) {

        room?.disconnect()
        ChatService.shared.removeMeFromVideoCall(chat: chat, complete: nil)
                
        dataCleanup()
        stopVideoCallTimer()
        
        UIApplication.shared.isIdleTimerDisabled = false
        
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
        guard let chat = chat else { return }
        
        cleanup(chat)
    }
    
    func prep(enable: Bool) {
        if enable {
            
            // unpublish media
            if let audioTrack = localAudioTrack {
                room?.localParticipant?.unpublishAudioTrack(audioTrack)
            }
            if let videoTrack = localVideoTrack {
                room?.localParticipant?.unpublishVideoTrack(videoTrack)
            }
            
            // setup
            prepAudioEnabled = audioEnabled
            prepVideoEnabled = videoEnabled
            prepEnabled = true
        } else {
            prepEnabled = false
            
            // publish media
            if prepAudioEnabled {
               if let audioTrack = localAudioTrack {
                    room?.localParticipant?.publishAudioTrack(audioTrack)
                }
            } else {
                localAudioTrack = nil
            }
            if prepVideoEnabled {
                if let videoTrack = localVideoTrack {
                    room?.localParticipant?.publishVideoTrack(videoTrack)
                }
            } else {
                localVideoTrack = nil
            }
        }
    }
    
    private var prepEnabled: Bool = false
    private var prepVideoEnabled: Bool = true
    private var prepAudioEnabled: Bool = true
    
    var audioEnabled: Bool {
        get {
            if prepEnabled {
                return prepAudioEnabled
            }
            return audioTrack != nil
        }
        set {
            if prepEnabled {
                prepAudioEnabled = newValue
                NotificationCenter.default.post(name: Notifications.AudioSettingsChanged, object: self)
                return
            }
            
            if newValue {
                localAudioTrack = LocalAudioTrack()
                if let audioTrack = localAudioTrack {
                    room?.localParticipant?.publishAudioTrack(audioTrack)
                }
            } else {
                if let audioTrack = localAudioTrack {
                    room?.localParticipant?.unpublishAudioTrack(audioTrack)
                }
                localAudioTrack = nil
            }
            NotificationCenter.default.post(name: Notifications.AudioSettingsChanged, object: self)
        }
    }
    
    var videoEnabled: Bool {
        get {
            if prepEnabled {
                return prepVideoEnabled
            }
            return videoTrack != nil
        }
        set {
            if prepEnabled {
                prepVideoEnabled = newValue
                NotificationCenter.default.post(name: Notifications.VideoSettingsChanged, object: self)
                return
            }
            
            if newValue {
                createVideoSource()
                if let videoTrack = localVideoTrack {
                    room?.localParticipant?.publishVideoTrack(videoTrack)
                }
                NotificationCenter.default.post(name: Notifications.VideoSettingsChanged, object: self)
            } else {
                if let videoTrack = localVideoTrack {
                    room?.localParticipant?.unpublishVideoTrack(videoTrack)
                }
                destroyVideoSource { [weak self] in
                    NotificationCenter.default.post(name: Notifications.VideoSettingsChanged, object: self)
                }
            }
        }
    }
    
    var audioTrack: LocalAudioTrack? {
        get {
            return localAudioTrack
            // return room?.localParticipant?.localAudioTracks.first?.localTrack
        }
    }
    
    var videoTrack: LocalVideoTrack? {
        get {
            return localVideoTrack
            // return room?.localParticipant?.localVideoTracks.first?.localTrack
        }
    }
    
    func getParticipants() -> [RemoteParticipant] {
        return participants
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
    
    // MARK: - RoomDelegate
    
    func roomDidConnect(room: Room) {
        guard let chat = chat else {
            room.disconnect()
            return
        }
        
        self.room = room
        startVideoCallTimer(chat)
        
        ChatService.shared.addVideoCall(to: chat, id: room.name, sessionId: "") { [weak self] (success, erroMsg) in
            self?.completeJoin?(success, erroMsg)
            self?.completeJoin = nil
            if !success {
                self?.endCall(complete: nil)
            }
        }
        
        for participant in room.remoteParticipants {
            participant.delegate = self
            participants.append(participant)
        }
        
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self)
        
        if let audioTrack = localAudioTrack {
            room.localParticipant?.publishAudioTrack(audioTrack)
        }
        if let videoTrack = localVideoTrack {
            room.localParticipant?.publishVideoTrack(videoTrack)
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        completeJoin?(false, error.localizedDescription)
        completeJoin = nil
        dataCleanup()
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        endCall(complete: nil)
        NotificationCenter.default.post(name: Notifications.CallEnded, object: self)
    }
    
    func roomDidReconnect(room: Room) {
        
    }
    
    func roomIsReconnecting(room: Room, error: Error) {
        
    }
    
    func roomDidStartRecording(room: Room) {
        
    }
    
    func roomDidStopRecording(room: Room) {
        
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self, userInfo: ["userId": participant.identity])
        participant.delegate = self
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        participants.removeAll(where: { $0.identity == participant.identity })
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self, userInfo: ["userId": participant.identity])
    }
    
    func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
        
    }
    
    // MARK: - RemoteParticipantDelegate
    
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        /*
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self)
        */
    }
    
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self, userInfo: ["userId": participant.identity])
    }
    
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        /*
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self)
        */
    }
    
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self, userInfo: ["userId": participant.identity])
    }
    
    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        /*
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self)
        */
    }
    
    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        print("Twilio Audio Error \(error)")
    }
    
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        participants.removeAll(where: { $0.identity == participant.identity })
        participants.append(participant)
        NotificationCenter.default.post(name: Notifications.MembersChanged, object: self)
    }
    
    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        print("Twilio Video Error \(error)")
    }
    
    // MARK: - CameraSourceDelegate

    func cameraSourceInterruptionEnded(source: CameraSource) {
        print("cameraSourceInterruptionEnded: \(cameraSource.debugDescription)")
        if let videoTrack = localVideoTrack {
            room?.localParticipant?.publishVideoTrack(videoTrack)
        }
    }
    
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        print("cameraSourceDidFail: \(error.localizedDescription)")
    }
    
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        print("cameraSourceWasInterrupted: \(reason) --- \(cameraSource.debugDescription)")
        if let videoTrack = localVideoTrack {
            room?.localParticipant?.unpublishVideoTrack(videoTrack)
        }
    }
    
    // MARK: - camea management
    
    private func createVideoSource() {
        if let camera = CameraSource(delegate: self) {
            localVideoTrack = LocalVideoTrack(source: camera, enabled: true, name: "camera")
            startCameraSource(camera)
            cameraSource = camera
        }
    }
    
    private func destroyVideoSource(_ complete: (()->())?) {
        cameraSource?.stopCapture() { [weak self] _ in
            self?.localVideoTrack = nil
            self?.cameraSource = nil
            complete?()
        }
    }
    
    private func startCameraSource(_ cameraSource: CameraSource) {
        guard let captureDevice = CameraSource.captureDevice(position: .front) else { return }

        let targetSize: CMVideoDimensions
        let cropRatio: CGFloat
        let frameRate: UInt
        
        targetSize = CMVideoDimensions(width: 1024, height: 768)
        cropRatio = CGFloat(targetSize.width) / CGFloat(targetSize.height)
        frameRate = 24

        let preferredFormat = selectVideoFormatBySize(captureDevice: captureDevice, targetSize: targetSize)
        preferredFormat.frameRate = min(preferredFormat.frameRate, frameRate)
        
        let cropDimensions: CMVideoDimensions
        
        if preferredFormat.dimensions.width > preferredFormat.dimensions.height {
            cropDimensions = CMVideoDimensions(
                width: Int32(CGFloat(preferredFormat.dimensions.height) * cropRatio),
                height: preferredFormat.dimensions.height
            )
        } else {
            cropDimensions = CMVideoDimensions(
                width: preferredFormat.dimensions.width,
                height: Int32(CGFloat(preferredFormat.dimensions.width) * cropRatio)
            )
        }
        
        let outputFormat = VideoFormat()
        outputFormat.dimensions = cropDimensions
        outputFormat.pixelFormat = preferredFormat.pixelFormat
        outputFormat.frameRate = 0
        
        cameraSource.requestOutputFormat(outputFormat)
        
        cameraSource.startCapture(device: captureDevice, format: preferredFormat) { [weak self] _, _, error in
            guard error == nil else { return }
            
            // TODO
        }
    }
    
    private func selectVideoFormatBySize(captureDevice: AVCaptureDevice, targetSize: CMVideoDimensions) -> VideoFormat {
        let supportedFormats = Array(CameraSource.supportedFormats(captureDevice: captureDevice)) as! [VideoFormat]
        
        // Cropping might be used if there is not an exact match
        for format in supportedFormats {
            guard
                format.pixelFormat == .formatYUV420BiPlanarFullRange &&
                    format.dimensions.width >= targetSize.width &&
                    format.dimensions.height >= targetSize.height
                else {
                    continue
            }
            
            return format
        }
        
        fatalError()
    }
    
    func flipCamera() {
        guard
            let cameraSource = cameraSource,
            let position = cameraSource.device?.position,
            let captureDevice = CameraSource.captureDevice(position: position == .front ? .back : .front)
            else {
                return
        }
        
        cameraSource.selectCaptureDevice(captureDevice) { [weak self] _, _, error in
            guard error == nil else { return }
            NotificationCenter.default.post(name: Notifications.CameraChanged, object: self)
        }
    }
    
}
