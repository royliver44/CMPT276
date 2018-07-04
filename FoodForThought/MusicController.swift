
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
<<<<<<< HEAD
    var audioList = ["Joshua", "The Truth That You Leave", "Kiss The Rain"]
    var listLen = 3
=======
    
    //todo: change the list to automatic generation. (done)

    var audioList = [[String]]()
>>>>>>> d638a0b102804c40cb3d7c11b6ba490af0500f39
    var itr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
<<<<<<< HEAD
        //Audio setup
        do{
            
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "October", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            //set up backgroud music playing
            var audioSession = AVAudioSession.sharedInstance()
=======
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
>>>>>>> d638a0b102804c40cb3d7c11b6ba490af0500f39
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
        }
        catch{
            print(error)
        }
        //end Audio setup
<<<<<<< HEAD
=======
        
>>>>>>> d638a0b102804c40cb3d7c11b6ba490af0500f39
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
<<<<<<< HEAD
    //Music functions
    @IBAction func play(_ sender: UIButton) {
        audioPlayer.play()
        
=======
    
    //Music functions
    func play(){
        audioPlayer.play()

         // todo: creat a thread that call next up on finish playing.(done)
        DispatchQueue.global(qos: .background).async {
            
            while(self.audioPlayer.duration - self.audioPlayer.currentTime > 1){
                sleep(1)
            }
            self.next()
        }
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
>>>>>>> d638a0b102804c40cb3d7c11b6ba490af0500f39
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
<<<<<<< HEAD
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
=======
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
>>>>>>> d638a0b102804c40cb3d7c11b6ba490af0500f39
        }catch{
            print(error)
        }
        
    }
    
    
    
    //end Music functions
}
