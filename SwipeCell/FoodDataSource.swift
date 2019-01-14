//
//  FoodDataSource.swift
//  TrackFoodExample
//
//  Created by Jon Lu on 1/8/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import Foundation

struct Food {
    let name: String
    let serving: String
    let smartPts: Int
}

func generateFood() -> [Food] {
    return [
        Food(name: "Eggs", serving: "2 items", smartPts: 0),
        Food(name: "Ham cooked", serving: "2 pounds", smartPts: 12),
        Food(name: "Chicken breast", serving: "2 pounds", smartPts: 4),
        Food(name: "Broccoli", serving: "6 pounds", smartPts: 0),
        Food(name: "Steak, flat iron", serving: "6 oz", smartPts: 10),
        Food(name: "Sweet Potato Breakfast Hash", serving: "1 serving(s)", smartPts: 2)
    ]
}
