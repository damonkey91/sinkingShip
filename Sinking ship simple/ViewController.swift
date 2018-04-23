//
//  ViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-18.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var upperButtonArray: [UIButton] = []
    var lowerButtonArray: [UIButton] = []
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createButtons(view: upperView)
        createButtons(view: lowerView)
    }
    
    func createButtons(view: UIView) {
        let width = view.frame.width/10
        let height = view.frame.height/10
        var y: CGFloat = 0
        var count = 1
        for _ in 1...10 {
            var x: CGFloat = 0
            for _ in 1...10 {
                let frameSize = CGRect(x: CGFloat(x), y: y, width: width, height: height)
                let button = UIButton(frame: frameSize)
                button.backgroundColor = UIColor.blue
                button.addTarget(self, action: #selector(clickedButton), for: .touchUpInside)
                button.tag = count
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.white.cgColor
                view.addSubview(button)
                x += width
                count += 1
            }
            y += height
        }
    }

    @objc func clickedButton(sender: UIButton!){
        print("button clicked \(sender.tag)")
    }
    //hämta userdefaults och kolla om den är nil är den nil så skapa up standard skepp och spara ner i userdefaults. Dessa hämtar vi sedan i både moveViewcontroller och gameviewcontroller

}

