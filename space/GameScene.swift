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



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var lastYieldTimeInterval = NSTimeInterval()
    var lastUpdateTimeInterval = NSTimeInterval()
    var clock:Double = 0.0
    var aliensDestroyed:Int = 0
    
    //bit mask which identifies collisions: (expression 0x1 is multiplied by 1)
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    
    override func didMoveToView(view: SKView) {
    }
    
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPointMake(self.frame.size.width/2, player.size.height + 20)
        self.addChild(player)
        self.physicsWorld.gravity = CGVectorMake(0, 0)  // our world has zero gravity, it's space!
        self.physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addAlien(){
        
        var alien = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        let minX = alien.size.width/2
        let maxX = self.frame.size.width - minX
        let rangeX = maxX - minX
        
        // create a random x-position and place alien at top of screen
        let xPosition:CGFloat = CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minX)
        alien.position = CGPointMake(xPosition, self.frame.size.height+alien.size.height)
        self.addChild(alien)
        
        
        // create a random speed that the alien attacks with
        //        let minDuration = 1.5
        //        let maxDuration = 4.0
        let rangeDuration = maxDuration - minDuration
        
        let duration = Double(arc4random()) % Double(rangeDuration) + Double(minDuration)
        var actionArray:NSMutableArray = NSMutableArray()
        var movePosition = CGPointMake(xPosition, -alien.size.height)
        actionArray.addObject(SKAction.moveTo(movePosition, duration: (duration as NSTimeInterval)))
        
        
        
        // if the alien gets this far it means it made it across the whole screen
        actionArray.addObject(SKAction.runBlock({
            var transition = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(GameSceneNext(size: self.size, status:2), transition: transition)
        }))
        
        
        actionArray.addObject(SKAction.removeFromParent())
        alien.runAction(SKAction.sequence(actionArray as [AnyObject]))
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        clock += (aliensPerFrame)
        if clock >= 1 {
            addAlien()
            clock = 0.0;
        }
    }
    
    
    /**This is all about firing the torpedos  **/
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // play the cool sound
        torpedoSound()
        
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
        if offSet.y < 0 {
            return
        }
        
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
    
    
    
    // contact Delegate Method for handling collisions
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
                    if ++aliensDestroyed == currentLevel {
                        var tran = SKTransition.flipHorizontalWithDuration(0.5)
                        self.view?.presentScene(GameSceneNext(size: self.size, status:1), transition: tran)
                    }
                }
            } else {
                return
            }
        }
    }
    
    func torpedoSound(){
        torpedoMusicPlayer = AVAudioPlayer(contentsOfURL: torpedoURL, error: nil)
        torpedoMusicPlayer.prepareToPlay()
        torpedoMusicPlayer.volume -= 0.9
        torpedoMusicPlayer.play()
    }
    
    // vector addition used for torpedo firing
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
    
    
}
