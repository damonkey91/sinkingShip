//
//  ViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-18.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

class ViewController: UIViewController {
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var toastLabel: UILabel!
    var yourTurn = false
    var firstTurn: Int = Int(arc4random_uniform(1000))
    var informationArray: [Information] = []
    let userId = Int(arc4random_uniform(5000))
    var opponentsBoatPositionArray: [BoatPositions] = []
    var myBoatPositionsAsTileNrs: [[Int]] = []
    var opponentsBoatPositionsAsTileNrs: [[Int]] = []
    var opponentsHitsLeftArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toastLabel.layer.zPosition = -1
        toastLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createButtons(view: upperView, addTarget: false)
        createButtons(view: lowerView, addTarget: true)
        createShips()
        setupDatabase()
        sendGameInfoToDatabase()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Gonna delete data dissaper")
        let database = Database.database().reference()
        database.removeValue()
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
    
    func setupDatabase() {
        var database = Database.database().reference().child("chooseTurn")
        database.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [Any]
            print(snapshot)
            let gameInformation = Information()
            let first = snapshotValue[0] as! [String: String]
            let second = snapshotValue[1] as! [String: [[String: Int]]]
            let boats = second["BoatPosition"]!
            gameInformation.number = Int(first["FirstTurn"]!)!
            gameInformation.sender = Int(first["Sender"]!)!
            if gameInformation.sender != self.userId{
                for boatpos in boats {
                    let boatPosition = BoatPositions(
                        row: CGFloat(boatpos["row"]!),
                        column: CGFloat(boatpos["column"]!),
                        height: CGFloat(boatpos["height"]!),
                        width: CGFloat(boatpos["width"]!))
                    self.opponentsBoatPositionArray.append(boatPosition)
                }
            }
            self.informationArray.append(gameInformation)
            self.startFirstTurn()
        }
        
