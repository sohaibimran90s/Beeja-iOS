//
//  WWMSpotifyManager.swift
//  Meditation
//
//  Created by Akram Khan on 05/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMSpotifyManager: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, SPTAppRemoteUserAPIDelegate
 {

    static let sharedManager = WWMSpotifyManager()
    
    fileprivate var currentPodcastSpeed: SPTAppRemotePodcastPlaybackSpeed?

    fileprivate let redirectUri = URL(string:"beeja-med-test-app://beeja-med-test-callback")!
    fileprivate let clientIdentifier = "2fd82c511bd74915b2b16ff1903eeb2b"
    fileprivate let name = "spotify"
    static fileprivate let kAccessTokenKey = "access-token-key"
    
    @objc dynamic var currentPlaylist: [Dictionary<String, Any>]?
    
    var alertPopupView = WWMAlertController()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: WWMSpotifyManager.kAccessTokenKey)
            defaults.synchronize()
        }
    }

    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url);
        // SPTPlaylistReadPrivateScope
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            playerViewController.showError(error_description);
        }
        
        return true
    }
    
    func getPlaylists() {
        let url = URL(string: "https://api.spotify.com/v1/me/playlists")
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + self.accessToken!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let urlSession = URLSession(configuration: .default)
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? Dictionary<String,Any>
                {
                    self.currentPlaylist = jsonDict["items"] as! [Dictionary<String, Any>]
                    
                    
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    func connect() {
        appRemote.connect()
    }
    
    
    // MARK: AppRemoteDelegate
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
     
        getPlaylists()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")

    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")

    }
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {

    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        self.playerState = playerState
    }
    
    func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }
    
    func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }
    
    func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
    func playTrack() {
//        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
    
    func enqueueTrack() {
//        appRemote.playerAPI?.enqueueTrackUri(trackIdentifier, callback: defaultCallback)
    }
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {

                }
            }
        }
    }
    
    func authorize() -> Bool {
        if !(appRemote.isConnected) {
            print("Spotify authenticate")
            if (!appRemote.authorizeAndPlayURI("")) {
                
                
                
                alertPopupView = UINib(nibName: "WWMAlertController", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMAlertController
                let window = UIApplication.shared.keyWindow!
                
                alertPopupView.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
                alertPopupView.btnOK.layer.borderWidth = 2.0
                alertPopupView.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
                
                alertPopupView.lblTitle.text = kAlertTitle
                alertPopupView.lblSubtitle.text = "Oops. You need to install the Spotify app."
               // alertPopupView.btnClose.isHidden = true
                
                alertPopupView.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
                window.rootViewController?.view.addSubview(alertPopupView)
                
                
                
                
//                let alert = UIAlertController(title: kAlertTitle,
//                                              message: "Spotify App not installed.\nDownload from App Store?",
//                                              preferredStyle: UIAlertController.Style.alert)
//
//
//                let okAction = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) in
//                    let url = URL.init(string: "https://itunes.apple.com/us/app/spotify-music-and-podcasts/id324684580?mt=8")
//                    let application = UIApplication.shared
//                    if  application.canOpenURL(url!) {
//                        application.open(url!, options: [:], completionHandler: nil)
//                    }
//                }
//                let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (UIAlertAction) in
//                    //https://itunes.apple.com/us/app/spotify-music-and-podcasts/id324684580?mt=8
//                }
//
//                alert.addAction(cancelAction)
//                alert.addAction(okAction)
//
//                UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
                
                
                
                // The Spotify app is not installed, present the user with an App Store page
            }
            return false
        }
        return true
    }
    
   
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let url = URL.init(string: "https://itunes.apple.com/us/app/spotify-music-and-podcasts/id324684580?mt=8")
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }
    }
}
