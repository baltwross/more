//
//  ImageSearchService.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ImageSearchService {

    /*
    // Anirud keys
    static private let GoogleCutomSearchApiKey = "AIzaSyCToiS8iNvPIYi_HRbekmrTTfeaoKxNuO0"
    static private let GoogleCustomSearchEngineID = "003878442745318300727:pijggyfs9uo"
    */
    
    // More keys
    static private let GoogleCutomSearchApiKey = "AIzaSyARSeyHqoBMXep-JhSXNG_KKJ784XfJGtY"
    static private let GoogleCustomSearchEngineID = "014818910537487288361:kh_mvpzmoxm"
    
    static private let serviceUrl = "https://www.googleapis.com/customsearch/v1?key=\(GoogleCutomSearchApiKey)&cx=\(GoogleCustomSearchEngineID)&searchType=image&imgType=photo&imageSize=huge&filter=1"
    
    struct ImageData: Hashable {
        let url: String
        let thumbnailUrl: String?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(url)
        }
        
        static func == (lhs: ImageData, rhs: ImageData) -> Bool {
            return lhs.url == rhs.url
        }
    }
    
    static let shared = ImageSearchService()
    
    private weak var runningTask: URLSessionDataTask?
    
    init() {
        // TODO: - setup keys tc
    }
    
    func searchImages(for searchString: String, offset: Int, complete: @escaping (_ results: [ImageData])->()) {
        
        runningTask?.cancel()
        
        let countryCode = "us"
        let countryQuerry = "&cr=country\(countryCode.uppercased())&gl=\(countryCode.lowercased())"
        
        var searchQuery = "q=" + searchString
        searchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlString = ImageSearchService.serviceUrl + countryQuerry + "&" + searchQuery
        if offset > 0 {
            urlString += "&start=\(offset)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, responseError) in
            
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any],
                let items = json["items"] as? [[String: Any]]
            else {
                return
            }
            
            var results: [ImageData] = []
            for item in items {
                if let url = item["link"] as? String {
                    
                    let image = ImageData(
                        url: url,
                        thumbnailUrl: (item["image"] as? [String: Any])?["thumbnailLink"] as? String)
                    
                    results.append(image)
                }
            }
            
            complete(results)
        }
        task.resume()
        runningTask = task
    }
    
    /// mock
    private func mockApiResponse() -> [ImageData] {

        let results = [
            ImageData(url: "https://photos.mandarinoriental.com/is/image/MandarinOriental/new-york-2017-columbus-circle-day?wid=720&hei=1080&fmt=jpeg&qlt=75,0&op_sharpen=0&resMode=sharp2&op_usm=0.8,0.8,5,0&iccEmbed=0&printRes=72&fit=crop", thumbnailUrl: nil),
            ImageData(url: "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/31/09/new-york-statue-of-liberty.jpg", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/466685/pexels-photo-466685.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/374710/pexels-photo-374710.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/1402790/pexels-photo-1402790.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/1486222/pexels-photo-1486222.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/332208/pexels-photo-332208.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/290492/pexels-photo-290492.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
            ImageData(url: "https://images.pexels.com/photos/440152/pexels-photo-440152.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350", thumbnailUrl: nil),
        ]
        return results
    }

}
