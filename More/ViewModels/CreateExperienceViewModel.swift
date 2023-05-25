//
//  CreateExperienceViewModel.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class CreateExperienceViewModel: Codable {
    
    let creator: User = ProfileService.shared.profile?.user ?? User()
    
    struct Photo: Codable, Hashable {
        
        enum CodingKeys: String, CodingKey {
            case webImage
            case image
            case url
            case video
            case videoPreview
        }
        
        var webImage: Image? = nil
        var image: UIImage? = nil
        var url: String? = nil
        var video: Data? = nil
        var videoPreview: UIImage? = nil
        var isUploaded: Bool = false
        
        init(webImage: Image? = nil, image: UIImage? = nil, url: String? = nil, video: Data? = nil, videoPreview: UIImage? = nil, isUploaded: Bool = false) {
            self.webImage = webImage
            self.image = image
            self.url = url
            self.video = video
            self.videoPreview = videoPreview
            self.isUploaded = isUploaded
        }
        
        // Codable
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let imageData = try? container.decode(Data.self, forKey: .image) {
                image = UIImage(data: imageData)
            }
            url = try? container.decodeIfPresent(String.self, forKey: .url)
            video = try? container.decodeIfPresent(Data.self, forKey: .video)
            if let previewData = try? container.decode(Data.self, forKey: .videoPreview) {
                videoPreview = UIImage(data: previewData)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            if let image = image, let imageData = UIImageProgressiveJPEGRepresentation(image, 1) {
                try container.encode(imageData, forKey: .image)
            }
            try container.encode(url, forKey: .url)
            try container.encode(video, forKey: .video)
            if let videoPreview = videoPreview, let previewData = UIImageProgressiveJPEGRepresentation(videoPreview, 1) {
                try container.encode(previewData, forKey: .videoPreview)
            }
        }
        
        // Hashable
        
        func hash(into hasher: inout Hasher) {
            if let image = image {
                hasher.combine(image)
            } else if let url = url {
                hasher.combine(url)
            } else if let video = video {
                hasher.combine(video)
            }
        }
        
        static func == (lhs: Photo, rhs: Photo) -> Bool {
            if let image = lhs.image {
                return image == rhs.image
            }
            if let url = lhs.url {
                return rhs.image == nil && url == rhs.url
            }
            if let video = lhs.video {
                return video == rhs.video
            }
            return false
        }
    }

    var images: [Photo] = []
    
    var type: SignalType?
    var title: String = ""
    var text: String = ""

    var somewhere: Bool = false
    var destination: GeoPoint?
    var destinationName: String?
    var destinationAddress: String?
    var destinationNeighbourhood: String?
    var destinationCity: String?
    var destinationState: String?
    
    var sometime: Bool = false
    var schedule: ExperienceSchedule?
        
    var radius: Double?
    
    var tier: Product?
    
    func experience(id: String, isPrivate: Bool) -> Experience {
        
        let createdAt = Date()
        let expiresAt = Date(timeIntervalSinceNow: ConfigService.shared.signalExpiration)
        
        let hasDestination = !somewhere &&
            destinationNeighbourhood == nil &&
            destinationCity == nil &&
            destinationState == nil
        
        var webImages: [Image] = []
        for image in images {
            if let webImage = image.webImage {
                webImages.append(webImage)
            }
        }
        
        return Experience(
            id: id,
            title: title,
            text: text,
            images: webImages,
            type: type ?? .magical,
            isVirtual: false,
            isPrivate: isPrivate,
            tier: tier,
            creator: creator,
            createdAt: createdAt,
            expiresAt: expiresAt,
            radius: radius,
            schedule: schedule,
            destination: hasDestination ? destination : nil,
            destinationName: destinationName,
            destinationAddress: destinationAddress,
            anywhere: somewhere ? true : nil,
            neighbourhood: destinationNeighbourhood,
            city: destinationCity,
            state: destinationState)
    }
    
    enum CodingKeys: String, CodingKey {
        case creator
        case images
        case type
        case title
        case text
        case somewhere
        case destination
        case destinationName
        case destinationAddress
        case destinationNeighbourhood
        case destinationCity
        case destinationState
        case sometime
        case schedule
    }
    
    init() { }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        images = (try? container.decode([Photo].self, forKey: .images)) ?? []
        type = try? container.decodeIfPresent(SignalType.self, forKey: .type)
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        text = (try? container.decode(String.self, forKey: .text)) ?? ""
        somewhere = try container.decode(Bool.self, forKey: .somewhere)
        destination = try? container.decodeIfPresent(GeoPoint.self, forKey: .destination)
        destinationName = try? container.decodeIfPresent(String.self, forKey: .destinationName)
        destinationAddress = try? container.decodeIfPresent(String.self, forKey: .destinationAddress)
        destinationNeighbourhood = try? container.decodeIfPresent(String.self, forKey: .destinationNeighbourhood)
        destinationCity = try? container.decodeIfPresent(String.self, forKey: .destinationCity)
        destinationState = try? container.decodeIfPresent(String.self, forKey: .destinationState)
        sometime = try container.decode(Bool.self, forKey: .sometime)
        schedule = try? container.decode(ExperienceSchedule.self, forKey: .schedule)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(images, forKey: .images)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(somewhere, forKey: .somewhere)
        try container.encodeIfPresent(destination, forKey: .destination)
        try container.encodeIfPresent(destinationName, forKey: .destinationName)
        try container.encodeIfPresent(destinationAddress, forKey: .destinationAddress)
        try container.encodeIfPresent(destinationNeighbourhood, forKey: .destinationNeighbourhood)
        try container.encodeIfPresent(destinationCity, forKey: .destinationCity)
        try container.encodeIfPresent(destinationState, forKey: .destinationState)
        try container.encode(sometime, forKey: .sometime)
        try container.encodeIfPresent(schedule, forKey: .schedule)
        
    }
}

