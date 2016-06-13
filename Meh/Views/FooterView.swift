//
//  FooterView.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class FooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Public

extension FooterView {
    func configureWithTheme(theme: Theme) {
        backgroundColor = theme.accentColor
    }
}
