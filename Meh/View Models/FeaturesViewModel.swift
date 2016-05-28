//
//  FeaturesViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import SwiftyMarkdown

struct FeaturesViewModel {
    let features: String
    let featuresAttributedString: NSAttributedString

    init(deal: Deal?) {
        features = deal?.features ?? "No Features"

        let featuresMarkdown = SwiftyMarkdown.markdownWithString(features, fontSize: 16.0)

        //TODO: - Figure out why spaces arent working when calculating width, for now using "l"
        let indentMarkdown = SwiftyMarkdown.markdownWithString("\u{2022}l", fontSize: 16.0)
        let size = CGSize(width: CGFloat.max, height: CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesFontLeading, .UsesLineFragmentOrigin]
        let indentBoundingRect = indentMarkdown.attributedString().boundingRectWithSize(size, options: options, context: nil)
        let headIndent = ceil(indentBoundingRect.width)

        featuresAttributedString = featuresMarkdown.attributedString().attributedStringByApplyingLineBreakMode(.ByWordWrapping, headIndent: headIndent)
    }
}
