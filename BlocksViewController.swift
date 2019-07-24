//  edit 6/18/19 by jacqueline
//  BlocksViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 5/9/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

//Comment

import UIKit
import AVFoundation

//test push comment


//collection of blocks that are part of the program
var functionsDict = [String : [Block]]()
var currentWorkspace = String()
let startIndex = 0
var endIndex: Int{
    return functionsDict[currentWorkspace]!.count - 1
}

//MARK: - Block Selection Delegate Protocol
protocol BlockSelectionDelegate{
    /*Used to send information to SelectedBlockViewController when moving blocks in workspace*/
    func setSelectedBlocks(_ blocks:[Block])
    func unsetBlocks()
    func setParentViewController(_ myVC:UIViewController)
}

class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BlockSelectionDelegate {
    
    
    
    // below are all the buttons for this class
    @IBOutlet weak var clearAll: UIButton!
    @IBOutlet weak var workspaceLabel: UILabel!
    
    @IBOutlet weak var blocksProgram: UICollectionView!
    //View on the bottom of the screen that shows blocks in worksapce
    @IBOutlet weak var playTrashToggleButton: UIButton!
    
    @IBOutlet weak var menuButton: UIButton!
    // above are all the buttons for this class
    
    
    
    
    var blocksBeingMoved = [Block]() /* List of blocks that are currently being moved (moving repeat and if blocks
     also move the blocks nested inside */
    var movingBlocks = false    //True if currently moving blocks in the workspace
    // used in moving as well as deleting, plural for for and if statements and nesting
    
    var containerViewController: UINavigationController? //Top-level controller for toolbox view controllers
    
    // FIXME: the blockWidth and blockHeight are not the same as the variable blockSize (= 100) - discuss
    var blockWidth = 150
    var blockHeight = 150
    let blockSpacing = 1
    
    var modifierBlockIndex: Int?
    var tappedModifierIndex: Int?

    
    // from Paul Hegarty, lectures 13 and 14
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /** This function saves each block in the superview as a json object cast as a String to a growing file. The function uses fileManager to be able to add and remove blocks from previous saves to stay up to date. **/
    
    func save(){
        let fileManager = FileManager.default
        //filename refers to the url found at "Blocks4AllSave.json"
        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        do{
            //Deletes previous save in order to rewrite for each save action (therefore, no excess blocks)
            try fileManager.removeItem(at: filename)
        }catch{
            print("couldn't delete save")
        }
        
        // string that json text is appended too
        var writeText = String()
        /** block represents each block belonging to the global array of blocks in the workspace. blocksStack holds all blocks on the screen. **/
        let funcNames = functionsDict.keys
        //gets all the function names in functionsDict as an array of strings
        
        for name in funcNames{
        // for all functions
            writeText.append("New Function \n")
            writeText.append(name)
            //adds name of function immediately after the new function and prior to the next object so that it can be parsed same way as blocks
            writeText.append("\n Next Object \n")
            // allows name to be handled in load at the same time as blocks
            for block in functionsDict[name]!{
                // for block in the current fuctionsDict function's array of blocks
                if let jsonText = block.jsonVar{
                    // sets jsonText to block.jsonVar which removes counterparts so it doesn't wind up with an infite amount of counterparts
                    writeText.append(String(data: jsonText, encoding: .utf8)!)
                    //adds the jsonText as .utf8 as a string to the writeText string
                    writeText.append("\n Next Object \n")
                    //marks next object
                }
                do{
                    try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    // writes the accumlated string of json objects to a single file
                }catch{
                    print("couldn't create json for", block)
                }
            }
        }
        
    }

    // MARK: - - View Set Up
    // MARK: - viewDidLoad
    
