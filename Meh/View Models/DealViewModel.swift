//
//  DealViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol DealViewModelDelegate {
    func didUpdateDeal()
}

class DealViewModel {
    private let dealService: DealService
    private(set) var deal: Deal? {
        didSet {
            delegate?.didUpdateDeal()
        }
    }

    var delegate: DealViewModelDelegate?

    init() {
        dealService = DealService(client: APIClient.sharedInstance)
        dealService.fetchDeal { (deal: Deal?, error: NSError?) -> Void in
            self.deal = deal

            if error != nil {
                print("Failed with error: \(error)")
            }
            else {
                print("Success")
            }
        }
    }
}
