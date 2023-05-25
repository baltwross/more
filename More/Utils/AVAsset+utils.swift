//
//  AVAsset+utils.swift
//  More
//
//  Created by Luko Gjenero on 01/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import AVKit

extension AVPlayerItem {

    enum VideoOriantation: CGFloat {
        case right = 0
        case up = 90
        case left = 180
        case down = -90
        
        func radians() -> CGFloat  {
            return self.rawValue.toRadians()
        }
        
        func orientation() -> UIImage.Orientation {
            switch self {
            case .up:
                return .up
            case .left:
                return .left
            case .down:
                return .down
            default:
                return.right
            }
        }
    }
    
    func snapshot() -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        guard let cgImage = try? imageGenerator.copyCGImage(at: currentTime(), actualTime: nil) else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: videoOriantation().orientation())
    }
    
    func videoOriantation() -> VideoOriantation {
        guard let track = asset.tracks(withMediaType: .video).first else { return .right }
        let angle = atan2(track.preferredTransform.b, track.preferredTransform.a).toDegrees()
        switch angle {
        case 90:
            return .right
        case 180:
            return .down
        case -90:
            return .left
        default:
            return .up
        }
    }
    
    
    
}
