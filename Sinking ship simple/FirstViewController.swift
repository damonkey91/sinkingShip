//
//  FirstViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-20.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().signInAnonymously() { (user, error) in
            if error != nil{
                print(error)
            }else {
                print("Login sucess")
            }
        }
    }
}
