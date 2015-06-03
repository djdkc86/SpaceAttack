//
//  GameSceneNext.swift
//  space
//
//  Created by Nathan T Marder on 6/3/15.
//  Copyright (c) 2015 Nathan Marder. All rights reserved.
//


import SpriteKit

class GameSceneNext: SKScene {
    

    
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        
        
        var message:NSString = NSString()
        
        
        if won {
        
            message = "You Won"
            
        } else {
        
            message = "You Lost"
        }
        
        
        var label:SKLabelNode = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        label.text = message as String
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        
        self.addChild(label)
        
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(2.0),
            SKAction.runBlock({
                self.removeAllChildren()
                var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(GameScene(size: self.size), transition: transition)
                
            })
        ]))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   
}
