//
//  NSAttributedString+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 4/6/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func heightForSize(size: CGSize) -> CGFloat {
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0

        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: self)
        textStorage.addLayoutManager(layoutManager)

        layoutManager.ensureLayoutForTextContainer(textContainer)

        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        let height = ceil(usedRect.height)

        return height
    }

    func singleLineWidth() -> CGFloat {
        let size = CGSize(width: CGFloat.max, height: CGFloat.max)
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0

        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: self)
        textStorage.addLayoutManager(layoutManager)

        layoutManager.ensureLayoutForTextContainer(textContainer)

        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        let width = ceil(usedRect.width)

        return width
    }
}
