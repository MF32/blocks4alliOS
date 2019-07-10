//
//  WheelVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit


class WheelVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableSelectedTwo: String = "orange"
//    var variableValue: Int = 0
//    var variableValueTwo: Int = 0
    
    //left wheel buttons
    @IBOutlet weak var orangeWheelLButton: UIButton!
    @IBOutlet weak var bananaWheelLButton: UIButton!
    @IBOutlet weak var appleWheelLButton: UIButton!
    @IBOutlet weak var cherryWheelLButton: UIButton!
    @IBOutlet weak var watermelonWheelLButton: UIButton!
    
    //right wheel buttons
    @IBOutlet weak var orangeWheelRButton: UIButton!
    @IBOutlet weak var bananaWheelRButton: UIButton!
    @IBOutlet weak var appleWheelRButton: UIButton!
    @IBOutlet weak var cherryWheelRButton: UIButton!
    @IBOutlet weak var watermelonWheelRButton: UIButton!
    
    
    
    func deselectAllLeft(){
        orangeWheelLButton.layer.borderWidth = 0
        bananaWheelLButton.layer.borderWidth = 0
        cherryWheelLButton.layer.borderWidth = 0
        watermelonWheelLButton.layer.borderWidth = 0
        appleWheelLButton.layer.borderWidth = 0
    }
    
    func deselectAllRight(){
        orangeWheelRButton.layer.borderWidth = 0
        bananaWheelRButton.layer.borderWidth = 0
        cherryWheelRButton.layer.borderWidth = 0
        watermelonWheelRButton.layer.borderWidth = 0
        appleWheelRButton.layer.borderWidth = 0
    }
    
    //Reference for knowing which button is selected
    //https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    
    //when left wheel pressed
    @IBAction func orangeLeftPressed(_ sender: Any) {
        variableSelected = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
//                variableValue = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func bananaLeftPressed(_ sender: Any) {
        variableSelected = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
//                variableValue = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleLeftPressed(_ sender: Any) {
        variableSelected = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
//                variableValue = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryLeftPressed(_ sender: Any) {
        variableSelected = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
//                variableValue = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonLeftPressed(_ sender: Any) {
        variableSelected = "watermelon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
//                variableValue = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    
    //when right wheel pressed
    @IBAction func orangeRightPressed(_ sender: Any) {
        variableSelectedTwo = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
//                variableValueTwo = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func bananaRightPressed(_ sender: Any) {
        variableSelectedTwo = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
//                variableValueTwo = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleRightPressed(_ sender: Any) {
        variableSelectedTwo = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
//                variableValueTwo = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryRightPressed(_ sender: Any) {
        variableSelectedTwo = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
//                variableValueTwo = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func watermelonRightPressed(_ sender: Any) {
        variableSelectedTwo = "watermelon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
//                variableValueTwo = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
//            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Int(variableValue))"
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelectedTwo"] = variableSelectedTwo
//            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValueTwo"] = "\(Int(variableValueTwo))"
            
            
            
        }
    }
    
}