    // viewDidLoad = on appear
    override func viewDidLoad() {
        super.viewDidLoad()
        workspaceLabel.text = currentWorkspace
        self.navigationController?.isNavigationBarHidden = true
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        if workspaceLabel.text != "Main Workspace" && functionsDict[currentWorkspace]!.isEmpty{
            let startBlock = Block.init(name: "Function Start", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#058900")), double: true, tripleCounterpart: false)
            let endBlock = Block.init(name: "Function End", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#058900")), double: true, tripleCounterpart: false)
            startBlock!.counterpart = [endBlock!]
            endBlock!.counterpart = [startBlock!]
            functionsDict[currentWorkspace]?.append(startBlock!)
            functionsDict[currentWorkspace]?.append(endBlock!)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
////        if workspaceLabel.text != "Main Workspace" && functionsDict[currentWorkspace]!.isEmpty{
////            let startBlock = Block.init(name: "Function Start", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#058900")), double: true, tripleCounterpart: false)
////            let endBlock = Block.init(name: "Function End", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#058900")), double: true, tripleCounterpart: false)
////            startBlock!.counterpart = [endBlock!]
////            endBlock!.counterpart = [startBlock!]
////            functionsDict[currentWorkspace]?.append(startBlock!)
////            functionsDict[currentWorkspace]?.append(endBlock!)
////        }
//        var keyExists = false
//        if workspaceLabel.text == "Main Workspace"{
//            for var i in 0..<functionsDict[currentWorkspace]!.count{
//                if functionsDict[currentWorkspace]![i].type == "Function"{
//                    var block = functionsDict[currentWorkspace]![i]
//                    for j in 0..<oldKey.count{
//                        if block.name == oldKey[j]{
//                            keyExists = true
//                            block.name = newKey[j]
//                        }
//                    }
//                    //                    if keyExists == false{
//                    //                        functionsDict[currentWorkspace]!.removeSubrange(i-1)
//                    //                         i -= 1
//                    //                    }
//                }
//
//            }
//        }
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - - Block Selection Delegate functions
    func unsetBlocks() {
        /*Called after Blocks have been placed in final destination, so unset everything*/
        movingBlocks = false
        blocksBeingMoved.removeAll()
        changePlayTrashButton() //Toggling the play/trash button
        save()
    }
    
    // MARK: add save function to function
    func setSelectedBlocks(_ blocks: [Block]) {
        /*Called when moving moving blocks*/
        movingBlocks = true
        blocksBeingMoved = blocks
        blocksProgram.reloadData()
        changePlayTrashButton()
        save()
    }
    
    //TODO: LAUREN, figure out what this code is for
    func setParentViewController(_ myVC: UIViewController) {
        containerViewController = myVC as? UINavigationController
    }
    
    /** Function removes all blocks from the blocksStack and program **/
    func clearAllBlocks(){
        if currentWorkspace == "Main Workspace"{
            functionsDict[currentWorkspace] = []
            blocksProgram.reloadData()
            save()
        }
        else{
            functionsDict[currentWorkspace]!.removeSubrange(1..<functionsDict[currentWorkspace]!.count-1)
            blocksProgram.reloadData()
            save()
        }
    }
    
    /** When a user clicks the 'Clear All' button, they receive an alert asking if they really want to
     delete all blocks or not. If yes, the screen is cleared. **/
    @IBAction func clearAll(_ sender: Any) {
        clearAll.accessibilityLabel = "Clear all"
        clearAll.accessibilityHint = "Clear all blocks on the screen"
        
        let alert = UIAlertController(title: "Do you want to clear all?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            let announcement = "All blocks cleared."
            self.clearAll.accessibilityLabel = announcement
            self.clearAllBlocks()}))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    /* Changes the play button back and forth from trash to play */
    func changePlayTrashButton(){
        if movingBlocks{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "Trashcan"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Place in Trash"
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        }else if stopIsOption{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Stop"
            playTrashToggleButton.accessibilityHint = "Stop your robot!"
        }else{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    var stopIsOption = false
    
    // run the actual program when the play button is clicked
    @IBAction func playButtonClicked(_ sender: Any) {
        //play
        print("in playButtonClicked")
        if(movingBlocks){
            trashClicked()
        }else if stopIsOption{
            stopClicked()
        }else{
            print("in play clicked")
            playClicked()
        }
    }
    
    override func programHasCompleted(){
        movingBlocks = false
        stopIsOption = false
        changePlayTrashButton()
    }

    // run the actual program when the trash button is clicked
    func trashClicked() {
        //trash
        let announcement = blocksBeingMoved[0].name + " placed in trash."
        playTrashToggleButton.accessibilityLabel = announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.containerViewController?.popViewController(animated: false)})
        print("put in trash")
        blocksProgram.reloadData()
        unsetBlocks()
    }
    
    func playClicked(){
        if(!connectedRobots()){
            //no robots
            let announcement = "Connect to the dash robot. "
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, NSLocalizedString(announcement, comment: ""))
            print("No robots")
            performSegue(withIdentifier: "AddRobotSegue", sender: nil)
            
        }else if(functionsDict[currentWorkspace]!.isEmpty){
            changePlayTrashButton()
            let announcement = "Your robot has nothing to do! Add some blocks to your workspace."
            playTrashToggleButton.accessibilityLabel = announcement
            
        }else{
            stopIsOption = true
            changePlayTrashButton()
            play(functionsDictToPlay: functionsDict)
            //calls RobotControllerViewController play function which
        }
    }
    
    func stopClicked(){
        print("in stop clicked")
        self.executingProgram = nil
        programHasCompleted()
    }
    
    // MARK: - Blocks Methods
    
    func addBlocks(_ blocks:[Block], at index:Int){
        /*Called after selecting a place to add a block to the workspace, makes accessibility announcements
         and place blocks in the blockProgram stack, etc...*/
        
        //change for beginning
        var announcement = ""
        if(index != 0){
            let myBlock = functionsDict[currentWorkspace]![index-1]
            announcement = blocks[0].name + " placed after " + myBlock.name
        }else{
            announcement = blocks[0].name + " placed at beginning"
        }
        delay(announcement, 2)
        
        //add a completion block here
        if(blocks[0].double) || (blocks[0].tripleCounterpart){
//            functionsDict[currentWorkspace]!.insert(contentsOf: blocks, at: index)
//            blocksBeingMoved.removeAll()
//            blocksProgram.reloadData()
            if currentWorkspace != "Main Workspace" && index > endIndex {
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }else if currentWorkspace != "Main Workspace" && index <= startIndex {
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }
            else{
            functionsDict[currentWorkspace]!.insert(contentsOf: blocks, at: index)
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
            }
        }
        else{
            if currentWorkspace != "Main Workspace" && index > endIndex {
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }else if currentWorkspace != "Main Workspace" && index <= startIndex {
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }
            else{
                functionsDict[currentWorkspace]!.insert(blocks[0], at: index)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()

            }
            }
    }
    
  
    func makeAnnouncement(_ announcement: String){
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
    }
    
    func delay(_ announcement: String, _ seconds: Int){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
            self.makeAnnouncement(announcement)
        })
    }
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        /*Given a list of blocks, creates the views that will be displayed in the blocksProgram*/
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        var count = 0
        for block in blocksRep{
            let xCoord = count*(blockWidth + blockSpacing)
            
            let blockView = BlockView(frame: CGRect(x: xCoord, y: 0, width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            count += 1
            
            myView.addSubview(blockView)
            
        }
        myView.alpha = 0.75
        return myView
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return functionsDict[currentWorkspace]!.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
        //        print(indexPath)
        if indexPath.row == functionsDict[currentWorkspace]!.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end
            // with VoiceOver on
            if functionsDict[currentWorkspace]!.count < 8 {
                // TODO: eventually simplify this section without blocksStack.count < 8
                // blocksStack.count < 8 means that the orignal editor only fit up to 8 blocks of a fixed size horizontally, but we may want to change that too
                let myWidth = collectionView.frame.width
                size = CGSize(width: myWidth, height: collectionView.frame.height)
            }else{
                size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
            }
        }
        return size
    }
    
    
    /* adds in label for voiceOver
     */
    func addAccessibilityLabel(myLabel: UIView, block:Block, number: Int, blocksToAdd: [Block], spatial: Bool, interface: Int){
        //TODO: if condition change accessibility label
        myLabel.isAccessibilityElement = true
        var accessibilityLabel = ""
        //is blocksStack.count always correct?
        let blockPlacementInfo = ". Workspace block " + String(number) + " of " + String(functionsDict[currentWorkspace]!.count)
        var accessibilityHint = ""
        var movementInfo = ". Double tap to move block."
        
        if(!blocksBeingMoved.isEmpty){
            //Moving blocks, so switch labels to indicated where blocks can be placed
            if(interface == 0){
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " before "
            }else{
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " after "
            }
            movementInfo = ". Double tap to add " + blocksBeingMoved[0].name + " block here"
            
            if(blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"){
                //if block being moved is a boolean or number, announces information about where it can and cannot go
                var acceptsNumbers = false
                var acceptsBooleans = false
                for type in block.acceptedTypes{
                    if type == "Boolean"{
                        acceptsBooleans = true
                    }
                    if type == "Number"{
                        acceptsNumbers = true
                    }
                }
                if acceptsNumbers && blocksBeingMoved[0].type == "Number"{
                    accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " as number of times "
                }else if acceptsBooleans && blocksBeingMoved[0].type == "Boolean"{
                    accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " as condition of "
                }else{
                    accessibilityLabel = "Cannot place in "
                    movementInfo = ""
                }
            }
        }
        
        if(interface == 1){
            movementInfo = ". tap and hold to move block."
        }
        
        accessibilityLabel +=  block.name + blockPlacementInfo
        accessibilityHint += movementInfo
        
        myLabel.accessibilityLabel = accessibilityLabel
        myLabel.accessibilityHint = accessibilityHint
    }
    
