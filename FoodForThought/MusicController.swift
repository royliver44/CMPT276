
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
    var audioList = ["Joshua", "The Truth That You Leave", "Kiss The Rain"]
    var listLen = 3
    var itr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Audio setup
        do{
            
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "October", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            //set up backgroud music playing
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
    
    @IBAction func next(_ sender: UIButton){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr+1) % 3], ofType: "mp3")!))
            itr += 1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch{
            print(error)
        }
        
    }
    @IBAction func prev(_ sender: UIButton){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr-1) % 3], ofType: "mp3")!))
            itr -= 1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch{
            print(error)
        }
        
    }
    
    
    
    //end Music functions
}
