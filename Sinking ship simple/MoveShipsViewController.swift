//
//  MoveShipsViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-18.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit

class MoveShipsViewController: UIViewController {
    
    @IBOutlet weak var battleView: UIView!
    var boatArray: [UIView] = []
    var positionArray: [BoatPositions]!
    let defaults = UserDefaults.standard
    var newCord = CGPoint(x: 0, y: 0)
    var tileWidthAndHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        positionArray = BoatPositions.getFromUserDefaults()
        tileWidthAndHeight = battleView.frame.width/10
        createBattlefield()
        createShips()
    }
    
    func createBattlefield() {
        var y: CGFloat = 0
        var count = 1
        for _ in 1...10 {
            var x: CGFloat = 0
            for _ in 1...10 {
                let frameSize = CGRect(x: CGFloat(x), y: y, width: tileWidthAndHeight, height: tileWidthAndHeight)
                let button = UIButton(frame: frameSize)
                button.backgroundColor = UIColor.blue
                button.tag = count
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.white.cgColor
                battleView.addSubview(button)
                x += tileWidthAndHeight
                count += 1
            }
            y += tileWidthAndHeight
        }
    }
    
    func createShips() {
        var i = 1
        for boatPosition in positionArray {
            let frame = calcPositionByTileSize(boatPosition: boatPosition)
            let boat = UIView(frame: frame)
            boat.backgroundColor = UIColor.green
            boat.layer.borderWidth = 2
            boat.layer.borderColor = UIColor.white.cgColor
            boat.tag = i
            let tapRecogn = UITapGestureRecognizer()
            tapRecogn.addTarget(self, action: #selector(tapToRotate))
            boat.addGestureRecognizer(tapRecogn)
            let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
            panGesture.minimumPressDuration = 0.5
            boat.addGestureRecognizer(panGesture)
            boatArray.append(boat)
            battleView.addSubview(boat)
            i += 1
            print("column = \(boatPosition.column), row = \(boatPosition.row), width = \(boatPosition.width), height = \(boatPosition.height)")
            
        }
    }
    
    @objc func tapToRotate(sender: UITapGestureRecognizer){
        guard let view = sender.view else {return }
        view.transform = view.transform.rotated(by: CGFloat.pi/2)
        var position = view.frame.origin
        if position.x < 0 {
            position.x = 0
        }else if position.x > battleView.frame.width-view.frame.width {
            position.x = battleView.frame.width-view.frame.width
        }
        if position.y < 0 {
            position.y = 0
        }else if position.y > battleView.frame.height-view.frame.height {
            position.y = battleView.frame.height-view.frame.height
        }
        position.x = calcPosition(position: position.x)
        position.y = calcPosition(position: position.y)
        view.frame.origin = CGPoint(x: position.x, y: position.y)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard let shipViewFrame = recognizer.view?.frame  else {return}
        let newCord = recognizer.location(in: battleView)
        let x = newCord.x - (recognizer.view?.frame.width)! / 2
        let y = newCord.y - (recognizer.view?.frame.height)! / 2
        
        if x >= 0 && x <= battleView.frame.width-shipViewFrame.width {
            self.newCord.x = calcPosition(position: x)
        }
        if y >= 0 && y <= battleView.frame.height-shipViewFrame.height {
            self.newCord.y = calcPosition(position: y)
        }
        recognizer.view?.frame.origin = CGPoint(x: self.newCord.x, y: self.newCord.y)
    }
    
    func calcPosition(position: CGFloat) -> CGFloat {
        let newPosition = CGFloat(Int(position/tileWidthAndHeight+0.5))*tileWidthAndHeight
        return newPosition
    }
    
    func calcRowColumnWidthHeight(boat: UIView)-> BoatPositions{
        let row = boat.frame.origin.y/tileWidthAndHeight + 0.5
        let column = boat.frame.origin.x/tileWidthAndHeight + 0.5
        let width = boat.frame.width/tileWidthAndHeight + 0.5
        let height = boat.frame.height/tileWidthAndHeight + 0.5
        print("column = \(column) row = \(row) height = \(height) width = \(width)")
        print("x = \(boat.frame.origin.x) y = \(boat.frame.origin.y) height = \(boat.frame.height) width = \(boat.frame.width)")
        return BoatPositions(row: row, column: column, height: height, width: width)
        
    }
    
    @IBAction func saveShipsPosition(_ sender: Any) {
       saveUserDefaults()
    }
    
    func saveUserDefaults(){
        boatsPosition()
        BoatPositions.saveToUserDefaults(boats: positionArray)
        self.dismiss(animated: true, completion: nil)
    }
    
    func boatsPosition() {
        var array: [BoatPositions] = []
        for boat in boatArray {
            array.append(calcRowColumnWidthHeight(boat: boat))
        }
        positionArray = array
    }
    
     func calcPositionByTileSize(boatPosition: BoatPositions)-> CGRect{
        let x = boatPosition.column*tileWidthAndHeight
        let y = boatPosition.row*tileWidthAndHeight
        let height = boatPosition.height*tileWidthAndHeight
        let width = boatPosition.width*tileWidthAndHeight
        let frame = CGRect(x: x, y: y, width: width, height: height)
        return frame
    }
}
