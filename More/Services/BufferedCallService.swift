//
//  BufferedCallService.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

protocol BufferedRunInterface: class {
    
    associatedtype BufferedData
    
    var buffer: BufferedData? { get set }
    var bufferDelay: TimeInterval { get }
    var bufferTimer: Timer? { get set }
    
    func bufferCall(with data: BufferedData, run: @escaping (_ buffer: BufferedData)->())
}

extension BufferedRunInterface {
    
    func bufferCall(with data: BufferedData, run: @escaping (_ buffer: BufferedData)->()) {
        bufferTimer?.invalidate()
        buffer = data
        bufferTimer = Timer.scheduledTimer(withTimeInterval: bufferDelay, repeats: false) { [weak self] (_) in
            if let sself = self, let buffer = sself.buffer {
                sself.bufferTimer = nil
                sself.buffer = nil
                run(buffer)
            }
        }
    }
}
