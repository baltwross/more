//
//  ChatMeetingCell.swift
//  More
//
//  Created by Luko Gjenero on 13/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import SDWebImage

class ChatMeetingCell: ChatBaseCell {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var card: UIView!
    @IBOutlet private weak var map: UIImageView!
    @IBOutlet private weak var mapPin: UIImageView!
    @IBOutlet private weak var mapBubble: UIView!
    @IBOutlet private weak var mapCallout: UILabel!
    @IBOutlet private weak var loading: UIActivityIndicatorView!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        icon.layer.transform = CATransform3DMakeRotation(CGFloat(90).toRadians(), 0, 0, 1)
        
        mapPin.layer.cornerRadius = 22.5
        // mapPin.layer.masksToBounds = true
        mapPin.enableShadow(color: .black)
        mapBubble.layer.cornerRadius = 11
        mapBubble.enableShadow(color: .black)
        
        card.layer.cornerRadius = 15
        card.layer.masksToBounds = true
        
        enableShadow(color: .black)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(for message: Message, in chat: Chat) {
        
        label.text = "\(message.sender.name) set a meet point."
        name.text = message.additionalMeetingName()
        address.text = message.additionalMeetingAddress()
        mapCallout.text = message.additionalMeetingName()
        
        if let location = message.additionalMeetingLocation() {
            mapImage(location: location)
        } else {
            loading.isHidden = false
            loading.startAnimating()
            mapPin.isHidden = true
            mapBubble.isHidden = true
            map.image = nil
        }
    }
    
    func mapImage(location: GeoPoint) {
        
        if let snap = checkCache(location) {
            loading.stopAnimating()
            map.image = snap
            mapPin.isHidden = false
            mapBubble.isHidden = false
            return
        }
        
        let style = URL(string: MapBox.styleUrl)
        let camera = MGLMapCamera(lookingAtCenter: location.coordinates(), altitude: Math.mileInMeters * 2, pitch: 0, heading: 0)
        let size = CGSize(width: UIScreen.main.bounds.width - 56, height: 136) // cheating a bit
        let options = MGLMapSnapshotOptions(styleURL: style, camera: camera, size: size)
        options.zoomLevel = 15
        
        // loading
        loading.isHidden = false
        loading.startAnimating()
        mapPin.isHidden = true
        mapBubble.isHidden = true
        map.image = nil
        
        // Create the map snapshot.
        var snapshotter: MGLMapSnapshotter? = MGLMapSnapshotter(options: options)
        snapshotter?.start { [weak self] (snapshot, error) in
            if error != nil {
                print("Unable to create a map snapshot.")
            } else if let snapshot = snapshot {
                self?.loading.stopAnimating()
                self?.map.image = snapshot.image
                self?.mapPin.isHidden = false
                self?.mapBubble.isHidden = false
                self?.cacheSnapshot(snapshot.image, location)
            }
            snapshotter = nil
        }
    }
    
    // MARK: - cache
    
    private func cacheKey(_ location: GeoPoint) -> String {
        return "chat_meetig_\(location.latitude)_\(location.longitude)"
    }
    
    private func cacheSnapshot(_ snapshot: UIImage, _ location: GeoPoint) {
        SDImageCache.shared.store(snapshot, forKey: cacheKey(location), toDisk: true)
    }
    
    private func checkCache(_ location: GeoPoint) -> UIImage? {
        if let cacheImage = SDImageCache.shared.imageFromDiskCache(forKey: cacheKey(location)) {
            return cacheImage
        }
        return nil
    }
}
