//
//  PubNubHandler.swift
//  SikkaNet2
//
//  Created by Narendra Kumar on 5/29/16.
//  Copyright © 2016 Kvana. All rights reserved.
//

import Foundation
import PubNub

protocol PubNubDelagate {
    func didReceiveMessage(message: AnyObject)
}

struct PubNubConfig {

    static let PUBLISH_KEY = "pub-c-1454bbf1-3a7c-4f55-ba32-37ce6414879b"
    static let SUBSCRIBE_KEY = "sub-c-e681ba2c-969b-11e6-94c7-02ee2ddab7fe"
}

class PubNubHandler: NSObject, PNObjectEventListener {
    static var sharedManager = PubNubHandler()
    
    static let senderChannel = "valli"
    static let receiverChannel = "vinod"

    
    var client: PubNub?
    var delegate : PubNubDelagate?
    func setupConfig(authKey : String) {
        let configuration = PNConfiguration(publishKey: PubNubConfig.PUBLISH_KEY, subscribeKey: PubNubConfig.SUBSCRIBE_KEY)
        configuration.authKey=authKey
        configuration.uuid=authKey
        configuration.shouldRestoreSubscription = true
        client = PubNub.clientWithConfiguration(configuration)
        client?.addListener(self)
        client?.subscribeToChannels([authKey], withPresence: true)
        
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
           // if isOnChannel(channelName){
                self.delegate?.didReceiveMessage(message: message.data.message! as AnyObject)
    }
    
    

    
    func client(client: PubNub, didReceiveStatus status: PNStatus) {
        print(status)
    }
    
    
    func publishMessageOnChannel(message : AnyObject!, channel : String!) {
        client?.publish(message, toChannel: channel, withCompletion: { (status) in
            print(status)
        })
    }

}
