//
//  PageControl.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class PageControl: UIView {

    // MARK: - Properties

    private static let pageIndicatorSize = CGSize(width: 10.0, height: 10.0)

    var currentPage = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var numberOfPages = 0 {
        didSet {
            hidden = (numberOfPages == 1) && hidesForSinglePage

            setNeedsDisplay()
        }
    }

    var hidesForSinglePage = true {
        didSet {
            if hidesForSinglePage {
                hidden = (numberOfPages == 1)
            }
            else {
                hidden = false
            }
        }
    }

    var pageIndicatorTintColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    var currentPageIndicatorTintColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        var origin = CGPoint(x: 1.0, y: 1.0)

        (pageIndicatorTintColor ?? UIColor.grayColor()).setStroke()
        (currentPageIndicatorTintColor ?? UIColor.blackColor()).setFill()

        for page in 0 ..< numberOfPages {
            let rect = CGRect(origin: origin, size: PageControl.pageIndicatorSize)
            let path = UIBezierPath(ovalInRect: rect)
            path.lineWidth = 1.0
            path.stroke()

            if page == currentPage {
                path.fill()
            }

            origin.x += (2.0 * PageControl.pageIndicatorSize.width)
        }
    }

    override func intrinsicContentSize() -> CGSize {
        let count = CGFloat((2 * numberOfPages) - 1)
        let width = count * PageControl.pageIndicatorSize.width + 2.0
        let height = PageControl.pageIndicatorSize.height + 2.0

        return CGSize(width: width, height: height)
    }

    class func height() -> CGFloat {
        return PageControl.pageIndicatorSize.height + 2.0
    }
}
