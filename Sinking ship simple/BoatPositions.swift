//
//  BoatPositions.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-20.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit

class BoatPositions: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Int(row), forKey: "row")
        aCoder.encode(Int(column), forKey: "column")
        aCoder.encode(Int(width), forKey: "width")
        aCoder.encode(Int(height), forKey: "height")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let row = CGFloat(aDecoder.decodeInteger(forKey: "row"))
        let column = CGFloat(aDecoder.decodeInteger(forKey: "column"))
        let height = CGFloat(aDecoder.decodeInteger(forKey: "width"))
        let width = CGFloat(aDecoder.decodeInteger(forKey: "height"))
        self.init(row: row, column: column, height: height, width: width)
    }
    
    var row: CGFloat
    var column: CGFloat
    var height: CGFloat
    var width: CGFloat
    
    init(row: CGFloat, column: CGFloat, height: CGFloat, width: CGFloat) {
        self.row = row
        self.column = column
        self.height = height
        self.width = width
    }
}
