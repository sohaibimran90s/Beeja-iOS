//
//  WWMCommunityVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 17/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit
import SDWebImage

import SafariServices
@_exported import AVFoundation

class WWMCommunityVC: WWMBaseViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SPTAudioStreamingPlaybackDelegate,SPTAudioStreamingDelegate {
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var accessToken: String!
    @objc dynamic var currentPlaylist: [Dictionary<String, Any>]?
    var playerAV = AVAudioPlayer()
    var isChangingProgress: Bool = false
    var playListURIToBePlay: String!
    var isPlaying = false
    
    var communityData = WWMCommunityData()
    var observers = [NSKeyValueObservation]()
    
    @IBOutlet weak var tblViewCommunity: UITableView!
    var strMonthYear = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyyMM"
        self.strMonthYear = dateFormatter.string(from: Date())
        self.getCommunityAPI()
        self.setUpNavigationBarForDashboard(title: "Community")
        // Do any additional setup after loading the view.
        
        
        
        accessToken = "Not Assigned"
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        CallingFuncs()
        
        
        /*
         self.observers = [
         WWMSpotifyManager.sharedManager.observe(\.currentPlaylist, options: [.initial]) { [weak self] (playlist, change) in
         
         DispatchQueue.main.async{
         //put your code here
         self?.tblViewCommunity.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
         }
         
         
         }
         
         ]*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func CallingFuncs()
    {
        if UIApplication.shared.canOpenURL(loginUrl!){
            UIApplication.shared.open(loginUrl!, options: [:]) { (Bool) in
                if (self.auth.canHandle(self.auth.redirectURL)){
                    
                }
            }
            
        }
    }
    
    func setup() {
        
        let redirectURL = "Beeja-App://GetPlayList" // put your redirect URL here
        let clientID = "2fd82c511bd74915b2b16ff1903eeb2b" // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = "2fd82c511bd74915b2b16ff1903eeb2b"
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        //searchButtn.alpha = 0
    }
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            print("spotify token %@",authSession.accessToken)
            accessToken = authSession.accessToken
            self.getPlaylists()
            DispatchQueue.main.async{
                //put your code here
                
                print(self.accessToken)
                self.isPlaying = true
                self.tblViewCommunity.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }
        
    }
    
    @objc func updateAfterFirstLogin () {
        
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
        }
        
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
                    print(String(data: try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted), encoding: .utf8 )!)
                    
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    // MARK:- UITable View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.communityData.events.count == 0 {
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = WWMCommunityTableViewCell()
        if self.communityData.events.count == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellFirst") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewSpotifyAction(_:)), for: .touchUpInside)
                
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellThird") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnUploadHashTagsAction(_:)), for: .touchUpInside)
            }
            cell.collectionViewCommunity.tag = indexPath.row
            cell.collectionViewCommunity.reloadData()
            return cell
        }else {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellFirst") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewSpotifyAction(_:)), for: .touchUpInside)
                
            }else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellSecond") as! WWMCommunityTableViewCell
                if self.communityData.events.count < 3 {
                    cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)/2
                }
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-14)
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnViewAllEventsAction(_:)), for: .touchUpInside)
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CellThird") as! WWMCommunityTableViewCell
                cell.layoutCollectionviewHeight.constant = (self.view.frame.size.width-8)/2.5
                cell.btnSpotifyPlayList.addTarget(self, action: #selector(btnUploadHashTagsAction(_:)), for: .touchUpInside)
            }
            cell.collectionViewCommunity.tag = indexPath.row
            cell.collectionViewCommunity.reloadData()
            return cell
        }
    }
    
    
    // MARK:- UICollection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.communityData.events.count == 0 {
            if collectionView.tag == 1 {
                if self.communityData.hashtags.count > 6 {
                    return 6
                }
                return self.communityData.hashtags.count
            }else {
                print(self.currentPlaylist?.count ?? 0)
                return self.currentPlaylist?.count ?? 0
            }
        }else {
            if collectionView.tag == 1 {
                if self.communityData.events.count > 4 {
                    return 4
                }
                return self.communityData.events.count
            }else if collectionView.tag == 2 {
                if self.communityData.hashtags.count > 6 {
                    return 6
                }
                return self.communityData.hashtags.count
            }else {
                return self.currentPlaylist?.count ?? 0
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = WWMCommunityCollectionViewCell()
        if self.communityData.events.count == 0 {
            if collectionView.tag == 0 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let playlist = self.currentPlaylist![indexPath.row]
                cell.lblTitle.text = playlist["name"] as? String
                let images = playlist["images"] as! [Dictionary<String, Any>]
                for imageDictionary in images {
                    
                    let imageUrl = imageDictionary["url"] as! String
                    print("\(imageUrl)")
                    cell.imgView.sd_setImage(with: URL.init(string: imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                    
                    /*  if let imageSize = imageDictionary["height"] as? Int {
                     if imageSize == 640 {
                     let imageUrl = imageDictionary["url"] as! String
                     print("\(imageUrl)")
                     cell.imgView.sd_setImage(with: URL.init(string: imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                     }
                     }*/
                    
                }
            }else if collectionView.tag == 1 {
                if indexPath.row == 5 {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellMore", for: indexPath) as! WWMCommunityCollectionViewCell
                    return cell
                }
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.hashtags[indexPath.row]
                cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            }
        }else {
            if collectionView.tag == 0 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyCell", for: indexPath) as! WWMCommunityCollectionViewCell
                
                let playlist = self.currentPlaylist![indexPath.row]
                cell.lblTitle.text = playlist["name"] as? String
                let images = playlist["images"] as! [Dictionary<String, Any>]
                for imageDictionary in images {
                    
                    let imageUrl = imageDictionary["url"] as! String
                    print("\(imageUrl)")
                    cell.imgView.sd_setImage(with: URL.init(string: imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                }
                
            }else if collectionView.tag == 1 {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.events[indexPath.row]
                
                cell.imgView.sd_setImage(with: URL.init(string: data.imageUrl), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
                cell.lblTitle.text = data.eventTitle
                
            }else if collectionView.tag == 2 {
                if indexPath.row == 5 {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellMore", for: indexPath) as! WWMCommunityCollectionViewCell
                    return cell
                }
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "#TagCell", for: indexPath) as! WWMCommunityCollectionViewCell
                let data = self.communityData.hashtags[indexPath.row]
                cell.imgView.sd_setImage(with: URL.init(string: data.url), placeholderImage: UIImage.init(named: "AppIcon"), options: .scaleDownLargeImages, completed: nil)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.communityData.events.count == 0 {
            if collectionView.tag == 0 {
                let playlist = self.currentPlaylist![indexPath.row]
                print("\(playlist)")
                
                print(String(data: try! JSONSerialization.data(withJSONObject: playlist, options: .prettyPrinted), encoding: .utf8 )!)
                
                playListURIToBePlay = playlist["uri"] as? String
                print(isPlaying)
                if (isPlaying == true)
                {
                    isPlaying = false
                    self.handleNewSession()
                }
                else{
                    isPlaying = true
                    
                    SPTAudioStreamingController.sharedInstance().setIsPlaying(!SPTAudioStreamingController.sharedInstance().playbackState.isPlaying, callback: nil)
                    
                    //self.closeSession()
                    
                    
                    
                }
            }else if collectionView.tag == 1 {
                if indexPath.row == 5 {
                    let data = self.communityData.hashtags
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMCommunityAllHashTagsVC") as! WWMCommunityAllHashTagsVC
                    vc.arrAllHashTag = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            if collectionView.tag == 0 {
                let playlist = self.currentPlaylist![indexPath.row]
                print("\(playlist)")
                
                print(String(data: try! JSONSerialization.data(withJSONObject: playlist, options: .prettyPrinted), encoding: .utf8 )!)
                
                playListURIToBePlay = playlist["uri"] as? String
                print(isPlaying)
                if (isPlaying == true)
                {
                    isPlaying = false
                    self.handleNewSession()
                }
                else{
                    isPlaying = true
                    
                    SPTAudioStreamingController.sharedInstance().setIsPlaying(!SPTAudioStreamingController.sharedInstance().playbackState.isPlaying, callback: nil)
                    
                    //self.closeSession()
                    
                    
                    
                }
            }else if collectionView.tag == 1 {
                let data = self.communityData.events[indexPath.row]
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWebViewVC") as! WWMWebViewVC
                
                vc.strUrl = data.url
                vc.strType = data.eventTitle
                self.navigationController?.pushViewController(vc, animated: true)
            }else if collectionView.tag == 2 {
                
                if indexPath.row == 5 {
                    let data = self.communityData.hashtags
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMCommunityAllHashTagsVC") as! WWMCommunityAllHashTagsVC
                    vc.arrAllHashTag = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.communityData.events.count > 0 {
            if collectionView.tag == 1 {
                let width = (self.view.frame.size.width-14)/2
                return CGSize.init(width: width, height: width)
            }
        }
        
        let width = (self.view.frame.size.width-8)/2.5
        return CGSize.init(width: width, height: width)
    }
    
    
    @IBAction func btnViewSpotifyAction(_ sender: Any) {
        let url = URL.init(string: "spotify:")
        let application = UIApplication.shared
        if  application.canOpenURL(url!) {
            application.open(url!, options: [:], completionHandler: nil)
        }else {
            
        }
    }
    
    @IBAction func btnViewAllEventsAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMCommunityAllEventsVC") as! WWMCommunityAllEventsVC
        vc.arrAllEvent = self.communityData.events
        self.navigationController?.pushViewController(vc, animated: true)
    }
    var imageData = Data()
    @IBAction func btnUploadHashTagsAction(_ sender: Any) {
        
        print("btnUploadHashTagsAction detect")
        let ImagePickerManager = WWMImagePickerManager()
        ImagePickerManager.pickImage(self){ image in
            //here is the image
            self.imageData = image.jpegData(compressionQuality: 0.75)!
            
            print("%@",self.imageData)
            self.uploadHashtagAPI()
            print("Get Image Data")
        }
    }
    
    
    func uploadHashtagAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_Id":self.appPreference.getUserID(),
            "type" : "Image",
            "tagname":"#meditationanywhere"
            ] as [String : Any]
        
        WWMWebServices.formRequestApiWithBody(param: param, urlString: URL_UPLOADHASHTAG, imgData: self.imageData, isHeader: true) { (result, error, success) in
            if success {
                print(result)
            }else {
                if error != nil {
                    
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                    }
                    
                }
            }
            WWMHelperClass.dismissSVHud()
        }
        
    }
    
    
    func getCommunityAPI() {
        WWMHelperClass.showSVHud()
        let param = [
            "user_Id":self.appPreference.getUserID(),
            "month":self.strMonthYear
            ] as [String : Any]
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_COMMUNITYDATA, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                self.communityData = WWMCommunityData.init(json: result["result"] as! [String : Any])
                self.tblViewCommunity.reloadData()
            }else {
                if error != nil {
                    WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                }
            }
            WWMHelperClass.dismissSVHud()
        }
    }
    
    
    func handleNewSession() {
        self.closeSession()
        do {
            AuthService.instance.sessiontokenId = accessToken
            print(AuthService.instance.sessiontokenId)
            print(SPTAuth.defaultInstance().clientID)
            
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            SPTAudioStreamingController.sharedInstance().delegate = self
            SPTAudioStreamingController.sharedInstance().playbackDelegate = self
            SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: AuthService.instance.sessiontokenId ?? "")
        } catch let error {
            let alert = UIAlertController(title: "Error init", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: {})
            self.closeSession()
        }
    }
    
    func closeSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
            SPTAuth.defaultInstance().session = nil
            // _ = self.navigationController!.popViewController(animated: true)
        } catch let error {
            let alert = UIAlertController(title: "Error deinit", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { })
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: {  })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        if isPlaying {
            self.activateAudioSession()
        }
        else {
            self.deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent, withName name: String) {
        print("didReceivePlaybackEvent: \(event) \(name)")
        print("isPlaying=\(SPTAudioStreamingController.sharedInstance().playbackState.isPlaying) isRepeating=\(SPTAudioStreamingController.sharedInstance().playbackState.isRepeating) isShuffling=\(SPTAudioStreamingController.sharedInstance().playbackState.isShuffling) isActiveDevice=\(SPTAudioStreamingController.sharedInstance().playbackState.isActiveDevice) positionMs=\(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        
        print("didReceiveError: \(error!.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        
        if self.isChangingProgress {
            return
        }
        let positionDouble = Double(position)
        let durationDouble = Double(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.duration)
        //self.progressSlider.value = Float(positionDouble / durationDouble)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Starting \(trackUri)")
        print("Source \(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceUri)")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri.contains("spotify:track") && !(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri == trackUri)
        print("Relinked \(isRelinked)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finishing: \(trackUri)")
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        let playListRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: AuthService.instance.sessionuserId ?? "", withAccessToken: AuthService.instance.sessiontokenId ?? "")
        
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(playListURIToBePlay, startingWith: 0, startingWithPosition: 1) { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            }
        }
    }
    
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
}
