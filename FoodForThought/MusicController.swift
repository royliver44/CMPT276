
//
//  FirstViewController.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 6/27/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit
import AVFoundation

class musicController: UIViewController {
    //set up audio player
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Audio setup
        do{
            
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "October", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            
            var audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
        }
        catch{
            print(error)
        }
        //end Audio setup
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Music functions
    @IBAction func play(_ sender: UIButton) {
        audioPlayer.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
        
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }    }
    
    
    //end Music functions
}