    /* CollectionView contains the actual collection of blocks (i.e. the program that is being created with the blocks)
     This method creates and returns the cell at a given index
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionReuseIdentifier = "BlockCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        cell.isAccessibilityElement = false
        if indexPath.row == functionsDict[currentWorkspace]!.count {
            // The last cell in the collectionView is an empty cell so you can place blocks at the end
            if !blocksBeingMoved.isEmpty{
                cell.isAccessibilityElement = true
                
                if functionsDict[currentWorkspace]!.count == 0 {
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at Beginning"
                }else{
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End"
                }
                if(blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"){
                    cell.accessibilityLabel = "Cannot place at end "
                }
            }
        }else{
            
            let startingHeight = Int(cell.frame.height)-blockHeight
            
            let block = functionsDict[currentWorkspace]![indexPath.row]
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times) and adds in "inside" repeat/if blocks
            for i in 0...indexPath.row {
                if functionsDict[currentWorkspace]![i].double{
                    if(!functionsDict[currentWorkspace]![i].name.contains("End")){
                        if(i != indexPath.row){
                            blocksToAdd.append(functionsDict[currentWorkspace]![i])
                        }
                    }else{
                        if !blocksToAdd.isEmpty{
                            blocksToAdd.removeLast()
                        }
                    }
                }
                else if functionsDict[currentWorkspace]![i].tripleCounterpart{
                    if (!functionsDict[currentWorkspace]![i].name.contains("If")){
                        print(("in if true"))
                        if(i != indexPath.row){
                            blocksToAdd.append(functionsDict[currentWorkspace]![i])
                        }
                    }else{
                    if !blocksToAdd.isEmpty{
                        blocksToAdd.removeLast()
                    }
                    }
                    if (!functionsDict[currentWorkspace]![i].name.contains("Else")){
                        if(i != indexPath.row){
                            blocksToAdd.append(functionsDict[currentWorkspace]![i])
                        }
                    }
                    else{
                        if !blocksToAdd.isEmpty{
                            blocksToAdd.removeLast()
                        }
                    }

                }
            }
            
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
                
                myView.accessibilityLabel = "Inside " + b.name
                myView.text = "Inside " + b.name
                
                cell.addSubview(myView)
                count += 1
            }
            
            let name = block.name
            //            print(name)
            switch name{
            case "If":
                if !block.tripleCounterpart{
                    if block.addedBlocks.isEmpty{
                        // Creates repeat button for modifier.
                        let initialBoolean = "false"
                        
                        let placeholderBlock = Block(name: "If Modifier", color: Color.init(uiColor:UIColor.lightGray), double: false, tripleCounterpart: false, type: "Boolean")
                        
                        block.addedBlocks.append(placeholderBlock!)
                        placeholderBlock?.addAttributes(key: "booleanSelected", value: "\(initialBoolean)")
                        
                        
                        let ifButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
    //                    let image = UIImage(named: "false_plchldr.pdf")

                        ifButton.tag = indexPath.row
                        switch block.addedBlocks[0].attributes["booleanSelected"]{
                        case "hear_voice":
                            let image = UIImage(named: "hear_voice.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        case "obstacle_sensed":
                            let image = UIImage(named: "sense_obstacle")
                            ifButton.setBackgroundImage(image, for: .normal)

                        default:
                            let image = UIImage(named: "false_plchldr.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        }
    //                    ifButton.setBackgroundImage(image, for: .normal)
                        ifButton.backgroundColor = .lightGray
                        ifButton.addTarget(self, action: #selector(ifModifier(sender:)), for: .touchUpInside)
                        
                        ifButton.accessibilityLabel = "Set Boolean Condition for If"
                        ifButton.isAccessibilityElement = true
                        
                        cell.addSubview(ifButton)
                    } else {
                        _ = block.addedBlocks[0]
                        let ifButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                        
    //                    let image = UIImage(named: "false_plchldr.pdf")
                        
                        ifButton.tag = indexPath.row
                        switch block.addedBlocks[0].attributes["booleanSelected"]{
                        case "hear_voice":
                            let image = UIImage(named: "hear_voice.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        case "obstacle_sensed":
                            let image = UIImage(named: "sense_obstacle")
                            ifButton.setBackgroundImage(image, for: .normal)
                            
                        default:
                            let image = UIImage(named: "false_plchldr.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        }
    //                    ifButton.setBackgroundImage(image, for: .normal)
                        ifButton.backgroundColor = .lightGray
                        
                        // TODO: replace block.addedBlocks[0] with placeholderBlock variable? Same for other modifiers.
                        

                        ifButton.addTarget(self, action: #selector(ifModifier(sender:)), for: .touchUpInside)
                        ifButton.accessibilityLabel = "Set Boolean Condition for If"
                        ifButton.isAccessibilityElement = true
                        
                        cell.addSubview(ifButton)
                    }
                }
                else{
                    block.imageName = "smallIf.pdf"
                    if block.addedBlocks.isEmpty{
                        // Creates repeat button for modifier.
                        let initialBoolean = "false"
                        
                        let placeholderBlock = Block(name: "If Modifier", color: Color.init(uiColor:UIColor.lightGray), double: false, tripleCounterpart: false, type: "Boolean")
                        
                        block.addedBlocks.append(placeholderBlock!)
                        placeholderBlock?.addAttributes(key: "booleanSelected", value: "\(initialBoolean)")
                        
                        
                        let ifButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                        //                    let image = UIImage(named: "false_plchldr.pdf")
                        
                        ifButton.tag = indexPath.row
                        switch block.addedBlocks[0].attributes["booleanSelected"]{
                        case "hear_voice":
                            let image = UIImage(named: "hear_voice.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        case "obstacle_sensed":
                            let image = UIImage(named: "sense_obstacle")
                            ifButton.setBackgroundImage(image, for: .normal)
                            
                        default:
                            let image = UIImage(named: "false_plchldr.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        }
                        //                    ifButton.setBackgroundImage(image, for: .normal)
                        ifButton.backgroundColor = .lightGray
                        ifButton.addTarget(self, action: #selector(ifModifier(sender:)), for: .touchUpInside)
                        
                        ifButton.accessibilityLabel = "Set Boolean Condition for If"
                        ifButton.isAccessibilityElement = true
                        
                        cell.addSubview(ifButton)
                    } else {
                        _ = block.addedBlocks[0]
                        let ifButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                        
                        //                    let image = UIImage(named: "false_plchldr.pdf")
                        
                        ifButton.tag = indexPath.row
                        switch block.addedBlocks[0].attributes["booleanSelected"]{
                        case "hear_voice":
                            let image = UIImage(named: "hear_voice.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        case "obstacle_sensed":
                            let image = UIImage(named: "sense_obstacle")
                            ifButton.setBackgroundImage(image, for: .normal)
                            
                        default:
                            let image = UIImage(named: "false_plchldr.pdf")
                            ifButton.setBackgroundImage(image, for: .normal)
                        }
                        //                    ifButton.setBackgroundImage(image, for: .normal)
                        ifButton.backgroundColor = .lightGray
                        
                        // TODO: replace block.addedBlocks[0] with placeholderBlock variable? Same for other modifiers.
                        
                        
                        ifButton.addTarget(self, action: #selector(ifModifier(sender:)), for: .touchUpInside)
                        ifButton.accessibilityLabel = "Set Boolean Condition for If"
                        ifButton.isAccessibilityElement = true
                        
                        cell.addSubview(ifButton)
                    }
                }
                
            case "Repeat":
                if block.addedBlocks.isEmpty{
                    // Creates repeat button for modifier.
                    let initialTimesToRepeat = 2
                   
                    let placeholderBlock = Block(name: "Repeat Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "timesToRepeat", value: "\(initialTimesToRepeat)")

                    
                    let repeatNumberButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    repeatNumberButton.tag = indexPath.row
                    repeatNumberButton.backgroundColor = #colorLiteral(red: 0.7019607843, green: 0.05098039216, blue: 0.7960784314, alpha: 1)
                    repeatNumberButton.setTitle("\(placeholderBlock?.attributes["timesToRepeat"] ?? "1")", for: .normal)
                    repeatNumberButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    repeatNumberButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    repeatNumberButton.titleLabel?.numberOfLines = 0
                    repeatNumberButton.titleLabel?.textAlignment = NSTextAlignment.left
                    repeatNumberButton.addTarget(self, action: #selector(repeatModifier(sender:)), for: .touchUpInside)
                    repeatNumberButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    repeatNumberButton.layer.borderWidth = 2.0
                    repeatNumberButton.layer.borderColor = UIColor.black.cgColor
                    
                    repeatNumberButton.accessibilityLabel = "Set number of times to repeat"
                    repeatNumberButton.isAccessibilityElement = true
                    
                    cell.addSubview(repeatNumberButton)
                } else {
                    _ = block.addedBlocks[0]
                    let repeatNumberButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    repeatNumberButton.tag = indexPath.row
                    repeatNumberButton.backgroundColor = #colorLiteral(red: 0.7019607843, green: 0.05098039216, blue: 0.7960784314, alpha: 1)
                    // TODO: replace block.addedBlocks[0] with placeholderBlock variable? Same for other modifiers.
                    repeatNumberButton.setTitle("\(block.addedBlocks[0].attributes["timesToRepeat"] ?? "1")", for: .normal)
                    repeatNumberButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    repeatNumberButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    repeatNumberButton.titleLabel?.numberOfLines = 0
                    repeatNumberButton.titleLabel?.textAlignment = NSTextAlignment.left
                    repeatNumberButton.addTarget(self, action: #selector(repeatModifier(sender:)), for: .touchUpInside)
                    repeatNumberButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    repeatNumberButton.layer.borderWidth = 2.0
                    repeatNumberButton.layer.borderColor = UIColor.black.cgColor
                    repeatNumberButton.accessibilityLabel = "Set number of times to repeat"
                    repeatNumberButton.isAccessibilityElement = true
                    
                    cell.addSubview(repeatNumberButton)
                }
                
            case "Repeat Forever":
                if block.addedBlocks.isEmpty{
                    _ = Block(name: "forever", color: Color.init(uiColor:UIColor.red ) , double: false, tripleCounterpart: false, type: "Boolean")
                }
                
            case "Drive Forward", "Drive Backward":
                if block.addedBlocks.isEmpty{
                    let initialDistance = 30
                    let initialSpeed = "Normal"
                    // Creates distance button for modifier.
                    // TODO: change the Distance and Speed values in the placeholderBlock name according to Dash API
                    
                    let placeholderBlock = Block(name: "Distance Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "distance", value: "\(initialDistance)")
                    placeholderBlock?.addAttributes(key: "speed", value: initialSpeed)
                    
                    
                    let distanceSpeedButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    distanceSpeedButton.tag = indexPath.row
                    distanceSpeedButton.backgroundColor = UIColor(displayP3Red: 177/255, green: 92/255, blue: 19/255, alpha: 1)
                    distanceSpeedButton.setTitle("\(placeholderBlock?.attributes["distance"] ?? "30") cm, \(placeholderBlock?.attributes["speed"] ?? "Normal")", for: .normal)
                    distanceSpeedButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 40)
                    distanceSpeedButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    distanceSpeedButton.titleLabel?.numberOfLines = 0
                    distanceSpeedButton.titleLabel?.textAlignment = NSTextAlignment.left
                    distanceSpeedButton.addTarget(self, action: #selector(distanceSpeedModifier(sender:)), for: .touchUpInside)
                    distanceSpeedButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    distanceSpeedButton.layer.borderWidth = 2.0
                    distanceSpeedButton.layer.borderColor = UIColor.black.cgColor
                    
                    distanceSpeedButton.accessibilityLabel = "Set distance and speed"
                    distanceSpeedButton.isAccessibilityElement = true
                    
                    cell.addSubview(distanceSpeedButton)
                } else {
                    _ = block.addedBlocks[0]
                    let distanceSpeedButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    distanceSpeedButton.tag = indexPath.row
                    distanceSpeedButton.backgroundColor = UIColor(displayP3Red: 177/255, green: 92/255, blue: 19/255, alpha: 1)
                    distanceSpeedButton.setTitle("\(block.addedBlocks[0].attributes["distance"]!) cm, \(block.addedBlocks[0].attributes["speed"]!)", for: .normal)
                    distanceSpeedButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 40)
                    distanceSpeedButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    distanceSpeedButton.titleLabel?.numberOfLines = 0
                    distanceSpeedButton.titleLabel?.textAlignment = NSTextAlignment.left
                    distanceSpeedButton.addTarget(self, action: #selector(distanceSpeedModifier(sender:)), for: .touchUpInside)
                    distanceSpeedButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    distanceSpeedButton.layer.borderWidth = 2.0
                    distanceSpeedButton.layer.borderColor = UIColor.black.cgColor
                    distanceSpeedButton.accessibilityLabel = "Set distance and speed"
                    distanceSpeedButton.isAccessibilityElement = true
                    
                    cell.addSubview(distanceSpeedButton)
                }
                
            case "Turn Left", "Turn Right":
                if block.addedBlocks.isEmpty{
                    //Creates angle button for modifier
                    let initialAngle = 90
                    
                    let placeholderBlock = Block(name: "Distance Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "angle", value: "\(initialAngle)")
                    
                    
                    let angleButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    angleButton.tag = indexPath.row
                    angleButton.backgroundColor = UIColor(displayP3Red: 177/255, green: 92/255, blue: 19/255, alpha: 1)
                    angleButton.setTitle("\(placeholderBlock?.attributes["angle"] ?? "90")", for: .normal)
                    angleButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    angleButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    angleButton.titleLabel?.numberOfLines = 0
                    angleButton.titleLabel?.textAlignment = NSTextAlignment.left
                    angleButton.addTarget(self, action: #selector(angleModifier(sender:)), for: .touchUpInside)
                    angleButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    angleButton.layer.borderWidth = 2.0
                    angleButton.layer.borderColor = UIColor.black.cgColor
                    angleButton.accessibilityLabel = "Set turn angle"
                    angleButton.isAccessibilityElement = true
                    
                    cell.addSubview(angleButton)
                } else {
                    _ = block.addedBlocks[0]
                    let angleButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    angleButton.tag = indexPath.row
                    angleButton.backgroundColor = UIColor(displayP3Red: 177/255, green: 92/255, blue: 19/255, alpha: 1)
                    angleButton.setTitle("\(block.addedBlocks[0].attributes["angle"]!)", for: .normal)
                    angleButton.addTarget(self, action: #selector(angleModifier(sender:)), for: .touchUpInside)
                    angleButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    angleButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    angleButton.titleLabel?.numberOfLines = 0
                    angleButton.titleLabel?.textAlignment = NSTextAlignment.left
                    angleButton.layer.borderWidth = 2.0
                    angleButton.layer.borderColor = UIColor.black.cgColor
                    angleButton.accessibilityLabel = "Set turn angle"
                    angleButton.isAccessibilityElement = true
                    
                    cell.addSubview(angleButton)
                }
                
            case "Set Left Ear Light", "Set Right Ear Light", "Set Chest Light", "Set All Lights":
                if block.addedBlocks.isEmpty{
                    // Creates button to allow light color change.
                    // MARK: Blockly default color is purple
                    let initialColor = "purple"
                    
                    let placeholderBlock = Block(name: "Light Color Modifier", color: Color.init(uiColor:UIColor.purple) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    placeholderBlock?.addAttributes(key: "lightColor", value: initialColor)
                    // MARK: modifier block color changes to what was selected
                    placeholderBlock?.addAttributes(key: "modifierBlockColor", value: initialColor)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "lightColor", value: "\(initialColor)")
                    

                    let lightColorButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    lightColorButton.tag = indexPath.row
                    lightColorButton.backgroundColor = UIColor(displayP3Red: 0.58188, green: 0.2157, blue: 1, alpha: 1) // default color
                    lightColorButton.addTarget(self, action: #selector(lightColorModifier(sender:)), for: .touchUpInside)
                    lightColorButton.layer.borderWidth = 2.0
                    lightColorButton.layer.borderColor = UIColor.black.cgColor
                    
                    lightColorButton.accessibilityLabel = "Set light color"
                    lightColorButton.isAccessibilityElement = true
                    
                    cell.addSubview(lightColorButton)
                } else {
                    _ = block.addedBlocks[0]
                    let lightColorButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    var modifierBlockColor: UIColor = changeModifierBlockColor(color: block.addedBlocks[0].attributes["modifierBlockColor"]!)
                    
                    lightColorButton.tag = indexPath.row
                    lightColorButton.backgroundColor = modifierBlockColor
                    
                    lightColorButton.addTarget(self, action: #selector(lightColorModifier(sender:)), for: .touchUpInside)
                    if (modifierBlockColor == UIColor.yellow || modifierBlockColor == UIColor.green || modifierBlockColor == UIColor.white) {
                        lightColorButton.setTitleColor(.black, for: .normal)
                    }
                    lightColorButton.layer.borderWidth = 2.0
                    lightColorButton.layer.borderColor = UIColor.black.cgColor
                    lightColorButton.accessibilityLabel = "Set light color"
                    lightColorButton.isAccessibilityElement = true
                    
                    cell.addSubview(lightColorButton)
                }
                
            case "Set Eye Light":
                if block.addedBlocks.isEmpty{
                    let initialEyeLightStatus = "Off"
                    let placeholderBlock = Block(name: "Eye Light Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "eyeLight", value: "\(initialEyeLightStatus)")
                    
                    let eyeLightButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))

                    
                    eyeLightButton.tag = indexPath.row
                    eyeLightButton.backgroundColor = UIColor(displayP3Red: 100/255, green: 4/255, blue: 195/255, alpha: 1)
                    eyeLightButton.setTitle("\(block.addedBlocks[0].attributes["eyeLight"]!)", for: .normal)
                    eyeLightButton.addTarget(self, action: #selector(setEyeLightModifier(sender:)), for: .touchUpInside)
                    eyeLightButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    eyeLightButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    eyeLightButton.titleLabel?.numberOfLines = 0
                    eyeLightButton.titleLabel?.textAlignment = NSTextAlignment.left
                    eyeLightButton.layer.borderWidth = 2.0
                    eyeLightButton.layer.borderColor = UIColor.black.cgColor
                    
                    eyeLightButton.accessibilityLabel = "Turn eye light on and off"
                    eyeLightButton.isAccessibilityElement = true
                    
                    cell.addSubview(eyeLightButton)
                } else {
                    _ = block.addedBlocks[0]
                    let eyeLightButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    modifierBlockIndex = indexPath.row
                    
                    eyeLightButton.tag = indexPath.row
                    eyeLightButton.backgroundColor = UIColor(displayP3Red: 100/255, green: 4/255, blue: 195/255, alpha: 1)
                    eyeLightButton.setTitle("\(block.addedBlocks[0].attributes["eyeLight"]!)", for: .normal)
                    eyeLightButton.addTarget(self, action: #selector(setEyeLightModifier(sender:)), for: .touchUpInside)
                    eyeLightButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 60)
                    eyeLightButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    eyeLightButton.titleLabel?.numberOfLines = 0
                    eyeLightButton.titleLabel?.textAlignment = NSTextAlignment.left
                    eyeLightButton.layer.borderWidth = 2.0
                    eyeLightButton.layer.borderColor = UIColor.black.cgColor
                    eyeLightButton.accessibilityLabel = "Turn eye light on and off"
                    eyeLightButton.isAccessibilityElement = true
                    
                    cell.addSubview(eyeLightButton)
                }
            
            case "Wait for Time":
                if block.addedBlocks.isEmpty{
                    let initialWait = 1
                    let placeholderBlock = Block(name: "Wait Time", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "wait", value: "\(initialWait)")

                    
                    let waitTimeButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    waitTimeButton.tag = indexPath.row
                    waitTimeButton.backgroundColor = UIColor(displayP3Red: 179/255, green: 12/255, blue: 203/255, alpha: 1)
                    waitTimeButton.setTitle("\(placeholderBlock?.attributes["wait"] ?? "1") second", for: .normal)
                    waitTimeButton.addTarget(self, action: #selector(waitModifier(sender:)), for: .touchUpInside)
                    waitTimeButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    waitTimeButton.titleLabel?.font = UIFont (name:"Helvetica Neue", size: 36)
                    waitTimeButton.titleLabel?.numberOfLines = 0
                    waitTimeButton.titleLabel?.textAlignment = NSTextAlignment.center
                    waitTimeButton.layer.borderWidth = 2.0
                    waitTimeButton.layer.borderColor = UIColor.black.cgColor
                    
                    waitTimeButton.accessibilityLabel = "Set Wait Time"
                    waitTimeButton.isAccessibilityElement = true
                    
                    cell.addSubview(waitTimeButton)
                } else {
                    _ = block.addedBlocks[0]
                    let waitTimeButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    waitTimeButton.tag = indexPath.row
                    waitTimeButton.backgroundColor = UIColor(displayP3Red: 179/255, green: 12/255, blue: 203/255, alpha: 1)
                    if (block.addedBlocks[0].attributes["wait"] == "1"){
                        waitTimeButton.setTitle("\(block.addedBlocks[0].attributes["wait"]!) second", for: .normal)
                    } else{
                        waitTimeButton.setTitle("\(block.addedBlocks[0].attributes["wait"]!) seconds", for: .normal)
                    }
                    waitTimeButton.addTarget(self, action: #selector(waitModifier(sender:)), for: .touchUpInside)
                    waitTimeButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    waitTimeButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 36)
                    waitTimeButton.titleLabel?.numberOfLines = 0
                    waitTimeButton.titleLabel?.textAlignment = NSTextAlignment.center
                    waitTimeButton.layer.borderWidth = 2.0
                    waitTimeButton.layer.borderColor = UIColor.black.cgColor
                    
                    waitTimeButton.accessibilityLabel = "Set wait time"
                    waitTimeButton.isAccessibilityElement = true
                    
                    cell.addSubview(waitTimeButton)
                }
            
            case "Set Variable":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    let initialVariableValue = 0

                    let placeholderBlock = Block(name: "Set Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    placeholderBlock?.addAttributes(key: "variableValue", value: "\(initialVariableValue)")
                    
                    
                    let setVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setVariableButton.tag = indexPath.row
                    setVariableButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    setVariableButton.setTitle(" \(placeholderBlock?.attributes["variableSelected"] ?? "Orange") \n = \(placeholderBlock?.attributes["variableValue"] ?? "0")", for: .normal)
                    setVariableButton.addTarget(self, action: #selector(variableModifier(sender:)), for: .touchUpInside)
                    setVariableButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    setVariableButton.titleLabel?.font = UIFont (name:"Helvetica Neue", size: 30)
                    setVariableButton.titleLabel?.numberOfLines = 0
                    setVariableButton.titleLabel?.textAlignment = NSTextAlignment.left
                    setVariableButton.layer.borderWidth = 2.0
                    setVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setVariableButton.accessibilityLabel = "Set Variable Value"
                    setVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setVariableButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setVariableButton.tag = indexPath.row
                    setVariableButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    setVariableButton.setTitle(" \(block.addedBlocks[0].attributes["variableSelected"]!) \n = \(block.addedBlocks[0].attributes["variableValue"]!)", for: .normal)
                    setVariableButton.addTarget(self, action: #selector(variableModifier(sender:)), for: .touchUpInside)
                    setVariableButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    setVariableButton.titleLabel?.font = UIFont (name: "Helvetica Neue", size: 30)
                    setVariableButton.titleLabel?.numberOfLines = 0
                    setVariableButton.titleLabel?.textAlignment = NSTextAlignment.left
                    setVariableButton.layer.borderWidth = 2.0
                    setVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setVariableButton.accessibilityLabel = "Set variable value"
                    setVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setVariableButton)
                }
                
            case "Drive":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Drive Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                    
                    let setDriveVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width:  blockWidth, height: blockHeight))
                    
                    setDriveVariableButton.tag = indexPath.row
                    
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setDriveVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    
                    setDriveVariableButton.addTarget(self, action: #selector(driveModifier(sender:)), for: .touchUpInside)
                    setDriveVariableButton.layer.borderWidth = 2.0
                    setDriveVariableButton.layer.borderColor = UIColor.black.cgColor
                
                    
                    cell.addSubview(setDriveVariableButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setDriveVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                          setDriveVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    setDriveVariableButton.tag = indexPath.row
                    
                    setDriveVariableButton.addTarget(self, action: #selector(driveModifier(sender:)), for: .touchUpInside)
                    
                    setDriveVariableButton.layer.borderWidth = 2.0
                    setDriveVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    cell.addSubview(setDriveVariableButton)
                }
                
            case "Look Up or Down":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Look Left or Right Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                    
                    let setLookUpDownVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setLookUpDownVariableButton.tag = indexPath.row
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setLookUpDownVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    setLookUpDownVariableButton.addTarget(self, action: #selector(lookUpDownModifier(sender:)), for: .touchUpInside)
                    setLookUpDownVariableButton.layer.borderWidth = 2.0
                    setLookUpDownVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setLookUpDownVariableButton.accessibilityLabel = "Set Look Left or Right Variable"
                    setLookUpDownVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setLookUpDownVariableButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setLookUpDownVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setLookUpDownVariableButton.tag = indexPath.row
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setLookUpDownVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                   
                    setLookUpDownVariableButton.addTarget(self, action: #selector(lookUpDownModifier(sender:)), for: .touchUpInside)
                    setLookUpDownVariableButton.layer.borderWidth = 2.0
                    setLookUpDownVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setLookUpDownVariableButton.accessibilityLabel = "Set Look Left or Right Variable"
                    setLookUpDownVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setLookUpDownVariableButton)
                }
                
            case "Look Left or Right":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Look Left or Right Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                    
                    let setLookLeftRightVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setLookLeftRightVariableButton.tag = indexPath.row
                    
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setLookLeftRightVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    setLookLeftRightVariableButton.addTarget(self, action: #selector(lookLeftRightModifier(sender:)), for: .touchUpInside)
                    setLookLeftRightVariableButton.layer.borderWidth = 2.0
                    setLookLeftRightVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setLookLeftRightVariableButton.accessibilityLabel = "Set Look Left or Right Variable"
                    setLookLeftRightVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setLookLeftRightVariableButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setLookLeftRightVariableButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setLookLeftRightVariableButton.tag = indexPath.row
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setLookLeftRightVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    setLookLeftRightVariableButton.addTarget(self, action: #selector(lookLeftRightModifier(sender:)), for: .touchUpInside)
                    setLookLeftRightVariableButton.layer.borderWidth = 2.0
                    setLookLeftRightVariableButton.layer.borderColor = UIColor.black.cgColor
                    
                    setLookLeftRightVariableButton.accessibilityLabel = "Set Look Left or Right Variable"
                    setLookLeftRightVariableButton.isAccessibilityElement = true
                    
                    cell.addSubview(setLookLeftRightVariableButton)
                }
                
            case "Wheel Speed":
                
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Wheel Speed Variables", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    placeholderBlock?.addAttributes(key: "variableSelectedTwo", value: "\(initialVariable)")
                    
                    
                    let setWheelSpeedButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: 2 * blockWidth/3, height: blockHeight/2))
                    
                    let setWheelSpeedButtonTwo = UIButton(frame: CGRect(x: blockWidth/3, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing) + blockHeight/2, width: 2 * blockWidth/3 , height: blockHeight/2))
                    
                    let setBackgroundButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    let setBorderButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setBackgroundButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    setBorderButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 0)
                    
                    setWheelSpeedButton.tag = indexPath.row
                    setWheelSpeedButtonTwo.tag = indexPath.row
                    setBorderButton.tag = indexPath.row
                    
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setWheelSpeedButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    switch block.addedBlocks[0].attributes["variableSelectedTwo"]{
                    case "orange":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setWheelSpeedButtonTwo.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
//                    setWheelSpeedButton.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
//                    setWheelSpeedButtonTwo.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
                    setBorderButton.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
                    
                    setBorderButton.accessibilityLabel = "Set Wheel Variables"
                    setBorderButton.isAccessibilityElement = true
                    
                    
                    setBorderButton.layer.borderWidth = 2.0
                    setBorderButton.layer.borderColor = UIColor.black.cgColor
                    
                    cell.addSubview(setBackgroundButton)
                    cell.addSubview(setWheelSpeedButton)
                    cell.addSubview(setWheelSpeedButtonTwo)
                    cell.addSubview(setBorderButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setWheelSpeedButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: 2 * blockWidth/3, height: blockHeight/2))
                    
                    let setWheelSpeedButtonTwo = UIButton(frame: CGRect(x: blockWidth/3, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing) + blockHeight/2, width: 2 * blockWidth/3 , height: blockHeight/2))
                    
                    let setBackgroundButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    let setBorderButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setBackgroundButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    setBorderButton.backgroundColor = #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 0)
                    
                    setWheelSpeedButton.tag = indexPath.row
                    setWheelSpeedButtonTwo.tag = indexPath.row
                    setBorderButton.tag = indexPath.row
                    
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setWheelSpeedButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setWheelSpeedButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    switch block.addedBlocks[0].attributes["variableSelectedTwo"]{
                    case "orange":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                    case "cherry":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                    case "banana":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                    case "melon":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                    case "apple":
                        setWheelSpeedButtonTwo.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                    default:
                        setWheelSpeedButtonTwo.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
//                    setWheelSpeedButton.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
//                    setWheelSpeedButtonTwo.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
                    setBorderButton.addTarget(self, action: #selector(wheelModifier(sender:)), for: .touchUpInside)
                    
                    setBorderButton.accessibilityLabel = "Set Wheel Variables"
                    setBorderButton.isAccessibilityElement = true
                    
                    
                    setBorderButton.layer.borderWidth = 2.0
                    setBorderButton.layer.borderColor = UIColor.black.cgColor
                    
                    cell.addSubview(setBackgroundButton)
                    cell.addSubview(setWheelSpeedButton)
                    cell.addSubview(setWheelSpeedButtonTwo)
                    cell.addSubview(setBorderButton)

            }
                
            case "Turn":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Choose Turn Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, tripleCounterpart: false, type: "Boolean")
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                   placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                    
                    let setTurnButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setTurnButton.tag = indexPath.row
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        let image = UIImage(named: "Orange.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "cherry":
                        let image = UIImage(named: "Cherry.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "banana":
                        let image = UIImage(named: "Banana.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "melon":
                        let image = UIImage(named: "Watermelon.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "apple":
                        let image = UIImage(named: "Apple.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    default:
                        setTurnButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    
                    setTurnButton.addTarget(self, action: #selector(turnModifier(sender:)), for: .touchUpInside)
                    setTurnButton.layer.borderWidth = 2.0
                    setTurnButton.layer.borderColor = UIColor.black.cgColor
                    
                    setTurnButton.accessibilityLabel = "Choose turn variable"
                    setTurnButton.isAccessibilityElement = true
                    
                    cell.addSubview(setTurnButton)
                } else {
                    _ = block.addedBlocks[0]
                    let setTurnButton = UIButton(frame: CGRect(x: 0, y:startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                    
                    setTurnButton.tag = indexPath.row
                    switch block.addedBlocks[0].attributes["variableSelected"]{
                    case "orange":
                        let image = UIImage(named: "Orange.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "cherry":
                        let image = UIImage(named: "Cherry.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "banana":
                        let image = UIImage(named: "Banana.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "melon":
                        let image = UIImage(named: "Watermelon.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    case "apple":
                        let image = UIImage(named: "Apple.pdf")
                        setTurnButton.setBackgroundImage(image, for: .normal)
                    default:
                        setTurnButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                    }
                    setTurnButton.addTarget(self, action: #selector(turnModifier(sender:)), for: .touchUpInside)
                    setTurnButton.layer.borderWidth = 2.0
                    setTurnButton.layer.borderColor = UIColor.black.cgColor
                    
                    setTurnButton.accessibilityLabel = "Choose Turn Variable"
                    setTurnButton.isAccessibilityElement = true
                    
                    cell.addSubview(setTurnButton)
                }
                
            default:
                print("This block does not need a modifier.")
            }
            
            //add main label
            
            let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            addAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row+1, blocksToAdd: blocksToAdd, spatial: true, interface: 0)
            cell.addSubview(myLabel)
        }
        cell.accessibilityElements = cell.accessibilityElements?.reversed()
//        save()
// think this save is extra
        return cell
    }
    
    @objc func distanceSpeedModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "DistanceSpeedModifier", sender: nil)
    }
    
    @objc  func waitModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "WaitModifier", sender: nil)
    }
    
    @objc func angleModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "TurnRightModifier", sender: nil)
    }
    
    @objc func lightColorModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "ColorModifier", sender: nil)
    }
    
    @objc func setEyeLightModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "EyeLightModifier", sender: nil)
    }
    
    @objc func repeatModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "RepeatModifier", sender: nil)
    }
    
    @objc func variableModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "VariableModifier", sender: nil)
    }
    
    @objc func ifModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "IfModifier", sender: nil)
    }
    
    @objc func turnModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "turnModifier", sender: nil)
    }
    
    @objc func lookUpDownModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "lookUpDownModifier", sender: nil)
    }
    
    @objc func lookLeftRightModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "lookLeftRightModifier", sender: nil)
    }
    
    @objc func driveModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "driveModifier", sender: nil)
    }
    
    @objc func wheelModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "wheelModifier", sender: nil)
    }
    
    @objc func buttonClicked(sender: UIButton!){
        print ("Button clicked")
    }
    
    func changeModifierBlockColor(color: String) -> UIColor {
        // test with black
        if color.elementsEqual("black"){
            return UIColor.black
        }
        if color.elementsEqual("red"){
            return UIColor.red
        }
        if color.elementsEqual("orange"){
            return UIColor.orange
        }
        if color.elementsEqual("yellow"){
            return UIColor.yellow
        }
        if color.elementsEqual("green"){
            return UIColor.green
        }
        if color.elementsEqual("blue"){
            // RGB values from Storyboard source code
            return UIColor(displayP3Red: 0, green: 0.5898, blue: 1, alpha: 1)
        }
        if color.elementsEqual("purple"){
            return UIColor(displayP3Red: 0.58188, green: 0.2157, blue: 1, alpha: 1)
        }
        if color.elementsEqual("white"){
            return UIColor.white
        }
        return UIColor.purple // default color
    }
    
    func createBlock(_ block: Block, withFrame frame:CGRect)->UILabel{
        let myLabel = UILabel.init(frame: frame)
        //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = block.color.uiColor
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color.uiColor
        return myLabel
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*Called when a block is selected in the collectionView, so either selects block to move or places blocks*/
        if(movingBlocks){
            if blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"{
                //TODO: can only be added above conditional
                var acceptsBooleans = false
                var acceptsNumbers = false
                if(indexPath.row < functionsDict[currentWorkspace]!.count){//otherwise empty block at end
                    let myBlock = functionsDict[currentWorkspace]![indexPath.row]
                    for type in myBlock.acceptedTypes{
                        if type == "Boolean"{
                            acceptsBooleans = true
                        }
                        if type == "Number"{
                            acceptsNumbers = true
                        }
                    }
                    if blocksBeingMoved[0].type == "Boolean" && acceptsBooleans{
                        //add it here
                        myBlock.addedBlocks.removeAll()
                        myBlock.addedBlocks.append(blocksBeingMoved[0])
                        containerViewController?.popViewController(animated: false)
                        let condition = myBlock.addedBlocks[0].name
                        let announcement = condition + "placed in if statement"
                        delay(announcement, 2)
                        blocksProgram.reloadData()
                        unsetBlocks()
                    }else if blocksBeingMoved[0].type == "Number" && acceptsNumbers{
                        //add it here
                        myBlock.addedBlocks.removeAll()
                        myBlock.addedBlocks.append(blocksBeingMoved[0])
                        containerViewController?.popViewController(animated: false)
                        let condition = myBlock.addedBlocks[0].name
                        let announcement = condition + "placed in repeat statement"
                        delay(announcement, 2)
                        blocksProgram.reloadData()
                        unsetBlocks()
                    }else{
                        //say you can't add it here
                        print("you can't add it here")
                        delay("you can't add it here", 2)
                        
                    }
                }else{
                    //say you can't add it here
                    print("you can't add it here")
                    delay("you can't add it here", 2)
                }
            }else{
                addBlocks(blocksBeingMoved, at: indexPath.row)
                containerViewController?.popViewController(animated: false)
                unsetBlocks()
            }
        }else{
            if(indexPath.row < functionsDict[currentWorkspace]!.count){ //otherwise empty block at end
                movingBlocks = true
                let blocksStackIndex = indexPath.row
                let myBlock = functionsDict[currentWorkspace]![blocksStackIndex]
                guard !myBlock.name.contains("Function Start") else{
                    movingBlocks = false
                    return
                }
                guard !myBlock.name.contains("Function End") else{
                    movingBlocks = false
                    return
                }
                //remove block from collection and program
                if myBlock.tripleCounterpart == true{
                    var indexOfCounterPartBlocks = [Int]()
                    var blockCounterParts = [Block]()
                    if myBlock.name == "If" || myBlock.name ==  "Else" || myBlock.name ==  "End If Else"{
                        for block in myBlock.counterpart[0].counterpart{
                            blockCounterParts.append(block)
                        }
                    }
                    for i in 0..<functionsDict[currentWorkspace]!.count{
                        // goes through all the blocks in the current workspace
                        for blockInPart in blockCounterParts{
                            // block class is not equatable can't compare counterpart which is an arryay of blocks to another array, best we can do is block to block
                            // goes through each block in the counterparts of the conterpart
                            if functionsDict[currentWorkspace]![i].name == "If" || functionsDict[currentWorkspace]![i].name ==  "Else" || functionsDict[currentWorkspace]![i].name ==  "End If Else"{
                                //this if statement is so when you get the blocks inbetween an If and an Else or an Else and and End If Else we don't try and search for their counterpart in the following for loop because they don't have it, this also covers our back for a few other things
                                for block in functionsDict[currentWorkspace]![i].counterpart[0].counterpart{
                                    // for block that is being iterated over in the whole function block stack get that block's counter parts counterparts list and then for each block in that list do the following
                                    if blockInPart === block{
                                    // compares if the block in the initail myblock's counterpart list matches the blocks in the counterpart list of the current block being iterated over by the functions dict i for loop at the very top
                                        if indexOfCounterPartBlocks.count == 0{
                                            // for the first case append i to the index of counterpart blocks this allows us to later know where the End If else block is so we know what chuncks of blocks to move
                                            indexOfCounterPartBlocks.append(i)
//                                            print("matched: ", block.name, " and ", blockInPart.name, " at index of: ", i)
//                                            print("blockCounterParts: ", blockCounterParts, "\n counterparts in functionsDict[currentWorkspace]![i].counterpart[0].counterpart: ", functionsDict[currentWorkspace]![i].counterpart[0].counterpart)
                                        }else if indexOfCounterPartBlocks[indexOfCounterPartBlocks.count - 1] != i{
                                            //this is so we don't end up with triplicate in the indexOfCounterPartBlocks, since we can't compare the arrays of blocks we end up doing 9 comparisons for each of the three counterparts so this whole chunk requires 27 comparisions, we should change this when we have time to make the Block class equatable, otherwise swift doesn't play nice and you have to do this
                                            indexOfCounterPartBlocks.append(i)
//                                            print("matched: ", block.name, " and ", blockInPart.name, " at index of: ", i)
//                                            print("blockCounterParts: ", blockCounterParts, "\n counterparts in functionsDict[currentWorkspace]![i].counterpart[0].counterpart: ", functionsDict[currentWorkspace]![i].counterpart[0].counterpart)
                                        }
                                    }
                                }
                            }
                        }
                    }
//                    print("indexofCounterpart: ", indexOfCounterPartBlocks)
                    // below mirros the other double/counterpart style blocks
                    var indexPathArray = [IndexPath]()
                    var tempBlockStack = [Block]()
                    for i in min(indexOfCounterPartBlocks[0],blocksStackIndex)...max(indexOfCounterPartBlocks[indexOfCounterPartBlocks.count - 1], blocksStackIndex){
                        indexPathArray += [IndexPath.init(row: i, section: 0)]
                        tempBlockStack += [functionsDict[currentWorkspace]![i]]
                    }
                    blocksBeingMoved = tempBlockStack
                    functionsDict[currentWorkspace]!.removeSubrange(min(indexOfCounterPartBlocks[0],blocksStackIndex)...max(indexOfCounterPartBlocks[indexOfCounterPartBlocks.count - 1], blocksStackIndex))
                    
                }
                else if myBlock.double == true{
                    var indexOfCounterpart = -1
                    var blockcounterparts = [Block]()
                    for i in 0..<functionsDict[currentWorkspace]!.count {
                        for block in myBlock.counterpart{
                            if block === functionsDict[currentWorkspace]![i]{
                                indexOfCounterpart = i
                                blockcounterparts.append(block)
                            }
                        }
                    }
                    var indexPathArray = [IndexPath]()
                    var tempBlockStack = [Block]()
                    for i in min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex){
                        indexPathArray += [IndexPath.init(row: i, section: 0)]
                        tempBlockStack += [functionsDict[currentWorkspace]![i]]
                    }
                    blocksBeingMoved = tempBlockStack
                    functionsDict[currentWorkspace]!.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
                }else{ //only a single block to be removed
                    blocksBeingMoved = [functionsDict[currentWorkspace]![blocksStackIndex]]
                    functionsDict[currentWorkspace]!.remove(at: blocksStackIndex)
                }
                blocksProgram.reloadData()
                let mySelectedBlockVC = SelectedBlockViewController()
                mySelectedBlockVC.blocks = blocksBeingMoved
                
                containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                changePlayTrashButton()
            }
        }
    }
    
    // MARK: - - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue to Toolbox
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksTypeTableViewController{
                myTopViewController.delegate = self
                myTopViewController.blockWidth = 150
            }
        }
        
        // Segue to DistanceSpeedModViewController
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to AngleModViewController
        if let destinationViewController = segue.destination as? AngleModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to ColorModViewController
        if let destinationViewController = segue.destination as? ColorModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to RepeatModViewController
        if let destinationViewController = segue.destination as? RepeatModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to WaitModViewController
        if let destinationViewController = segue.destination as? WaitModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to SetVariableModViewController
        if let destinationViewController = segue.destination as? SetVariableModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to IfModViewController
        if let destinationViewController = segue.destination as? IfModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to TurnVariable
        if let destinationViewController = segue.destination as? TurnVariable{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to LookLeftRightVariables
        if let destinationViewController = segue.destination as? LookLeftRightVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to LookUpDownVariables
        if let destinationViewController = segue.destination as? LookUpDownVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to DriveVariables
        if let destinationViewController = segue.destination as? DriveVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to WheelVariables
        if let destinationViewController = segue.destination as? WheelVariables{
          destinationViewController.modifierBlockIndexSender = modifierBlockIndex 
        }

        // Segue to EyeLightModifierViewController
        if let destinationViewController = segue.destination as? EyeLightModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
    }
}
