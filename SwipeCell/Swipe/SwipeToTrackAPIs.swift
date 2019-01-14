//
//  SwipeToTrackAPIs.swift
//  SwipeCell
//
//  Created by Jon Lu on 1/13/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    var swipeCells: [SwipeTableViewCell] {
        return visibleCells.compactMap({ $0 as? SwipeTableViewCell })
    }
    func hideSwipeCell() {
        swipeCells.forEach { $0.hideSwipe(animated: true) }
    }
}
