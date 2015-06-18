//
//  GameViewController.swift
//  space
//
//  Created by Nathan T Marder on 6/2/15.
//  Copyright (c) 2015 Nathan Marder. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}


// lets create an audio player instance
var backgroundMusicPlayer = AVAudioPlayer()

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        
        playMusic()
        
        /** Create a spritekit view... **/
        var skView:SKView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /** Create a spritekit scene... and present it within the view **/
        //var scene = GameScene(size: skView.bounds.size)
        var scene = GameSceneNext(size: skView.bounds.size, status:0)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        skView.presentScene(scene)
    }
    
    func playMusic(){
        let bgMusicURL1:NSURL = NSBundle.mainBundle().URLForResource("beatoff", withExtension: "mp3")!
        let bgMusicURL2:NSURL = NSBundle.mainBundle().URLForResource("nateBGmusic", withExtension: "mp3")!
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL2, error: nil)
        backgroundMusicPlayer.numberOfLoops = -1  // loops indefinitely
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
