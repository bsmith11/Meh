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
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }
}

// MARK: - Public

extension DealService {
    func fetchDeal(completion: DealCompletion?) {
        let baseURL = NSURL(string: "https://api.meh.com")!
        let path = "1/current.json"
        let URL = baseURL.URLByAppendingPathComponent(path)
        let encoding = ParameterEncoding.URL
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = Method.GET.rawValue
        let parameters = [
            "apikey": "Tg0jquXpmCHJl3afwY0MpFKK693vv5q3"
        ]

        let route = encoding.encode(request, parameters: parameters).0

        client.request(route) { (result: Result) in
            if result.isSuccess {
                guard let dictionary = result.value as? [String: AnyObject],
                          deal = Deal(dictionary: dictionary) else {
                    let error = NSError.errorWithCategory(.InvalidResponse)

                    completion?(nil, error)
                    return
                }

                //Pre-fetch photo URLs
                var requests = [URLRequestConvertible]()

                for photoURL in deal.photoURLs {
                    let request = NSURLRequest(URL: photoURL)
                    requests.append(request)
                }

                let width = UIScreen.mainScreen().bounds.width
                let height = width - 40.0
                let size = CGSize(width: width, height: height)
                let imageFilter = AspectScaledToFitSizeFilter(size: size)

                ImageDownloader.defaultInstance.downloadImages(URLRequests: requests, filter: imageFilter, completion: nil)

                //Pre-fetch video URL thumbnail
                if let videoURLThumbnail = deal.videoURLThumbnail {
                    let request = NSURLRequest(URL: videoURLThumbnail)

                    ImageDownloader.defaultInstance.downloadImages(URLRequests: [request])
                }

                completion?(deal, nil)
            }
            else {
                let error = result.error?.mehError()
                completion?(nil, error)
            }
        }
    }
}
