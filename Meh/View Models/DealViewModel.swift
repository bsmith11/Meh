//
//  DealViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

enum DealItem: Equatable {
    case Features
    case Specs
    case Video(NSURL?)
    case Image(NSURL?)
    case Story
    case Paragraph(String)
    case Table([[String]])
}

func == (lhs: DealItem, rhs: DealItem) -> Bool {
    switch (lhs, rhs) {
    case (.Features, .Features):
        return true
    case (.Specs, .Specs):
        return true
    case (.Video(let leftURL), .Video(let rightURL)):
        return leftURL == rightURL
    case (.Image(let leftURL), .Image(let rightURL)):
        return leftURL == rightURL
    case (.Story, .Story):
        return true
    case (.Paragraph(let leftString), .Paragraph(let rightString)):
        return leftString == rightString
    case (.Table(let leftObject), .Table(let rightObject)):
        return leftObject == rightObject
    default:
        return false
    }
}

class DealViewModel {
    private let dealService: DealService
    private var items = [DealItem]()

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

    func indexPathForItem(item: DealItem) -> NSIndexPath? {
        let index = items.indexOf(item)

        if let index = index {
            return NSIndexPath(forItem: index, inSection: 0)
        }
        else {
            return nil
        }
    }

    func fetchDealWithCompletion(completion: DealCompletion?) {
        dealService.fetchDeal { [weak self] (deal: Deal?, error: NSError?) in
            self?.deal = deal
            self?.configureItems()

            completion?(deal, error)
        }
    }
}

// MARK: - Private

private extension DealViewModel {
    func configureItems() {
        items.removeAll()
//        items.append(.Specs)
//        items.append(.Features)
//        items.append(.Video(deal?.videoURL))
//        items.append(.Story)

        if let body = deal?.specifications {
            for substring in body.componentsSeparatedByString("\r\n\r\n") {
                let string = substring.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if !string.isEmpty {
                    if string.isYoutubeURL() {
                        items.append(.Video(NSURL(string: string)))
                    }
                    else if string.isImageURL() {
                        items.append(.Image(NSURL(string: string)))
                    }
                    else if let rows = string.tableMarkdownRows() {
                        items.append(.Table(rows))
                    }
                    else {
                        items.append(.Paragraph(string))
                    }
                }
            }
        }
    }
}
