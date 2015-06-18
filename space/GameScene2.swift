//
//  GameScene2.swift
//  space
//
//  Created by Nathan T Marder on 6/6/15.
//  Copyright (c) 2015 Nathan Marder. All rights reserved.
//

import UIKit

import SpriteKit
import AVFoundation

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    
    
    
    var torpedoMusicPlayer = AVAudioPlayer()
    let torpedoURL:NSURL = NSBundle.mainBundle().URLForResource("torpedoFire", withExtension: "mp3")!
    var buttonBox:CGRect = CGRect()
    
    var straightLines:Bool = true
    var angledLines:Bool = true
    var multiAngledLines:Bool = true
    var alienDifficulty = 1
    
    
    var player = SKSpriteNode()
    var lastYieldTimeInterval = NSTimeInterval()
    var lastUpdateTimeInterval = NSTimeInterval()
    var alienClock:Double = 0.0
    var torpedoClock:Double = 0.0
    var keepFiring:Bool = false
    var aliensDestroyed:Int = 0
    var aliensThrough:Int = 0
    var alienKillGoal = 3
    var alienStartSize:CGSize?
    
    
    //bit mask which identifies collisions: (expression 0x1 is multiplied by 1)
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    override func didMoveToView(view: SKView) {  }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        var playerSize = CGSize(width: self.frame.size.width/10, height: self.frame.size.width/10)
        player = SKSpriteNode(imageNamed: "shuttle")
        //player = SKSpriteNode(color: UIColor.whiteColor(), size: playerSize)
        player.position = CGPointMake(self.frame.size.width/2, player.size.height + 10)
        player.speed = 150
        //create physics body and take care of collisions
        
        alienStartSize = CGSize(width: self.frame.size.width/16.0, height: self.frame.size.width/16.0)
        
        self.addChild(player)
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = photonTorpedoCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.speed = 120.0
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
            fireTorpedo()
            alienClock = 0.0;
        }
    }
    
    
    
    func addAlien(difficulty: Int) {
        
        var alien:SKSpriteNode = SKSpriteNode(color: SKColor.grayColor(), size: alienStartSize!)
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
        
        var numerator = getRandom(30, upper: 99)
        var percent:CGFloat = CGFloat(Double(numerator)/100.0)
        
        alien.setScale(percent)
        
        //bezier curve path with randomized curves
        alien.position = CGPointMake(initialXPosition, initialYPosition)
        var y1 = CGFloat(arc4random()) % CGFloat(self.frame.size.height) + alien.size.height
        var y2 = CGFloat(arc4random()) % CGFloat(y1) - alien.size.height
        var ran = Int(arc4random()) % 9 + 1
        var midPosition1:CGPoint
        var midPosition2:CGPoint
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
        
        self.addChild(alien)
        
        
        
        // if the alien gets this far it means the player lost
        actionArray.addObject(SKAction.runBlock({
                var transition = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(GameSceneNext(size: self.size, status:2), transition: transition)
        }))
        
        actionArray.addObject(SKAction.removeFromParent())
        alien.runAction(SKAction.sequence(actionArray as [AnyObject]))
        
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
        location.y += player.size.height
        var distance:CGFloat = vecDistance(player.position, b: location)
        let moveDuration = Double (distance) / 50.0
        var doThis:SKAction = SKAction.moveTo(location, duration: moveDuration)
        player.runAction(doThis)
        //self.keepFiring = true
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch:UITouch = touches.first as! UITouch
        var location:CGPoint = touch.locationInNode(self)
        location.y += player.size.height
        player.position = location
    }

    
    func fireTorpedo(){
        
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
        
        let velocity = 568.0/1.0
        let moveDuration = Double(self.size.width) / velocity
        var finalDest:CGPoint = CGPointMake(player.position.x,self.frame.size.height+torpedo.size.height)
        
        torpedoSound()
        self.addChild(torpedo)

        //now we need an action array which we can execute, it involves movements
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(finalDest, duration: moveDuration))
        actionArray.addObject(SKAction.removeFromParent())
        torpedo.runAction(SKAction.sequence(actionArray as [AnyObject]))
        
        //        var doThis:SKAction = SKAction.moveTo(location, duration: moveDuration)
        //        player.runAction(doThis)
        
        
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
                    nodeA.hidden = true
                    
                    nodeA.removeFromParent()
                    nodeB.removeFromParent()
                    
                    if ++aliensDestroyed == alienKillGoal {
                        //var t = SKTransition.flipHorizontalWithDuration(0.5)
                        self.view?.presentScene(GameSceneNext(size: self.size, status:1), transition: nil)
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
    
    func vecDistance(a:CGPoint, b:CGPoint)->CGFloat{
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
    
    func getRandom (lower : Int , upper : Int) -> Int {
        let difference = upper - lower
        return Int(Float(rand())/Float(RAND_MAX) * Float(difference + 1)) + lower
    }
    
    func getRandomPercent () -> Float {
        return Float(rand())/Float(RAND_MAX) * Float(1)
    }
}
