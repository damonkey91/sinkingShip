//
//  ViewController.swift
//  Sinking ship simple
//
//  Created by lösen är 0000 on 2018-04-18.
//  Copyright © 2018 TobiasJohansson. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var upperButtonArray: [UIButton] = []
    var lowerButtonArray: [UIButton] = []
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    var yourTurn = false
    var firstTurn: Int = Int(arc4random_uniform(1000))
    var informationArray: [Information] = []
    let userId = Int(arc4random_uniform(5000))
    var opponentsBoatPositionArray: [BoatPositions] = []
    var myBoatPositionsAsTileNrs: [[Int]] = []
    var opponentsBoatPositionsAsTileNrs: [[Int]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                let hit = hitNr == 1
                self.yourTurn = !hit
                self.shotUpperView(shot: shot, hit: hit)
                //TODO: check if hit and its your turn if miss
            }
            //send sender, firstTurn number in one child.
            //send sender, yourTurn (true or false), shot (button tag), hit (true or false)
            
            //send boatpositions and firstTurn number in one child. save his boat positions
            //send hisTurn bool and the hits you made
            
            //sender, randomNr, yourTurn (true or false), shot (button tag), hit (true or false),
            //sender, randomNr, yourTurn(true or false), my boats, his boats
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
                //TODO: check if hit and its your turn if miss
            }
        }

    }
    
    func shotUpperView(shot: Int, hit: Bool) {
        let button = upperView.viewWithTag(shot) as! UIButton
        if hit {
            button.backgroundColor = UIColor.red
        } else {
            button.backgroundColor = UIColor.yellow
        }
    }
    
    func sendGameInfoToDatabase(){
        let database = Database.database().reference().child("chooseTurn")
        let sendDataArray = [["Sender": String(userId), "FirstTurn": String(firstTurn)], ["BoatPosition": databaseFriendlyPositions()]]
        //database.child("FirstGameInfo").setValue(sendDataArray)
        database.childByAutoId().setValue(sendDataArray) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Gamedata sent succesfully!")
            }
        //sender, boatposition, firstNr
        }
    }
    
    func sendToDatabase(tag: Int, hit: Int){
        let database = Database.database().reference().child("SinkingShip")
        let dictionary = ["Sender": userId, "Shot": tag, "Hit": hit]
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
            let hit = checkIfHit(position: sender.tag, tileArray: opponentsBoatPositionsAsTileNrs)
            var hitNr = 0
            if hit {
                sender.backgroundColor = UIColor.red
                hitNr = 1
            } else {
                sender.backgroundColor = UIColor.yellow
            }
            sendToDatabase(tag: sender.tag, hit: hitNr)
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
            } else {
                yourTurn = true
                print("It is your turn")
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
            for i in 1...forNr{
                let nr = row + column + i * addNr
                innerArray.append(nr)
                print("TileNr = \(nr)")
            }
            boatTileNrArray.append(innerArray)
        }
        return boatTileNrArray
    }
    
    
    //Den övre vyn ska dina skepp ritas ut och när ett blir träffat så ska det märkas upp
    //Den undre vyn ska du kunna skjuta på när det är din tur Skotten ska märkas ut och du får inte skjuta på samma ställe.
    //När ett helt skepp blivit nerskjutet ska det bli synligt
    //Få det att synas när ditt skepp träffas, nu färgas bara bakgrunden under ditt skepp
    //Radera data när en match är över ur databasen
    //Veta när man sänkt ett helt skepp
    //Veta när man har sänkt alla skepp
}

