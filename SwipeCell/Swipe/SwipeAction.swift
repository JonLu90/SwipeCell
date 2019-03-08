//
//  SwipeAction.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/11/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

struct SwipeAction {
    
    public var title: String = "Track"
    
    public var actionHandler: ((SwipeAction, IndexPath)->Void)?
    // private var style: actionTriggeredAnimationStyle
    // TODO init
    // TODO: completion handler
    
    public func actionFulfill() {
        // completion handler
    }
}

enum actionTriggeredAnimationStyle {
    case fill
    case bounce
}
