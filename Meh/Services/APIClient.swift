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

    // MARK: - Properties

    static let sharedInstance = APIClient()

    private let manager: Alamofire.Manager

    // MARK: - Lifecycle

    init() {
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        manager = Alamofire.Manager(configuration: config, serverTrustPolicyManager: nil)
    }

    // MARK: - Actions

    func request(route: URLRequestConvertible, completion: APICompletion?) {
        manager.request(route).validate(statusCode: 200...399).responseJSON { response -> Void in
            completion?(response.result)
        }
    }
}
