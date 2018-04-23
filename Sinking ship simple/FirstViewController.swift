//
//  FirstViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-20.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if  defaults.array(forKey: "boatsPosition") == nil {
            print("before insert")
            let data = NSKeyedArchiver.archivedData(withRootObject: createStandardBoatsPosition())
            defaults.set(data, forKey: "boatsPosition")
            print("after insert")
        }
    }
    
    func createStandardBoatsPosition() -> [BoatPositions] {
        return [BoatPositions(row: 3, column: 9, height: 6, width: 1),
                             BoatPositions(row: 2, column: 2, height: 1, width: 5),
                             BoatPositions(row: 6, column: 1, height: 1, width: 4),
                             BoatPositions(row: 8, column: 6, height: 3, width: 1),
                             BoatPositions(row: 6, column: 8, height: 2, width: 1),
                             ]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
