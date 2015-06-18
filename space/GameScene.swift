//
//  GameScene.swift
//  space
//
//  Created by Nathan T Marder on 6/2/15.
//  Copyright (c) 2015 Nathan Marder. All rights reserved.
//

import SpriteKit
import AVFoundation

var torpedoMusicPlayer = AVAudioPlayer()
let torpedoURL:NSURL = NSBundle.mainBundle().URLForResource("torpedoFire", withExtension: "mp3")!
var buttonBox:CGRect = CGRect()

var straightLines:Bool = true
var angledLines:Bool = true
var multiAngledLines:Bool = true
var alienDifficulty = 1


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var lastYieldTimeInterval = NSTimeInterval()
    var lastUpdateTimeInterval = NSTimeInterval()
    var alienClock:Double = 0.0
    var aliensDestroyed:Int = 0
    var aliensThrough:Int = 0
    var alienKillGoal = 3
    var pause:SKSpriteNode = SKSpriteNode(imageNamed: "pause")
    
    //bit mask which identifies collisions: (expression 0x1 is multiplied by 1)
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    override func didMoveToView(view: SKView) {  }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPointMake(self.frame.size.width/2, player.size.height + 10)
        self.addChild(player)
        self.physicsWorld.gravity = CGVectorMake(0, 0)  // our world has zero gravity, it's space!
        self.physicsWorld.contactDelegate = self
        pause.position = CGPointMake(self.frame.size.width - pause.size.width,pause.size.height)
        self.addChild(pause)
        
        if currentLevel >= 3 {alienKillGoal = currentLevel}

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {

        /* Called before each frame is rendered */
        alienClock += (aliensPerFrame)
        if alienClock >= 1 {
            addAlien(currentLevel)
            alienClock = 0.0;
        }
    }
    
    
    
    func addAlien(difficulty: Int) {
        
//        var nextAlien = Alien1()
//        nextAlien.setDifficultyLevel(difficulty)
//        addChild(nextAlien)
//        nextAlien.runAction()
        
        var alien = SKSpriteNode(imageNamed: "alien")
        var actionArray:NSMutableArray = NSMutableArray()
        var initialXPosition = getRandomXPosition(alien)
        var initialYPosition:CGFloat = self.frame.size.height+alien.size.height
        var finalPosition:CGPoint
        var rangeDuration = maxDuration - minDuration
        var duration:Double = Double(arc4random()) % Double(rangeDuration) + Double(minDuration)
        
        
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        //println("Case: \(difficulty)")
        
        switch difficulty {
            
        case 1:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            finalPosition = CGPointMake(initialXPosition, -alien.size.height)
            actionArray.addObject(SKAction.moveTo(finalPosition, duration: duration))
            
        case 2:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            finalPosition = CGPointMake(getRandomXPosition(alien), -alien.size.height)
            actionArray.addObject(SKAction.moveTo(finalPosition, duration: duration))
            
            
        // one turn
        case 3:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var midPosition = CGPointMake(getRandomXPosition(alien), getRandomYPosition(alien))
            finalPosition = CGPointMake(getRandomXPosition(alien), -alien.size.height)
            var d1 = getDistance(alien.position, b: midPosition)
            var d2 = getDistance(midPosition, b: finalPosition)
            var totalDist = d1 + d2
            var d1Percent = Float(d1/totalDist)
            var d2Percent = Float(d2/totalDist)
            var dFloat = Float(duration)
            var d1Duration = Double(dFloat * d1Percent)
            var d2Duration = Double(dFloat * d2Percent)
            actionArray.addObject(SKAction.moveTo(midPosition, duration: d1Duration))
            actionArray.addObject(SKAction.moveTo(finalPosition, duration: d2Duration))
            
            
        // the bezier path
        case 4:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
            var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
            var midPosition1 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
            var midPosition2 = CGPointMake(alien.size.width/2, y2)
            var finalXPosition = getRandomXPosition(alien)
            finalPosition = CGPointMake(finalXPosition, -alien.size.height)
            var bezPath = UIBezierPath()
            bezPath.moveToPoint(alien.position)
            bezPath.addCurveToPoint(finalPosition, controlPoint1: midPosition1, controlPoint2: midPosition2)
            actionArray.addObject(SKAction.followPath(bezPath.CGPath, asOffset: false, orientToPath: false, duration: duration))
        
            
        case 5:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
            var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
            var midPosition1 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
            var midPosition2 = CGPointMake(alien.size.width/2, y2)
            var finalXPosition = getRandomXPosition(alien)
            finalPosition = CGPointMake(finalXPosition, -alien.size.height)
            var bezPath = UIBezierPath()
            bezPath.moveToPoint(alien.position)
            bezPath.addCurveToPoint(finalPosition, controlPoint1: midPosition1, controlPoint2: midPosition2)
            actionArray.addObject(SKAction.followPath(bezPath.CGPath, asOffset: false, orientToPath: false, duration: duration))
            
            
        case 6:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
            var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
            var ran = Int(arc4random()) % 9 + 1
            var midPosition1:CGPoint
            var midPosition2:CGPoint
            var finalPosition:CGPoint
            if (ran % 2 == 0) {
            
                midPosition1 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
                midPosition2 = CGPointMake(alien.size.width/2, y2)
                finalPosition = CGPointMake(self.frame.size.width/6, -alien.size.height)
            
            } else{
                midPosition2 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
                midPosition1 = CGPointMake(alien.size.width/2, y2)
                finalPosition = CGPointMake(self.frame.size.width - (self.frame.size.width/6), -alien.size.height)
            
            }
            
            var bezPath = UIBezierPath()
            bezPath.moveToPoint(alien.position)
            bezPath.addCurveToPoint(finalPosition, controlPoint1: midPosition1, controlPoint2: midPosition2)
            actionArray.addObject(SKAction.followPath(bezPath.CGPath, asOffset: false, orientToPath: false, duration: duration))
            
            
            
        case 7:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
            var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
            var x1 = getRandomXPosition(alien)
            var x2 = getRandomXPosition(alien)
            var midPosition1 = CGPointMake(x1, y1)
            var midPosition2 = CGPointMake(x2, y2)
            finalPosition = CGPointMake(x1, -alien.size.height)
            var d1 = getDistance(alien.position, b: midPosition1)
            var d2 = getDistance(midPosition1, b: midPosition2)
            var d3 = getDistance(midPosition2, b: finalPosition)
            var totalDist = d1 + d2 + d3
            var d1Percent = Float(d1/totalDist)
            var d2Percent = Float(d2/totalDist)
            var d3Percent = Float(d3/totalDist)
            var dFloat = Float(duration)
            var d1Duration = Double(dFloat * d1Percent)
            var d2Duration = Double(dFloat * d2Percent)
            var d3Duration = Double(dFloat * d3Percent)
            actionArray.addObject(SKAction.moveTo(midPosition1, duration: d1Duration))
            actionArray.addObject(SKAction.moveTo(midPosition2, duration: d2Duration))
            actionArray.addObject(SKAction.moveTo(finalPosition, duration: d3Duration))
            
            
        case 8:
            alien.position = CGPointMake(initialXPosition, initialYPosition)
            var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
            var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
            var ran = Int(arc4random()) % 9 + 1
            var midPosition1:CGPoint
            var midPosition2:CGPoint
            var finalPosition:CGPoint
            if (ran % 2 == 0) {
                
                midPosition1 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
                midPosition2 = CGPointMake(alien.size.width/2, y2)
                finalPosition = CGPointMake(self.frame.size.width/6, -alien.size.height)
                
            } else{
                midPosition2 = CGPointMake(self.frame.size.width-alien.size.width/2, y1)
                midPosition1 = CGPointMake(alien.size.width/2, y2)
                finalPosition = CGPointMake(self.frame.size.width - (self.frame.size.width/6), -alien.size.height)
                
            }
            
            var bezPath = UIBezierPath()
            bezPath.moveToPoint(alien.position)
            bezPath.addCurveToPoint(finalPosition, controlPoint1: midPosition1, controlPoint2: midPosition2)
            actionArray.addObject(SKAction.followPath(bezPath.CGPath, asOffset: false, orientToPath: true, duration: duration))

            
        default:
            var ran = getRandom(1, upper: 8)
            addAlien(ran)
            return
            
        }
        
        
        self.addChild(alien)
        
        
        
        // if the alien gets this far it means it made it across the whole screen
        actionArray.addObject(SKAction.runBlock({
            if ++self.aliensThrough >= 2{
                var transition = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(GameSceneNext(size: self.size, status:2), transition: transition)
            }
        }))
        
        actionArray.addObject(SKAction.removeFromParent())
        alien.runAction(SKAction.sequence(actionArray as [AnyObject]))

    }
    
    
    func getRandom (lower : Int , upper : Int) -> Int {
        let difference = upper - lower
        return Int(Float(rand())/Float(RAND_MAX) * Float(difference + 1)) + lower
    }
    
    
    
    
    
    /************************************************
    *************************************************
    **
    **  Handle Screen Touches
    **
    *************************************************
    *************************************************/
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch:UITouch = touches.first as! UITouch
        var location:CGPoint = touch.locationInNode(self)
        
        if (location.x >= self.frame.size.width - pause.size.width) &&
            (location.y <= pause.size.height)
        {
            self.view!.paused = !self.view!.paused
            if self.view!.paused == true {
                backgroundMusicPlayer.volume -= 0.9
            } else {
                backgroundMusicPlayer.volume += 0.9
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.view!.paused == true { return  }  // if it's paused do nothing...
        
        // get where to fire info
        var touch:UITouch = touches.first as! UITouch
        var location:CGPoint = touch.locationInNode(self)
        
        //create node for torpedo - each one is a sprite node
        var torpedo:SKSpriteNode = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = player.position //initial position of torpedo
        
        //create physics body and take care of collisions
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        
        //distance from torpedo to ship (use vector subtraction)
        var offSet:CGPoint = vecSub(location, b: torpedo.position)
        
        //since you can't fire backwards...
        if offSet.y < 0 { return  }
        
        // play the cool sound
        torpedoSound()
        self.addChild(torpedo)
        
        //get direction it shoots in, using normalization
        var direction:CGPoint = vecNormalize(offSet)
        
        //now we have to say how far it should go once fired. use vector multiplication
        var shotLength:CGPoint = vecMult(direction, factor: 1000) // 10000 is off the screen that's what matters
        
        //now we need final destination so we can animate the torpedo later
        var finalDestination:CGPoint = vecAdd(shotLength, b: torpedo.position)
        
        //we also need velocity and movementDuration for the torpedo
        let velocity = 568.0/1.0
        let moveDuration = Double(self.size.width) / velocity
        
        
        //now we need an action array which we can execute, it involves movements
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(finalDestination, duration: moveDuration as NSTimeInterval))
        actionArray.addObject(SKAction.removeFromParent())
        torpedo.runAction(SKAction.sequence(actionArray as [AnyObject]))

    }
    
    
    
    /************************************************
    *************************************************
    **
    **  Handle Collisions
    **
    *************************************************
    *************************************************/
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody:SKPhysicsBody = contact.bodyA
        var secondBody:SKPhysicsBody = contact.bodyB
        
        // make sure smaller one is torpedo
        if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask){
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Direct Hit! (torpedo vs. alien) uses bit-wise operations for speed
        if (firstBody.categoryBitMask & photonTorpedoCategory != 0) && (secondBody.categoryBitMask & alienCategory != 0 ){
            if let nodeA:SKSpriteNode = firstBody.node as? SKSpriteNode{
                if let nodeB:SKSpriteNode = secondBody.node as? SKSpriteNode{
                    nodeA.removeFromParent()
                    nodeB.removeFromParent()
                    if ++aliensDestroyed == alienKillGoal {
                        var t = SKTransition.flipHorizontalWithDuration(0.5)
                        self.view?.presentScene(GameSceneNext(size: self.size, status:1), transition: t)
                    }
                }
            } else {
                return
            }
        }
    }
    
    
    /************************************************
    *************************************************
    **
    **  Vector Math
    **
    *************************************************
    *************************************************/
    func vecAdd(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x+b.x, a.y+b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMult(a:CGPoint, factor:CGFloat)->CGPoint{
        return CGPointMake(a.x * factor, a.y * factor)
    }
    
    func vecLength(a:CGPoint)->CGFloat{
        // a^2 + b^2 = c^2  so return sqrt(a^2 + b^2)
        return CGFloat(sqrtf((CFloat(a.x)*CFloat(a.x))+(CFloat(a.y)*CFloat(a.y))))
    }
    
    func vecNormalize(a:CGPoint)->CGPoint{
        var length = vecLength(a)
        return CGPointMake(a.x/length, a.y/length)
    }
    
    func getDistance(a:CGPoint, b:CGPoint)->CGFloat{
        var dist = hypot((a.x - b.x), (a.y - b.y))
        return dist
    }
    
    
    
    
    /************************************************
    *************************************************
    **
    **  Other Misc Methods
    **
    *************************************************
    *************************************************/
    func torpedoSound(){
        torpedoMusicPlayer = AVAudioPlayer(contentsOfURL: torpedoURL, error: nil)
        torpedoMusicPlayer.prepareToPlay()
        torpedoMusicPlayer.volume -= 0.9
        torpedoMusicPlayer.play()
    }
    
    func getRandomXPosition(node:SKSpriteNode)->CGFloat {
        var minX = node.size.width/4
        let maxX = self.frame.size.width - minX
        let rangeX = maxX - minX
        return CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minX)    }
    
    func getRandomYPosition(node:SKSpriteNode)->CGFloat {
        var minY = node.size.height/2
        let maxY = self.frame.size.height
        let rangeY = maxY - minY
        return CGFloat(arc4random()) % CGFloat(rangeY) + CGFloat(minY)
    }
    
    
}
