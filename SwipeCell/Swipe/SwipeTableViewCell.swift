//
//  SwipeTableViewCell.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/14/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

class SwipeTableViewCell: UITableViewCell {
    
    var state = SwipeCellState.initial
    var actionView: SwipeActionView?
    var swipeController: SwipeController!
    var panGestureRecognizer: UIGestureRecognizer {
        return swipeController.panGestureRecognizer
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        swipeController = SwipeController(swipeable: self, actionContainerView: self)
        //swipeController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
