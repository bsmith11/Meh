//
//  DealService.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

typealias DealCompletion = (Deal?, NSError?) -> Void

class DealService {

    let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchDeal(completion: DealCompletion?) {
        let baseURL = NSURL(string: "https://api.meh.com")!
        let path = "1/current.json"
        let URL = baseURL.URLByAppendingPathComponent(path)
        let encoding = ParameterEncoding.URL
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = Method.GET.rawValue
        let parameters = [
            "apikey": ""
        ]

        let route = encoding.encode(request, parameters: parameters).0

        client.request(route) { (result: Result) -> Void in
            if result.isSuccess {
                if let dictionary = result.value as? Dictionary<String, AnyObject> {
                    let deal = Deal(dictionary: dictionary)

                    completion?(deal, nil)
                }
                else {
                    completion?(nil, nil)
                }
            }
            else {
                completion?(nil, result.error)
            }
        }
    }

    func mockFetchDeal(completion: DealCompletion?) {
        var deal: Deal?

        if let path = NSBundle.mainBundle().pathForResource("meh", ofType: ".json") {
            if let data = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? Dictionary<String, AnyObject> {
                        deal = Deal(dictionary: json)
                    }
                }
                catch _ {
                    print("Failed to serialize JSON")
                }
            }
        }

        //Pre-fetch photo URLs
        if let photoURLs = deal?.photoURLs {
            var requests = [URLRequestConvertible]()

            for photoURL in photoURLs {
                let request = NSURLRequest(URL: photoURL)
                requests.append(request)
            }

            ImageDownloader.defaultInstance.downloadImages(URLRequests: requests)
        }

        //Pre-fetch video URL thumbnail
        if let videoURLThumbnail = deal?.videoURLThumbnail {
            let request = NSURLRequest(URL: videoURLThumbnail)

            ImageDownloader.defaultInstance.downloadImage(URLRequest: request)
        }

        completion?(deal, nil)
    }
}
