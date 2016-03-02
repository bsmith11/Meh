//
//  DealViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

struct DealTheme {
    var backgroundColor: UIColor?
    var foregroundColor: UIColor?
    var accentColor: UIColor?
}

class DealViewModel: NSObject {
    var dealTheme: DealTheme?
    var dealName: NSAttributedString?

    override init() {
        super.init()

        dealTheme?.backgroundColor = UIColor(hexString: "C4E3F1")
        dealTheme?.foregroundColor = UIColor.blackColor()
        dealTheme?.accentColor = UIColor(hexString: "92A64D")
    }
}