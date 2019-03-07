//
//  SwipeActionButton.swift
//  SwipeCell
//
//  Created by Jon Lu on 3/1/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit

class SwipeActionButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 100)
    }
    convenience init(action: SwipeAction) {
        self.init(frame: .zero)
        
        contentHorizontalAlignment = .center
        tintColor = .black
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.numberOfLines = 1
    }
}
