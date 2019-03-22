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
        return CGSize(width: 40, height: 40)
    }
    init(action: SwipeAction) {
        super.init(frame: .zero)
        
        contentHorizontalAlignment = .center
        tintColor = .black
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.numberOfLines = 1
        
        
//        self.addTarget(self, action: #selector(tapToFire(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func tapToFire(sender: UIButton) {
//        print("tap to fire !")
//    }
}