        database = Database.database().reference().child("SinkingShip")
        database.observe(.childChanged) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: Int]
            let sender = snapshotValue["Sender"]
            if sender != self.userId {
                let shot = snapshotValue["Shot"]!
                let hitNr = snapshotValue["Hit"]!
                let youLost = snapshotValue["YouLost"]!
                let hit = hitNr == 1
                self.yourTurn = !hit
                self.shotUpperView(shot: shot, hit: hit)
                if self.yourTurn {
                    self.showToast(text: "Your turn")
                }
                if youLost == 1 {
                    print("You Lost")
                    self.showPopUp(won: false)
                }
            }
        }
        database.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: Int]
            let sender = snapshotValue["Sender"]
            if sender != self.userId {
                let shot = snapshotValue["Shot"]!
                let hitNr = snapshotValue["Hit"]!
                let hit = hitNr == 1
                self.yourTurn = !hit
                self.shotUpperView(shot: shot, hit: hit)
                if self.yourTurn {
                    self.showToast(text: "Your turn")
                }
            }
        }

    }
    
    func shotUpperView(shot: Int, hit: Bool) {
        let button = upperView.viewWithTag(shot) as! UIButton
        print(button.frame.origin)
        if hit {
            createShotImage(addToView: upperView, button: button)
            button.backgroundColor = UIColor.red
        } else {
            button.backgroundColor = UIColor.yellow
        }
    }
    
    func createShotImage(addToView: UIView, button: UIButton){
        let x = button.frame.origin.x
        let y = button.frame.origin.y
        let height = button.frame.width / 2
        let width = button.frame.width / 2
        let image = UIImageView(image: UIImage(named: "explosion3"))
        image.frame = CGRect(x: x, y: y, width: width, height: height)
        image.center = CGPoint(x: x + width, y: y + height)
        addToView.addSubview(image)
    }
    
    func sendGameInfoToDatabase(){
        let database = Database.database().reference().child("chooseTurn")
        let sendDataArray = [["Sender": String(userId), "FirstTurn": String(firstTurn)], ["BoatPosition": databaseFriendlyPositions()]]
        database.childByAutoId().setValue(sendDataArray) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Gamedata sent succesfully!")
            }
        }
    }
    
    func sendToDatabase(tag: Int, hit: Int, youLost: Int){
        let database = Database.database().reference().child("SinkingShip")
        let dictionary = ["Sender": userId, "Shot": tag, "Hit": hit, "YouLost": youLost]
        database.child("ShotsAndHits").setValue(dictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Gamedata sent succesfully!")
            }
        }
    }
    
    @objc func clickedButton(sender: UIButton!){
        print("button clicked \(sender.tag)")
        
        if yourTurn {
            sender.isEnabled = false
            var youWon = 0
            let hit = checkIfHit(position: sender.tag, tileArray: opponentsBoatPositionsAsTileNrs)
            var hitNr = 0
            if hit {
                sender.backgroundColor = UIColor.red
                hitNr = 1
                checkIfShipSunken(shotShips: subtractIfHitOpponent(tileNr: sender.tag))
                if checkIfWon() {
                    youWon = 1
                }
            } else {
                sender.backgroundColor = UIColor.yellow
            }
            sendToDatabase(tag: sender.tag, hit: hitNr, youLost: youWon)
            if youWon == 1 {
                showPopUp(won: true)
            }
        }
    }
    
    func checkIfHit(position: Int, tileArray: [[Int]]) -> Bool {
        for boat in tileArray {
            for tileNr in boat {
                if tileNr == position {
                    yourTurn = true
                    return true
                }
            }
        }
        yourTurn = false
        showToast(text: "Opponents turn")
        return false
    }
    
    func subtractIfHitOpponent(tileNr: Int)-> [Int]{
        var shotShips: [Int] = []
        for i in 0..<opponentsBoatPositionsAsTileNrs.count {
            let boat = opponentsBoatPositionsAsTileNrs[i]
            for j in 0..<boat.count {
                if boat[j] == tileNr {
                    opponentsHitsLeftArray[i] = opponentsHitsLeftArray[i] - 1
                    shotShips.append(i)
                }
            }
        }
        return shotShips
    }
    
    func checkIfShipSunken(shotShips: [Int]){
        for index in shotShips{
            if opponentsHitsLeftArray[index] == 0 {
                let boatPos = opponentsBoatPositionArray[index]
                let boat = UIView(frame: calcPositionByTileSize(boatPosition: boatPos))
                boat.backgroundColor = UIColor.green
                lowerView.addSubview(boat)
                let boatTiles = opponentsBoatPositionsAsTileNrs[index]
                for tile in boatTiles {
                    let button = lowerView.viewWithTag(tile) as! UIButton
                    createShotImage(addToView: lowerView, button: button)
                }
            }
        }
    }
    
    func checkIfWon()-> Bool{
        var count = 0
        for i in opponentsHitsLeftArray{
            if i == 0 {
                count += 1
            }
        }
        if count == 5 {
            print("You won!")
            return true
        }
        return false
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
    
    func startFirstTurn(){
        var myNr: Int = -1
        var hisNr: Int = -1
        print(userId)
        print(informationArray)
        if informationArray.count < 2{
            print("Array have less then 2 values")
        } else {
            for chooseTurn in informationArray {
                if chooseTurn.sender == userId {
                  myNr = chooseTurn.number
                }else {
                  hisNr = chooseTurn.number
                }
            }
            print("MyNr = \(myNr) hisNr = \(hisNr)")
            if hisNr > myNr {
                yourTurn = false
                print("It is opponents turn")
                showToast(text: "Opponents turn")
            } else {
                yourTurn = true
                print("It is your turn")
                showToast(text: "Your turn")
            }
            myBoatPositionsAsTileNrs = calculateBoatsPositionsAsTileNr(boats: BoatPositions.getFromUserDefaults())
            opponentsBoatPositionsAsTileNrs
                = calculateBoatsPositionsAsTileNr(boats: opponentsBoatPositionArray)
        }
    }
    
    func databaseFriendlyPositions() -> [[String: Int]] {
        var arrayDictionaryPositions: [[String: Int]] = []
        let positionArray = BoatPositions.getFromUserDefaults()
        for boatPosition in positionArray {
            arrayDictionaryPositions.append([
                "row": Int(boatPosition.row),
                "column": Int(boatPosition.column),
                "height": Int(boatPosition.height),
                "width": Int(boatPosition.width)])
        }
        return arrayDictionaryPositions
    }
    
    func calculateBoatsPositionsAsTileNr(boats: [BoatPositions]) -> [[Int]]{
        var array: [Int] = []
        var boatTileNrArray: [[Int]] = []
        for boat in boats {
            let row = Int(boat.row * 10)
            let column = Int(boat.column + 1)
            var innerArray = [row + column]
            var addNr = 1
            var forNr = Int(boat.width)
            if boat.width < boat.height {
                addNr = 10
                forNr = Int(boat.height)
            }
            array.append(forNr)
            for i in 1..<forNr{
                let nr = row + column + i * addNr
                innerArray.append(nr)
                print("TileNr = \(nr)")
            }
            boatTileNrArray.append(innerArray)
        }
        opponentsHitsLeftArray = array
        return boatTileNrArray
    }
    
    func endGame(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func showToast(text: String){
        toastLabel.layer.zPosition = 10
        toastLabel.text = text
        UIView.animate(withDuration: 1, animations: {
            self.toastLabel.alpha = 1
        }) { (complete) in
            UIView.animate(withDuration: 1, animations: {
                self.toastLabel.alpha = 0
            })
        }
        toastLabel.layer.zPosition = -1
    }
    
    func showPopUp(won: Bool){
        var text = "You lost! :("
        if won {
            text = "You won!!!"
        }
        
        let popup = PopupDialog(title: text, message: nil)
        let button = CancelButton(title: "Main menu") {
            self.endGame()
        }
        popup.addButton(button)
        self.present(popup, animated: true, completion: nil)
    }
}

