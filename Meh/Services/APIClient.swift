//
//  APIClient.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation
import Alamofire

typealias APICompletion = Result<AnyObject, NSError> -> Void

class APIClient {
    private let manager: Alamofire.Manager

    static let sharedInstance = APIClient()

    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        manager = Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: nil)
    }
}

// MARK: - Public

extension APIClient {
    func request(route: URLRequestConvertible, completion: APICompletion?) {
        manager.request(route).validate(statusCode: 200...399).responseJSON { response in
            completion?(response.result)
        }
    }
}
