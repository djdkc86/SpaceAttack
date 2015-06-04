//
//  GameSceneNext.swift
//  space
//
//  Created by Nathan T Marder on 6/3/15.
//  Copyright (c) 2015 Nathan Marder. All rights reserved.
//


import SpriteKit

var aliensPerFrame:Double = (1/60)
var currentLevel = 1
var minDuration = 3.0      // alien attack speeds
var maxDuration = 7.0


class GameSceneNext: SKScene {
    
    init(size: CGSize, status:Int) {
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        var winMessage:NSString = NSString()
        var levelMessage:NSString = "Next Level: "
        
        if status == 1 {
            if aliensPerFrame <= 1/4 { aliensPerFrame += 1/240 }
            currentLevel += 1
            if currentLevel % 5 == 0 {
                if minDuration > 1 && maxDuration > 1{
                    minDuration = minDuration - 0.25
                    maxDuration = maxDuration - 0.1
                }
            }
            winMessage = "You Won"
        } else if status == 2 {
            winMessage = "You Lost"
        } else if status == 0 {
            winMessage = "Lets Play"
        }
        
        
        var label1:SKLabelNode = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        label1.text = winMessage as String
        label1.fontColor = SKColor.whiteColor()
        label1.position = CGPointMake(self.size.width/2, self.size.height/1.8)
        
        var label2:SKLabelNode = SKLabelNode(fontNamed: "AppleSDGothicNeo")
        levelMessage = (levelMessage as String)+currentLevel.description
        label2.fontSize = 20
        label2.text = levelMessage as String
        label2.fontColor = SKColor.whiteColor()
        label2.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        self.addChild(label1)
        self.addChild(label2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
        self.view?.presentScene(GameScene(size: self.size), transition: transition)
    }
    
}
