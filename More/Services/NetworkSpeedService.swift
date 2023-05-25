//
//  NetworkSpeedService.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

private let urlForSpeedTest = URL(string: "https://www.google.com")

class NetworkSpeedProvider: NSObject, URLSessionDataDelegate, URLSessionDelegate, BufferedRunInterface {
    
    // buffered calls
    typealias BufferedData = Bool
    var buffer: Bool?
    var bufferDelay: TimeInterval {
        return 3
    }
    var bufferTimer: Timer?
    
    
    struct Notifications {
        static let Connection = NSNotification.Name(rawValue: "com.more.network.connection")
        static let Speed = NSNotification.Name(rawValue: "com.more.network.speed")
    }
    
    static let shared = NetworkSpeedProvider()
    
    private var startTime = CFAbsoluteTime()
    private var stopTime = CFAbsoluteTime()
    private var bytesReceived: CGFloat = 0
    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil

    /// MB per second
    var networkSpeed: CGFloat {
        if speedBuffer.count > 0 {
            return speedBuffer.reduce(0, { (result, next) -> CGFloat in
                return result + next
            }) / CGFloat(speedBuffer.count)
        }
        return 0
    }
    
    private var isConnected: Bool = true
    private var speedBuffer: [CGFloat] = []
    
    override init() {
        super.init()
        
        // connection
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { [weak self] snapshot in
            if snapshot.value as? Bool ?? false {
                self?.isConnected = true
            } else {
                self?.isConnected = false
                self?.bufferCall(with: false, run: { [weak self] (conectionState) in
                    if self?.isConnected == false {
                        NotificationCenter.default.post(name: Notifications.Connection, object: self)
                    }
                })
            }
        })
        
        // speed
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            self?.testDownloadSpeed(withTimout: 2, completionHandler: { (speed, error) in
                if error == nil {
                    NotificationCenter.default.post(
                        name: Notifications.Speed,
                        object: self,
                        userInfo: ["speed": speed])
                }
            })
        }
    }
    
    func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionHandler = completionHandler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        guard let checkedUrl = urlForSpeedTest else { return }
        
        session.dataTask(with: checkedUrl).resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived += CGFloat(data.count)
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = stopTime - startTime
        let speed: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 / 1024.0 : -1.0
        if speed > 0 {
            speedBuffer.append(speed)
            if speedBuffer.count > 10 {
                speedBuffer.remove(at: 0)
            }
        }
        if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
            speedTestCompletionHandler?(networkSpeed, nil)
        } else {
            speedTestCompletionHandler?(networkSpeed, error)
        }
    }
}
