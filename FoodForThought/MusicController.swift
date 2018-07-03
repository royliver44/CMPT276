
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
    
    //todo: change the list to automatic generation.

    var audioList = [[String]]()
    var itr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Automatic Music list generation (mp3 only)
        let docsPath = Bundle.main.resourcePath!

        let fileManager = FileManager.default
        do{
            //getting all files
            var docsArray = try fileManager.contentsOfDirectory(atPath: docsPath)
            
            //exctract .mp3 files
            var i = 0
            for each in docsArray{
                if each.range(of: ".mp3") != nil{
                }else{
                    docsArray.remove(at: i)
                    i -= 1
                }
                i += 1
            }
            //adding to audioList
            for each in docsArray{
                 audioList.append(each.components(separatedBy: "."))
            }
        }catch{
            print(error)
        }
        

        //Audio setup
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[0][0], ofType: audioList[0][1])!))
            audioPlayer.prepareToPlay()
            
            //set up backgroud music playing
            let audioSession = AVAudioSession.sharedInstance()
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
    func play(){
        audioPlayer.play()
        // todo: creat a thread that call next up on finish playing.
    }
    
    func next(){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr+1) % audioList.count][0], ofType: audioList[(itr+1) % audioList.count][1])!))
            itr += 1
            audioPlayer.prepareToPlay()
            play()
        }catch{
            print(error)
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
            play()
        }
    }
    
    @IBAction func next(_ sender: UIButton){
        next()
    }
    @IBAction func prev(_ sender: UIButton){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr-1) % audioList.count][0], ofType: audioList[(itr-1) % audioList.count][1])!))
            itr -= 1
            audioPlayer.prepareToPlay()
            play()
        }catch{
            print(error)
        }
        
    }
    
    
    
    //end Music functions
}
