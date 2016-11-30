//
//  ViewController.swift
//  FayeSwift
//
//  Created by Haris Amin on 01/25/2016.
//  Copyright (c) 2016 Haris Amin. All rights reserved.
//

import UIKit
import FayeSwift

class ViewController: UIViewController, UITextFieldDelegate, FayeClientDelegate {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textView: UITextView!
  
  /// Example FayeClient
  let client:FayeClient = FayeClient(aFayeURLString: "wws://api-dev10.sprentapp.com:8001", channel: "/messages")
  
  // MARK:
  // MARK: Lifecycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    client.delegate = self;
    client.connectToServer()
    
    let channelBlock:ChannelSubscriptionBlock = {(messageDict) -> Void in
        
      let text : Any? = messageDict["text"]
      print("Here is the Block message: \(text)")
        
        
    }
    _ = client.subscribeToChannel("/messages", block: channelBlock)
    
    
    
    
    
    DispatchQueue.main.asyncAfter(deadline: .now() + (5 * 0.1)) {
        // your code here
        DispatchQueue.main.async {
            self.client.unsubscribeFromChannel("/messages")
        }
    }
    
    /*let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.client.unsubscribeFromChannel("/awesome")
    }*/
    
    
    DispatchQueue.main.asyncAfter(deadline : .now() + (5 *  0.1)) {
        let model = FayeSubscriptionModel(subscription: "messages", clientId: nil)
        
        _ = self.client.subscribeToChannel(model, block: { [unowned self] messages in
            print("awesome response: \(messages)")
            
            self.client.sendPing("Ping".data(using: .utf8 )!, completion: {
                print("got pong")
            })
        })
    }
    
    /*dispatch_after(delayTime, dispatch_get_main_queue()) {
      let model = FayeSubscriptionModel(subscription: "/awesome", clientId: nil)
        
      self.client.subscribeToChannel(model, block: { [unowned self] messages in
        print("awesome response: \(messages)")
        
        self.client.sendPing("Ping".dataUsingEncoding(NSUTF8StringEncoding)!, completion: {
          print("got pong")
        })
      })
    }*/
  }
    
  // MARK:
  // MARK: TextfieldDelegate

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    client.sendMessage(["text" : textField.text as Any], channel: "messages")
    return false;
  }
    
  // MARK:
  // MARK: FayeClientDelegate
  
  func connectedtoser(client: FayeClient) {
    print("Connected to Faye server")
  }
  
  func connectionFailed(client: FayeClient) {
    print("Failed to connect to Faye server!")
  }
  
  func disconnectedFromServer(client: FayeClient) {
    print("Disconnected from Faye server")
  }
  
  func didSubscribeToChannel(client: FayeClient, channel: String) {
    print("Subscribed to channel \(channel)")
  }
  
  func didUnsubscribeFromChannel(client: FayeClient, channel: String) {
    print("Unsubscribed from channel \(channel)")
  }
  
  func subscriptionFailedWithError(client: FayeClient, error: subscriptionError) {
    print("Subscription failed")
  }
  
  func messageReceived(client: FayeClient, messageDict: NSDictionary, channel: String) {
    let text: Any? = messageDict["text"]
    print("Here is the message: \(text)")
  }
  
  func pongReceived(client: FayeClient) {
    print("pong")
  }
}
