//
//  FBrowseVC.swift
//  
//
//  Created by Jordan Ehrenholz on 7/24/18.
//

import UIKit

class FBrowseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 6;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "browseCell", for: indexPath) as! BrowseTableViewCell
        
        return cell
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print ("browse forums view loaded")
        // send a GET request to fftserver to get a list of posts
        // populate the table cells with post data
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
   
    // send a GET request to fftserver to get posts
    // populate the table cells with post data
    @IBAction func FeedButtonPressed(_ sender: UIButton) {
    }
    @IBAction func LatestButtonPressed(_ sender: UIButton) {
    }
    @IBAction func PopularButtonPressed(_ sender: UIButton) {
    }
    @IBAction func MyPostsButtonPressed(_ sender: UIButton) {
    }
    
}
