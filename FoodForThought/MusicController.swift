
//
//  FirstViewController.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 6/27/18.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class musicController: UIViewController , UITableViewDataSource, UITableViewDelegate,SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate{
    //set up audio player
    var audioPlayer = AVAudioPlayer()
    var playerFlag = 0
    var AudioListCount = 0  // count AudioPlayer Files
    //todo: change the list to automatic generation. (done)

    var audioList = [[String]]()
    var itr = 0
    var timer = Timer()
    
    //Playlist setups
    @IBOutlet var currentNameLabel: UILabel!
    
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

    //spotify integration Variables
    var trackArtistName = ""
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var loggedin = false
    // end spotify integration Variables
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        // check if loggedin, if yes, then switch the functionality of the button.
        if player != nil{
            if !(loggedin) {
            
                if UIApplication.shared.openURL(loginUrl!) {
                    if auth.canHandle(auth.redirectURL) {
                    }
                }
                sleep(1)
                audioStreamingDidLogin(player)
                loggedin = true
            }
            else{ // if logged in, press button will log out.
                
                for _ in 1...(audioList.count - AudioListCount) {
                    audioList.popLast()
                }
                if playerFlag == 0{
                    if audioPlayer.isPlaying{
                        audioPlayer.pause()
                    }
                }else{
                    if player?.playbackState != nil {
                        if (player?.playbackState.isPlaying)! {
                            player?.setIsPlaying(false, callback: nil)
                        }
                    }
                }
                playerFlag = 0
                next()
                Playlist.reloadData()
                loginButton.setTitle("Login with Spotify", for: UIControlState.normal)
                loggedin = false
            }
        }else{
            if UIApplication.shared.openURL(loginUrl!) {
                if auth.canHandle(auth.redirectURL) {
                }
            }
            loggedin = true
        }
    }
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = "foodForThought://returnAfterLogin" // put your redirect URL here
        let clientID = "8ac1120b0a0d413eb1151ba09e64b7f1" // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = clientID
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserReadPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
    }
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
        
    }
    
    @objc func updateAfterFirstLogin () {
        
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            
            // self.loadingLabel.isHidden = false
            
        }
        
    }
    func featuredPlaylist(itr: Int){
        var flag = false
        do{
            
            let featured_music = try SPTBrowse.createRequestForFeaturedPlaylists(inCountry: "CA", limit: 10, offset: 0, locale: nil, timestamp: nil, accessToken: session.accessToken)
            let task2 = URLSession.shared.dataTask(with: featured_music, completionHandler: {(data,response,error) in
                do{
                    let featured_playlist = try SPTFeaturedPlaylistList.init(from: data, with: response)
                    
                    for i in 0...itr {
                    let feat_playlist = featured_playlist.items[i] as! SPTPartialPlaylist
                        
                    // add label to audio list
                    let label = "Featured \(self.audioList.count - self.AudioListCount + 1): \(feat_playlist.name!) (\(feat_playlist.trackCount) Tracks)"
                    self.audioList.append([label, feat_playlist.playableUri.absoluteString])
                        print(feat_playlist.playableUri.absoluteString)
                    }
                    flag = true
                    
                }catch{
                    print("error in parsing data from Spotify")
                }
            })
            task2.resume()
        }catch{
            print("error2")
        }
        
        while !flag{}
        Playlist.reloadData()
        
    }
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        loginButton.setTitle("Log out from Spotify", for: UIControlState.normal)
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        if( audioPlayer.isPlaying){
            audioPlayer.pause()
        }
        featuredPlaylist(itr: 5)
        
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
        
        AudioListCount = audioList.count
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
    func getTrackName(url : String) {
        var str = ""
        do{
            let currentTrack = try SPTTrack.createRequest(forTrack: URL(string: url), withAccessToken: session.accessToken, market: "CA")
            let task2 = URLSession.shared.dataTask(with: currentTrack, completionHandler: {(data,response,error) in
                do{
                    
                    //print(String(data: data!, encoding: String.Encoding.utf8)!)
                    let track = try SPTTrack.init(from: data, with: response)
                    
                    print(track)
                    //print(track.name)
                    //self.currentNameLabel.text = track.name
                }catch{// dont know why but above SPTTrack.init seeems to have bugs, and not build the object.
                    let jsonTrack = (String(data: data!, encoding: String.Encoding.utf8)!)
                    print(jsonTrack)
                    var artist_index = 0
                    var track_index = 1
                    // read through file to find names
                    for i in 0...jsonTrack.count - 4{
                        let index = jsonTrack.index(jsonTrack.startIndex, offsetBy: i)
                        let index2 = jsonTrack.index(jsonTrack.startIndex, offsetBy: i+4)
                        // by observation, the first name tag is artist name, and the last appearance of name tag is track name
                        if jsonTrack[index..<index2] == "name" {
                            if artist_index == 0{
                                artist_index = i + 9
                                print(jsonTrack[index])
                            }
                            if track_index != 0{
                                track_index = i + 9
                            }
                        }
                    }
                    //acquired index, now just get the names
                    var itr = 0
                    var artistName = ""
                    var trackName = ""
                    while( jsonTrack[jsonTrack.index(jsonTrack.startIndex, offsetBy: artist_index + itr)] != "\""){
                        artistName.append(jsonTrack[jsonTrack.index(jsonTrack.startIndex, offsetBy: artist_index + itr)])
                        itr += 1
                    }
                    itr = 0
                    while( jsonTrack[jsonTrack.index(jsonTrack.startIndex, offsetBy: track_index + itr)] != "\""){
                        trackName.append(jsonTrack[jsonTrack.index(jsonTrack.startIndex, offsetBy: track_index + itr)])
                        itr += 1
                    }
                    str = "\(trackName) - \(artistName)"
                    self.trackArtistName = str
                }
            })
            task2.resume()
            
        }catch{
            print("error requesting track")
        
        }
    }
    func playByIndex(index: Int){
        currentNameLabel.adjustsFontForContentSizeCategory = true
            //pause any playing music
            if playerFlag == 0{
                if audioPlayer.isPlaying{
                    audioPlayer.pause()
                }
            }else{
                if player?.playbackState != nil {
                    if (player?.playbackState.isPlaying)! {
                        player?.setIsPlaying(false, callback: nil)
                    }
                }
            }
        
         if(audioList.count - (index) > audioList.count - AudioListCount){
            //if selected file is from AVAudioPlayer
            do{
                //play
                playerFlag = 0
                audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[index][0], ofType: audioList[index][1])!))
                itr = index
                audioPlayer.prepareToPlay()
                currentNameLabel.text = "\(audioList[index][0])"
                play()
            }catch{
                print(error)
            }
        }
        else{
            playerFlag = 1
            player?.playSpotifyURI(audioList[index][1], startingWith: 0, startingWithPosition: 0, callback: nil)
            play() // for enitiating label update
            sleep(1)
            let url = (player?.metadata!.currentTrack!.uri)!
            getTrackName(url: url)
            sleep(1)
            currentNameLabel.text = "\(trackArtistName)"
        }
    }
    func play(){
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(lableUpdate), userInfo: nil, repeats: true)
        if playerFlag == 0 {
            audioPlayer.play()
            
             // todo: creat a thread that call next up on finish playing.(done)
            DispatchQueue.global(qos: .background).async {
                
                while(self.audioPlayer.duration - self.audioPlayer.currentTime > 1){
                    sleep(1)
                }
                self.next()
            }
        }else{
            if player?.playbackState != nil{
                if player?.playbackState.isPlaying == false {
                    player?.setIsPlaying(true, callback: nil)
                }
            }
        }
    }
    
    
    @IBOutlet weak var musicDragBar: UISlider?
    @IBOutlet weak var musicTimeDisplay: UILabel?
    @IBOutlet weak var musicCurrentDisplay: UILabel?
    
    @objc func lableUpdate(){
        if playerFlag == 0 { //if AVAudio is playing
            //duration label
            if((Int(audioPlayer.duration) % 60) > 9){
                musicTimeDisplay?.text = "\(Int(audioPlayer.duration) / 60):\(Int(audioPlayer.duration) % 60)"
            }else{
                musicTimeDisplay?.text = "\(Int(audioPlayer.duration) / 60):0\(Int(audioPlayer.duration) % 60)"
            }
            //currentTime label
            if((Int(audioPlayer.currentTime) % 60) > 9){
            musicCurrentDisplay?.text = "\(Int(audioPlayer.currentTime) / 60):\(Int(audioPlayer.currentTime) % 60)"
            }else{
                musicCurrentDisplay?.text = "\(Int(audioPlayer.currentTime) / 60):0\(Int(audioPlayer.currentTime) % 60)"
            }
            //drag bar label
            musicDragBar?.setValue(Float(audioPlayer.currentTime / audioPlayer.duration), animated: true)
        }else{
            if (player?.playbackState.isPlaying)! {
                if((Int((player?.metadata.currentTrack?.duration)!) % 60) > 9){
                    musicTimeDisplay?.text = "\(Int((player?.metadata.currentTrack?.duration)!) / 60):\(Int((player?.metadata.currentTrack?.duration)!) % 60)"
                }else{
                    musicTimeDisplay?.text = "\(Int((player?.metadata.currentTrack?.duration)!) / 60):0\(Int((player?.metadata.currentTrack?.duration)!) % 60)"
                }
                //currentTime label
                if((Int((player?.playbackState.position)!) % 60) > 9){
                    musicCurrentDisplay?.text = "\(Int((player?.playbackState.position)!) / 60):\(Int((player?.playbackState.position)!) % 60)"
                }else{
                    musicCurrentDisplay?.text = "\(Int((player?.playbackState.position)!) / 60):0\(Int((player?.playbackState.position)!) % 60)"
                }
                //drag bar label
                musicDragBar?.setValue(Float((player?.playbackState.position)! / (player?.metadata.currentTrack?.duration)!), animated: true)
            }
        }
    }
    
    func next(){
        if playerFlag == 0 {
            do{
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr+1) % AudioListCount][0], ofType: audioList[(itr+1) % AudioListCount][1])!))
                itr += 1
                audioPlayer.prepareToPlay()
                play()
                currentNameLabel.text = "\(audioList[itr % AudioListCount][0])"
                
            }catch{
                print(error)
            }
        }else{
            player?.skipNext(nil)
            sleep(1)
            let url = (player?.metadata!.currentTrack!.uri)!
            getTrackName(url: url)
            sleep(1)
            currentNameLabel.text = "\(trackArtistName)"
        }
    }
    
    @IBAction func musicDrag(_ sender: UISlider) {
        if playerFlag == 0 {
            audioPlayer.currentTime = TimeInterval(Int((musicDragBar?.value)! * Float(audioPlayer.duration)))
        }else{
            player?.seek(to: TimeInterval(Int((musicDragBar?.value)! * Float((player?.metadata.currentTrack?.duration)!))), callback: nil)
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        play()
        
    }

    @IBAction func pause(_ sender: UIButton) {
        if playerFlag == 0{
            if audioPlayer.isPlaying{
                audioPlayer.pause()
            }
        }else{
            if player?.playbackState != nil {
                if (player?.playbackState.isPlaying)! {
                    player?.setIsPlaying(false, callback: nil)
                }
            }
        }
        //URL(string: (player?.metadata!.currentTrack!.uri)!)
        

        
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if playerFlag == 0 {
            if audioPlayer.isPlaying{
                audioPlayer.currentTime = 0
                play()
            }
        }else{
            if player?.playbackState != nil {
                if (player?.playbackState.isPlaying)! {
                    player?.seek(to: 0, callback: nil)
                }
            }
        }
    }
    
    @IBAction func next(_ sender: UIButton){
            next()
    }
    @IBAction func prev(_ sender: UIButton){
        if playerFlag == 0 {
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioList[(itr + AudioListCount - 1) % AudioListCount][0], ofType: audioList[(itr + AudioListCount - 1) % AudioListCount][1])!))
                itr += AudioListCount - 1
                audioPlayer.prepareToPlay()
                play()
                currentNameLabel.text = "\(audioList[itr % AudioListCount][0])"
            }catch{
                print(error)
            }
        }else{
            //todo
            player?.skipPrevious(nil)
            sleep(1)
            
            let url = (player?.metadata!.currentTrack!.uri)!
            getTrackName(url: url)
            sleep(1)
            currentNameLabel.text = "\(trackArtistName)"
        }
        
    }
    
    //end Music functions
}
