//
//  ViewController.swift
//  VirgilTestApp
//
//  Created by Narendra Kumar Rangisetty on 10/17/16.
//  Copyright © 2016 Narendra. All rights reserved.
//

import UIKit

class ViewController: UIViewController,PubNubDelagate {

    private var client: VSSClient! = nil

    @IBOutlet weak var aTF: UITextField!
    
    @IBOutlet weak var bTF: UITextField!
    @IBOutlet weak var decrptedTFB: UILabel!
    
    @IBOutlet weak var encryptedTFB: UILabel!
    var privateKey:VSSPrivateKey?
    @IBOutlet weak var decryptedTFA: UILabel!
    var othersCard: VSSCard?
    @IBOutlet weak var encryptedTFA: UILabel!
    let kVirgilApplicationToken = "AT.8cd3b286c2382a208735648c412dcdd9aa98a7aaacdf35cfc10646ee3df71a56"
    let kVirgilApplicationPrivateKey: String = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIGhMF0GCSqGSIb3DQEFDTBQMC8GCSqGSIb3DQEFDDAiBBDfB0CZjbRbTOD/WQlx\nhTltAgIfSTAKBggqhkiG9w0CCjAdBglghkgBZQMEASoEEKEV6/nls/p5F1oLKg2q\nkkcEQP79vzPRSf5N6D6aoTsM2OPRYXlstniBmMBUD0/ujILx7Y3k0rle9JCA9/Be\nVjXiDqNd3Y1UFANgvsminv9v+nk=\n-----END ENCRYPTED PRIVATE KEY-----\n"
    let kPrivateKeyPassword = "1"
    
    var card:VSSCard?
    override func viewDidLoad() {
        super.viewDidLoad()
        PubNubHandler.sharedManager.delegate = self
        self.client = VSSClient(applicationToken:kVirgilApplicationToken)
        let keyPair = VSSKeyPair(password:nil)
        privateKey = VSSPrivateKey(key: keyPair.privateKey(), password: nil)
        
        
        let identity = VSSIdentityInfo(type: "user-id-card", value: "vinod", validationToken: nil)

        self.client.createCard(withPublicKey: keyPair.publicKey(),
                                            identityInfo: identity,
                                            data: nil,
                                            privateKey: privateKey!) { (card, error) -> Void in
                                                if error != nil {
                                                    print(error)
                                                    // Handle error for creation of the Virgil Card.
                                                    return
                                                }
                                                self.card = card
                                                // VSSCard card represents Virgil Card.
                                                //...
        }
        
        self.client.searchCard(withIdentityValue: PubNubHandler.receiverChannel, type: "user-id-card", unauthorized: false) { (cards, error) in
            self.othersCard = cards?.first
        }
    }
    func didReceiveMessage(message: AnyObject) {
        
        print(message)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendActionA(_ sender: AnyObject) {
        PubNubHandler.sharedManager.publishMessageOnChannel(message: aTF.text as AnyObject!, channel: PubNubHandler.receiverChannel)
        
        let v = getEncryptedData(text: aTF.text!)
        
       

    }
    
    @IBAction func sendActionB(_ sender: AnyObject) {
    }
    
    func getEncryptedData(text: String) -> String?{
        var encrytedData = NSData()
        if let plainData = text.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let cryptor = VSSCryptor()
            do {
                try cryptor.addKeyRecipient((self.othersCard?.id)!, publicKey: (self.othersCard?.publicKey.key)!, error: ())
                try cryptor.addKeyRecipient((self.card?.id)!, publicKey: (self.card?.publicKey.key)!, error: ())

                encrytedData = try cryptor.encryptData(plainData, embedContentInfo: true, error: ()) as NSData
                
                 let result = try? cryptor.decryptData(encrytedData as Data, recipientId: self.card!.id, privateKey: (self.privateKey?.key)!, keyPassword: self.privateKey?.password, error: ())
                print(NSString(data: result!, encoding: String.Encoding.utf8.rawValue))
                /// Update UI Controls
                return encrytedData.base64EncodedString(options: .lineLength64Characters)
            }
            catch let error as NSError {
                print("Encryption error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
