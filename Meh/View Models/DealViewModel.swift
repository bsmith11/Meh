//
//  DealViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

enum DealItem {
    case Features
    case Specs
    case Video
    case Story
}

class DealViewModel {
    private let dealService: DealService
    private let items: [DealItem] = [
        .Specs,
        .Features,
        .Video,
        .Story
    ]

    private(set) var deal: Deal?

    init() {
        dealService = DealService(client: APIClient.sharedInstance)
    }
}

// MARK: - Public

extension DealViewModel {
    func numberOfSections() -> Int {
        if let _ = deal {
            return 1
        }
        else {
            return 0
        }
    }

    func numberOfItemsInSection(section: Int) -> Int {
        return items.count
    }

    func itemAtIndexPath(indexPath: NSIndexPath) -> DealItem? {
        if indexPath.item < items.count {
            return items[indexPath.item]
        }
        else {
            return nil
        }
    }

    func fetchDealWithCompletion(completion: DealCompletion?) {
        dealService.fetchDeal { [weak self] (deal: Deal?, error: NSError?) in
            self?.deal = deal

            completion?(deal, error)
        }
    }
}
