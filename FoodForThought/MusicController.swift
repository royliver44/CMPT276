
//
//  FirstViewController.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 6/27/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class musicController: UIViewController , UITableViewDataSource, UITableViewDelegate,SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate{
    //set up audio player
    var audioPlayer = AVAudioPlayer()
    
    //todo: change the list to automatic generation. (done)
    
    var audioList = [[String]]()
    var itr = 0
    var timer = Timer()
    
    //Playlist setups
    @IBOutlet weak var Playlist: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = audioList[indexPath.row][0]
        cell.textLabel?.text = text
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        playByIndex(index: indexPath.row)
    }
    
    //spotify integration
    // Variables
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = "foodForThought://returnAfterLogin" // put your redirect URL here
        let clientID = "8ac1120b0a0d413eb1151ba09e64b7f1" // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = clientID
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
    }
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            
            self.player!.login(withAccessToken: authSession.accessToken!)
            self.player!.login(withAccessToken: authSession.accessToken!)
            print(3)
            print(authSession.accessToken!)
            print(player!.loggedIn)
        }
        
    }
    
    @objc func updateAfterFirstLogin () {
        loginButton.isHidden = true
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            self.loginButton.isHidden = true
            // self.loadingLabel.isHidden = false
            
        }
        
    }
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:1p80LdxRV74UKvL8gnD7ky", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
            
        })
        
    }
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Playlist.dataSource = self
        Playlist.delegate = self
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
        
        //spotify intergtation
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(musicController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //@IBOutlet weak var musicTimeDisplay: UILabel!
    //@IBOutlet weak var musicCurrentDisplay: UILabel!
    
    //Music functions
    func playByIndex(index: Int){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[index][0], ofType: audioList[index][1])!))
            itr = index
            audioPlayer.prepareToPlay()
            play()
        }catch{
            print(error)
        }
    }
    func play(){
        audioPlayer.play()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(lableUpdate), userInfo: nil, repeats: true)
        
        // todo: creat a thread that call next up on finish playing.(done)
        DispatchQueue.global(qos: .background).async {
            
            while(self.audioPlayer.duration - self.audioPlayer.currentTime > 1){
                sleep(1)
            }
            self.next()
        }
    }
    
    
    @IBOutlet weak var musicDragBar: UISlider?
    @IBOutlet weak var musicTimeDisplay: UILabel?
    @IBOutlet weak var musicCurrentDisplay: UILabel?
    
    @objc func lableUpdate(){
        //Total duration of play.
        if((Int(audioPlayer.duration) % 60) > 9){
            musicTimeDisplay?.text = "\(Int(audioPlayer.duration) / 60):\(Int(audioPlayer.duration) % 60)"
        }else{
            musicTimeDisplay?.text = "\(Int(audioPlayer.duration) / 60):0\(Int(audioPlayer.duration) % 60)"
        }
        //currentTime of play
        if((Int(audioPlayer.currentTime) % 60) > 9){
            musicCurrentDisplay?.text = "\(Int(audioPlayer.currentTime) / 60):\(Int(audioPlayer.currentTime) % 60)"
        }else{
            musicCurrentDisplay?.text = "\(Int(audioPlayer.currentTime) / 60):0\(Int(audioPlayer.currentTime) % 60)"
        }
        
        musicDragBar?.setValue(Float(audioPlayer.currentTime / audioPlayer.duration), animated: true)
        
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
    
    @IBAction func musicDrag(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(Int((musicDragBar?.value)! * Float(audioPlayer.duration)))
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

