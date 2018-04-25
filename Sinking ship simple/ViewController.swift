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
    var yourTurn: Bool!
    var whosTurn: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createButtons(view: upperView, addTarget: false)
        createButtons(view: lowerView, addTarget: true)
        createShips()
        whosTurn = Int(arc4random_uniform(100))
    }
    
    func createButtons(view: UIView, addTarget: Bool) {
        let width = view.frame.width/10
        let height = view.frame.height/10
        var y: CGFloat = 0
        var count = 1
        for _ in 1...10 {
            var x: CGFloat = 0
            for _ in 1...10 {
                let frameSize = CGRect(x: CGFloat(x), y: y, width: width, height: height)
                let button = UIButton(frame: frameSize)
                if addTarget {
                    button.addTarget(self, action: #selector(clickedButton), for: .touchUpInside)
                }
                button.backgroundColor = UIColor.blue
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

    func createShips() {
        let positionArray = BoatPositions.getFromUserDefaults()
        for boatPosition in positionArray {
            let frame = calcPositionByTileSize(boatPosition: boatPosition)
            let boat = UIView(frame: frame)
            boat.backgroundColor = UIColor.green
            boat.layer.borderWidth = 2
            boat.layer.borderColor = UIColor.white.cgColor
            upperView.addSubview(boat)
        }
    }
    
    @objc func clickedButton(sender: UIButton!){
        print("button clicked \(sender.tag)")
        if yourTurn {
            
        }
    }
    
    func calcPositionByTileSize(boatPosition: BoatPositions)-> CGRect{
        let tileWidth = upperView.frame.width/10
        let tileHeight = upperView.frame.height/10
        let x = boatPosition.column*tileWidth
        let y = boatPosition.row*tileHeight
        let height = boatPosition.height*tileHeight
        let width = boatPosition.width*tileWidth
        let frame = CGRect(x: x, y: y, width: width, height: height)
        return frame
    }
    //hämta userdefaults och kolla om den är nil är den nil så skapa up standard skepp och spara ner i userdefaults. Dessa hämtar vi sedan i både moveViewcontroller och gameviewcontroller
    //hämta och spara userdefaults ska vara en fil eftersom det görs i ala vyer
    //beräkningar bör också vara i en fil positionsfilen? för det görs i två vyer Bör retunera cgrects
    //Den övre vyn ska dina skepp ritas ut och när ett blir träffat så ska det märkas upp
    // Den undre vyn ska du kunna skjuta på när det är din tur Skutten ska märkas ut och du får inte skjuta på samma ställe.
    //När ett helt skepp blivit nerskjutet ska det bli synligt
    //Den övre vyn hade inte behövts byggas i knappar då den ändå inte ska ha någon action kopplad till sig
}

