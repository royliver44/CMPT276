//
//  FBrowseVC.swift
//  
//
//  Created by Jordan Ehrenholz on 7/24/18.
//

import UIKit

// contains information about a single post
class Post
{
    var ID: String?
    var authorID: String?
    var bodyText: String?
    var timeStamp: String?
    var loveCount: String?
    var userLoveStatus: String?
    
    init ()
    {
        self.ID = ""
        self.authorID = ""
        self.bodyText = ""
        self.timeStamp = ""
        self.loveCount = ""
        self.userLoveStatus = ""
    }
    
    // parses the post data section of a server's response to a get page request
    init (fromString: String)
    {
        var components: [String] = fromString.components(separatedBy: delimChar)
        if (components.count != 6)
        {
            return
        }
        self.ID = components[0]
        self.authorID = components[1]
        self.bodyText = components[2]
        self.timeStamp = components[3]
        self.loveCount = components[4]
        self.userLoveStatus = components[5]
    }
}

// contains info about a single page (feed, latest, popular...)
class Page
{
    var nextPostToDeque: Int
    var numPosts: Int
    var posts: [Post]
    var numAuthors: Int
    var authors: [Author]
    
    init ()
    {
        self.nextPostToDeque = 0
        self.numPosts = 0
        self.posts = []
        self.numAuthors = 0
        self.authors = []
    }
    
    func empty()
    {
        nextPostToDeque = 0
        numPosts = 0
        posts = []
        numAuthors = 0
        authors = []
    }
}

// contains information about a single author
class Author
{
    var ID: String?
    var name: String?
    var reputation: String?
    var followStatus: String?
    
    init ()
    {
        self.ID = ""
        self.name = ""
        self.reputation = ""
        self.followStatus = ""
    }
    
    // parses the authors data section of a server's response to a get page request
    init (fromString: String)
    {
        var components: [String] = fromString.components(separatedBy: delimChar)
        if (components.count != 4)
        {
            return
        }
        self.ID = components[0]
        self.name = components[1]
        self.reputation = components[2]
        self.followStatus = components[3]
    }
}

class FBrowseVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    // UI outlets
    @IBOutlet var newPostButton: UIButton!
    @IBOutlet var latestButton: UIButton!
    @IBOutlet var popularButton: UIButton!
    @IBOutlet var postsTableView: UITableView!
    
    var currentPostsPage: String = "Latest"
    var feedPosts: String = ""
    var latestPosts: String = ""
    var popularPosts: String = ""
    var myPosts: String = ""
    var numPosts: Int = 0
    
    // locally stored post information
    var latestPage: Page = Page()
    
    
    // gets page information from fftserver with a get page request and saves the data in local variables
    // returns the number of cells in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return latestPage.numPosts;
    }
    
    // displays a single post
    // called numberOfRowsInSection() times when the view is loaded
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let postToLoad: Post = latestPage.posts[indexPath.row]
        latestPage.nextPostToDeque += 1
        // if loading the last cell, reset the next post index for the next time the page is loaded
        if (latestPage.nextPostToDeque == latestPage.numPosts)
        {
            latestPage.nextPostToDeque = 0
        }
        
        // create a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "browseCell", for: indexPath) as! FPostTableCell
        
        // find out who the author of this post is using this page's authors list
        let authorID: String = postToLoad.authorID!
        var authorToLoad: Author = Author()
        for currentAuthor in latestPage.authors
        {
            if (authorID == currentAuthor.ID)
            {
                authorToLoad = currentAuthor
                break
            }
        }
        
        // update the cell's data
        cell.postData = postToLoad
        cell.authorData = authorToLoad
        cell.UpdateUI()
        
        return cell
    }
    
    // disables the cells from turning gerey when you tap them
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GetPageData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // send a GET request to fftserver to get posts
    // populate the table cells with post data
    @IBAction func LatestButtonPressed(_ sender: UIButton)
    {
        currentPostsPage = "Latest"
        latestPage.empty()
        GetPageData()
        postsTableView.reloadData();
    }
    
    @IBAction func PopularButtonPressed(_ sender: UIButton)
    {
        currentPostsPage = "Popular"
        latestPage.empty()
        GetPageData()
        postsTableView.reloadData();
    }
    
    // fetches page data from fftserver for a specific page
    func GetPageData() -> Int
    {
        // gets posts from server
        var request: String = "G"
        if (currentPostsPage == "Latest")
        {
            request += "L"
        }
        else
        {
            request += "P"
        }
        request += GenerateUIDandTicket()
        var response: String = TalkToServer(outgoingMessage: request)
        if (response == "")
        {
            print("ERROR communicating with fftserver")
            return -1;
        }
        
        // split the server message into 2 strings: one for post data and one for user data
        if (response.prefix(1) != successHeader)
        {
            return -1
        }
        response = String(response.dropFirst(1))
        var messageLists = response.components(separatedBy: listDelimChar)
        if (messageLists.count != 2)
        {
            return -1;
        }
        let allPostDataFromServer: String = messageLists[0]
        let allUserDataFromServer: String = messageLists[1]
        
        
        // load all the page info from the server response into a page object
        let postStrings: [String] = allPostDataFromServer.components(separatedBy: objectDelimChar)
        latestPage.numPosts = postStrings.count
        for postString in postStrings
        {
            let newPost: Post = Post(fromString: postString)
            latestPage.posts.append(newPost)
        }
        let authorStrings: [String] = allUserDataFromServer.components(separatedBy: objectDelimChar)
        latestPage.numAuthors = authorStrings.count
        for authorString in authorStrings
        {
            let newAuthor: Author = Author(fromString: authorString)
            latestPage.authors.append(newAuthor)
        }
        
        return 0
    }
    
}
