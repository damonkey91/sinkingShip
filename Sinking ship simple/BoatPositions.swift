//
//  BoatPositions.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-20.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit

class BoatPositions: NSObject, NSCoding {
    
    static let BOAT_POSITION_KEY = "boatsPosition"
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
    
    required convenience init?(coder aDecoder: NSCoder) {
        let row = CGFloat(aDecoder.decodeInteger(forKey: "row"))
        let column = CGFloat(aDecoder.decodeInteger(forKey: "column"))
        let height = CGFloat(aDecoder.decodeInteger(forKey: "height"))
        let width = CGFloat(aDecoder.decodeInteger(forKey: "width"))
        self.init(row: row, column: column, height: height, width: width)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Int(row), forKey: "row")
        aCoder.encode(Int(column), forKey: "column")
        aCoder.encode(Int(width), forKey: "width")
        aCoder.encode(Int(height), forKey: "height")
    }
    
    static func saveToUserDefaults(boats: [BoatPositions]){
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: boats)
        UserDefaults.standard.set(encodeData, forKey: BOAT_POSITION_KEY)
    }
    
    static func getFromUserDefaults()->[BoatPositions]{
        
        var data = UserDefaults.standard.data(forKey: BOAT_POSITION_KEY)
        if data == nil {
            saveToUserDefaults(boats: createStandardBoatsPosition())
            data = UserDefaults.standard.data(forKey: BOAT_POSITION_KEY)
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data!) as! [BoatPositions]
    }
    
   private static func createStandardBoatsPosition() -> [BoatPositions] {
        return [BoatPositions(row: 2, column: 8, height: 6, width: 1),
                BoatPositions(row: 1, column: 1, height: 1, width: 5),
                BoatPositions(row: 5, column: 0, height: 1, width: 4),
                BoatPositions(row: 7, column: 5, height: 3, width: 1),
                BoatPositions(row: 5, column: 7, height: 2, width: 1),
        ]
        
    }
}
