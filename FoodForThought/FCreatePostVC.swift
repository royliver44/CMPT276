//
//  FCreatePostVC.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 7/21/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class FCreatePostVC: UIViewController {
    
    @IBOutlet var bodyOfPost: UITextView!
    @IBOutlet var SubmitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SubmitButtonPressed() {
        let response = SendMessage(outgoingMessage: "P:" + bodyOfPost.text)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func SendMessage(outgoingMessage: String) -> String {
    
    // declare a variable to return
    var response = ""
    
    // create a socket object to connect to fftserver
    let client = TCPClient(address: "184.73.132.214", port: 12345)
    
    // connect to fftserver
    switch client.connect(timeout: 1){
    case .success:
        print("Connection successful")
        
        // send whatever is in the text field
        switch client.send(string: outgoingMessage ) {
        case .success:
            print("Message sent to server")
            
            // wait for data to be available
            while(client.bytesAvailable() == 0) {}
            print("Data available")
            
            let availableBytes32: Int32 = client.bytesAvailable()!
            let availableBytes = Int(availableBytes32)
            
            // read the available data
            guard let data = client.read(availableBytes, timeout: 1) else{
                print("ERROR receiving message from server, gaurd engaged")
                return ""
            }
            print("Message received from server")
            
            // convert response to a string
            response = String(bytes: data, encoding: .utf8)!
            if (response != "") {
                print(response)
            }
            else{
                print("ERROR interpreting server response:")
                return ""
            }
            
        case .failure(let error):
            print("ERROR sending message to server")
            print(error)
            return ""
        }
    case .failure(let error):
        print("ERROR connecting to server")
        print(error)
        return ""
    }
    
    return response
}
