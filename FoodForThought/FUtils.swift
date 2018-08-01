//
//  FUtils.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 7/29/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import Foundation

// fftserver information
let fftserverIPAddress: String = "52.90.42.35"
let fftserverPort: Int32 = 12345;

// user login state variables
var userID_s: String = "0"
var userName_s: String = ""
var userTicket_s: String = ""

// other constants
let escapeChar: String = "\\"
let delimChar: String = "*"
let objectDelimChar: String = "~"
let listDelimChar: String = "^"
let ticketDelimChar: String = "-"
let successHeader: String = "G"
let failHeader: String = "B"

// concatenates the user's unique identifier and login ticket which are
// commonly used together in the application layer protocol
func GenerateUIDandTicket() -> String
{
    if (userID_s == "0")
    {
        return userID_s
    }
    else
    {
        return userID_s + ticketDelimChar + userTicket_s
    }
}

// sends a message to fftserver and returns it's response
// creates a single tcp connection for the transcation
// returns an empty string on failure
func TalkToServer( outgoingMessage: String) -> String
{
    var outgoingMessage = outgoingMessage
    print ("TALK TO SERVER CALLED: " + outgoingMessage)
    outgoingMessage += "\n" // swift strings are not null terminated?
    
    // declare a variable to return
    var response = ""
    
    // create a socket object to connect to fftserver
    let client = TCPClient(address: fftserverIPAddress, port: fftserverPort)
    
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
