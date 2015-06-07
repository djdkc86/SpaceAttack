////
////  GreenTurtle.swift
////  space
////
////  Created by Nathan T Marder on 6/6/15.
////  Copyright (c) 2015 Nathan Marder. All rights reserved.
////
//
//import UIKit
//import SpriteKit
//
//
//class Alien1: SKSpriteNode {
//    
//    // class fields
//    var actions:NSMutableArray?
//    let bitMaskCategory:UInt32 = 0x1 << 1
//    var difficulty:Int = 1
//    var thisScene:SKScene?
//    var thisView:UIView?
//    
//    
//    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
//        super.init(texture: texture, color: color, size: size)
//        //if (texture == nil){ self.texture = SKTexture(imageNamed: "alien")  }
//        
//  
//        thisView = thisScene?.view
//        var initialXPosition:CGFloat = getRandomXPosition()
//        var initialYPosition:CGFloat?
//        var initialPosition:CGPoint = getRandomStartPosition()
//        var finalPosition:CGPoint?
//        var positions:NSMutableArray?
//        var rangeDuration = maxDuration - minDuration
//        var duration:Double = Double(arc4random()) % Double(rangeDuration) + Double(minDuration)
//        var actions:NSMutableArray = NSMutableArray()
//
//        var pathType:String?
//
//        
//        
//        // set up physics
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
//        self.physicsBody?.dynamic = true
//        self.physicsBody?.categoryBitMask = bitMaskCategory
//        self.physicsBody?.contactTestBitMask = Torpedo1BitMaskCategory
//        self.physicsBody?.collisionBitMask = 0
//        
//        
//        // set positions
//        positions = NSMutableArray()
//        getRandomStartPosition()
//        self.position = getRandomStartPosition()
//       // positions?.addObject(startPosition as! AnyObject)
//        
//        
//
//            
//            switch difficulty {
//                
//            case 1:
//                finalPosition = CGPointMake(initialXPosition, -self.size.height)
//                actions.addObject(SKAction.moveTo(finalPosition!, duration: duration))
//                
//            case 2:
//                finalPosition = CGPointMake(getRandomXPosition(), -self.size.height)
//                actions.addObject(SKAction.moveTo(finalPosition!, duration: duration))
//                
//            case 3:
//                var midPosition = CGPointMake(getRandomXPosition(), getRandomYPosition())
//                var finalPosition = CGPointMake(getRandomXPosition(), -self.size.height)
//                var d1 = getDistance(self.position, b: midPosition)
//                var d2 = getDistance(midPosition, b: finalPosition)
//                var totalDist = d1 + d2
//                var d1Percent = Float(d1/totalDist)
//                var d2Percent = Float(d2/totalDist)
//                var dFloat = Float(duration)
//                var d1Duration = Double(dFloat * d1Percent)
//                var d2Duration = Double(dFloat * d2Percent)
//                actions.addObject(SKAction.moveTo(midPosition, duration: d1Duration))
//                actions.addObject(SKAction.moveTo(finalPosition, duration: d2Duration))
//                
//                
//            default:
//                var y1 = CGFloat(arc4random()) % CGFloat(self.scene!.size.height) + self.size.height
//                var y2 = CGFloat(arc4random()) % CGFloat(y1) - self.size.height
//                var x1 = getRandomXPosition()
//                var x2 = getRandomXPosition()
//                var midPosition1 = CGPointMake(x1, y1)
//                var midPosition2 = CGPointMake(x2, y2)
//                var finalPosition = CGPointMake(x1, -self.size.height)
//                var d1 = getDistance(self.position, b: midPosition1)
//                var d2 = getDistance(midPosition1, b: midPosition2)
//                var d3 = getDistance(midPosition2, b: finalPosition)
//                var totalDist = d1 + d2 + d3
//                var d1Percent = Float(d1/totalDist)
//                var d2Percent = Float(d2/totalDist)
//                var d3Percent = Float(d3/totalDist)
//                var dFloat = Float(duration)
//                var d1Duration = Double(dFloat * d1Percent)
//                var d2Duration = Double(dFloat * d2Percent)
//                var d3Duration = Double(dFloat * d3Percent)
//                actions.addObject(SKAction.moveTo(midPosition1, duration: d1Duration))
//                actions.addObject(SKAction.moveTo(midPosition2, duration: d2Duration))
//                actions.addObject(SKAction.moveTo(finalPosition, duration: d3Duration))
//            }
//        
//        // if the alien gets this far it means it made it across the whole screen
//        actions.addObject(SKAction.runBlock({
//          //  if ++GameScene.aliensThrough >= 2{
//                var transition = SKTransition.flipHorizontalWithDuration(0.5)
//                self.scene!.view!.presentScene(GameSceneNext(size: self.size, status:2), transition: transition)
//            //}
//        }))
//        
//        actions.addObject(SKAction.removeFromParent())
//        //self.runAction(SKAction.sequence(actions as [AnyObject]))
//    }
//    
//    /************************************************
//    *************************************************
//    **
//    **  Other Required Initializers
//    **
//    *************************************************
//    *************************************************/
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    convenience init(){
//        let theTexture = SKTexture(imageNamed: "alien")
//        self.init(texture: theTexture, color: nil, size: theTexture.size())
//    }
//    
//    /************************************************
//    *************************************************
//    **
//    **  Getters and Setters
//    **
//    *************************************************
//    *************************************************/
//    func setDifficultyLevel(diff:Int){
//        self.difficulty = diff
//    }
//    
//    func getDifficultyLevel()->Int {
//        return self.difficulty
//    }
//    
//    func runAction(){
//        self.runAction(SKAction.sequence(actions! as [AnyObject]))
//    }
//    
//    
//    
//    /************************************************
//    *************************************************
//    **
//    **  Vector Math
//    **
//    *************************************************
//    *************************************************/
//    func vecAdd(a:CGPoint, b:CGPoint)->CGPoint{
//        return CGPointMake(a.x+b.x, a.y+b.y)
//    }
//    
//    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
//        return CGPointMake(a.x - b.x, a.y - b.y)
//    }
//    
//    func vecMult(a:CGPoint, factor:CGFloat)->CGPoint{
//        return CGPointMake(a.x * factor, a.y * factor)
//    }
//    
//    func vecLength(a:CGPoint)->CGFloat{
//        // a^2 + b^2 = c^2  so return sqrt(a^2 + b^2)
//        return CGFloat(sqrtf((CFloat(a.x)*CFloat(a.x))+(CFloat(a.y)*CFloat(a.y))))
//    }
//    
//    func vecNormalize(a:CGPoint)->CGPoint{
//        var length = vecLength(a)
//        return CGPointMake(a.x/length, a.y/length)
//    }
//    
//    func getDistance(a:CGPoint, b:CGPoint)->CGFloat{
//        var dist = hypot((a.x - b.x), (a.y - b.y))
//        return dist
//    }
//    
//    
//    
//    /************************************************
//    *************************************************
//    **
//    **  Other Misc Methods
//    **
//    *************************************************
//    *************************************************/
//    func getRandomStartPosition()->CGPoint{
//    
//        return CGPointMake(getRandomXPosition(), self.scene!.size.height + self.size.height/2)
//
//    }
//    
//    func getRandomXPosition()->CGFloat {
//        var minX = self.size.width/2
//      //  let maxXX = self.scene?.size
//        var maxX = self.thisScene!.frame.size.width - minX
//        var rangeX = maxX - minX
//        return CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minX)    }
//    
//    func getRandomYPosition()->CGFloat {
//        var minY = self.size.height/2
//        let maxY = self.thisScene!.frame.size.height
//        let rangeY = maxY - minY
//        return CGFloat(arc4random()) % CGFloat(rangeY) + CGFloat(minY)
//    }
//}
//
//
//
