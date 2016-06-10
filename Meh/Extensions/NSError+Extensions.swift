//
//  NSError+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 6/9/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

enum ErrorCategory {
    case Unknown
    case InvalidResponse
    case ServerError

    var title: String {
        return "Error"
    }

    var message: String {
        switch self {
        case .Unknown:
            return "Something seems to have gone wrong..."
        case .InvalidResponse:
            return "Invalid response from server"
        case .ServerError:
            return "The server just exploded..."
        }
    }

    var code: Int {
        switch self {
        case .Unknown:
            return 0
        case .InvalidResponse:
            return 0
        case .ServerError:
            return 500
        }
    }
}

extension NSError {
    var title: String {
        if let title = userInfo["title"] as? String {
            return title
        }
        else {
            return "No Title"
        }
    }

    var message: String {
        if let message = userInfo["message"] as? String {
            return message
        }
        else {
            return "No Message"
        }
    }

    func mehError() -> NSError {
        switch self.code {
        case 404: fallthrough
        case 500:
            return NSError.errorWithCategory(.ServerError)
        default:
            return NSError.errorWithCategory(.Unknown)
        }
    }

    class func errorWithCategory(category: ErrorCategory) -> NSError {
        let domain = "com.meh.error"
        let code = category.code
        let title = category.title
        let message = category.message
        let userInfo = [
            "title": title,
            "message": message
        ]

        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
