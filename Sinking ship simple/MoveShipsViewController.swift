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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = defaults.data(forKey: "boatsPosition")
        positionArray = NSKeyedUnarchiver.unarchiveObject(with: data!) as! [BoatPositions]
        createBattlefield()
        createShips()
    }
    
    func createBattlefield() {
        let widthAndHeight = battleView.frame.width/10
        var y: CGFloat = 0
        var count = 1
        for _ in 1...10 {
            var x: CGFloat = 0
            for _ in 1...10 {
                let frameSize = CGRect(x: CGFloat(x), y: y, width: widthAndHeight, height: widthAndHeight)
                let button = UIButton(frame: frameSize)
                button.backgroundColor = UIColor.blue
                button.tag = count
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.white.cgColor
                battleView.addSubview(button)
                x += widthAndHeight
                count += 1
            }
            y += widthAndHeight
        }
    }
    
    func createShips() {
        let widthAndHeight = battleView.frame.width/10
        var y: CGFloat = battleView.frame.height
        var x: CGFloat = 0
        for i in 2...6{
            let frame = CGRect(x: x, y: y-widthAndHeight*CGFloat(i), width: widthAndHeight, height: widthAndHeight*CGFloat(i))
            let boat = UIView(frame: frame)
            boat.backgroundColor = UIColor.green
            boat.layer.borderWidth = 2
            boat.layer.borderColor = UIColor.white.cgColor
            boat.tag = i-1
            let tapRecogn = UITapGestureRecognizer()
            tapRecogn.addTarget(self, action: #selector(tapToRotate))
            boat.addGestureRecognizer(tapRecogn)
            let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
            panGesture.minimumPressDuration = 0.5
            boat.addGestureRecognizer(panGesture)
            
            boatArray.append(boat)
            battleView.addSubview(boat)
            x += widthAndHeight
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
        print("y = \(self.newCord.y) x = \(self.newCord.x)")
        calcRowColumnWidthHeight(boat: recognizer.view!)
    }
    
    func calcPosition(position: CGFloat) -> CGFloat {
        let widthAndHeight = battleView.frame.width/10
        let newPosition = CGFloat(Int(position/widthAndHeight+0.5))*widthAndHeight
        return newPosition
    }
    
    func calcRowColumnWidthHeight(boat: UIView)-> BoatPositions{
        let tileSize = battleView.frame.width/10
        let row = boat.frame.origin.y/tileSize+1
        let column = boat.frame.origin.x/tileSize+1
        let width = boat.frame.width/tileSize
        let height = boat.frame.height/tileSize
        print("column = \(column) row = \(row) height = \(height) width = \(width)")
        return BoatPositions(row: row, column: column, height: height, width: width)
        
    }
    
    @IBAction func saveShipsPosition(_ sender: Any) {
       saveUserDefaults()
    }
    
    func saveUserDefaults(){
        boatsPosition()
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: positionArray)
        let defaults = UserDefaults.standard
        defaults.set(encodeData, forKey: "boatsPosition")
        self.dismiss(animated: true, completion: nil)
    }
    
    func boatsPosition() {
        var array: [BoatPositions] = []
        for boat in boatArray {
            array.append(calcRowColumnWidthHeight(boat: boat))
        }
        positionArray = array
    }
    /*
    func calcPositionByTileSize(){
        let tileSize = battleView.frame.width/10
        let y = row*(tileSize-1)
        let x = column*(tileSize-1)
        let width = width*tileSize
        let height = height*tileSize
    }*/
    //Spara ner positioner och vilka skepp
    //Gör om positioner till vilka rad och kolumn skeppen står på och bredd och höjd i rutor
    //Kolla om skeppen ligger på varandra?
    //firebase. Skicka information om var skeppen är. vilka som är träffade
    //ska inte kunna skjuta på samma ställe två gånger.
}
