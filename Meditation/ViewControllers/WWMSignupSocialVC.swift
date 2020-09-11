//
//  WWMSignupSocialVC.swift
//  Meditation
//
//  Created by Prashant Tayal on 25/08/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import Lottie
import FirebaseCrashlytics
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices

class WWMSignupSocialVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var viewStartBeeja: UIView!
    @IBOutlet weak var lblSignup: UILabel!
    @IBOutlet weak var imgSignup: UIImageView!
    @IBOutlet weak var viewLottieAnimation: UIView!
    
    var animationView = AnimationView()
    let appPreference = WWMAppPreference()
    var pushToLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblSignup.textColor = UIColor.white
        self.imgSignup.image = UIImage.init(named: "startBeeja_Icon")
        self.viewStartBeeja.backgroundColor = UIColor.clear
        viewStartBeeja.layer.borderWidth = 2.0
        viewStartBeeja.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
    }
    
    @IBAction func clickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickLogin() {
        if pushToLogin {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
                   self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnSignupTouchDown(_ sender: Any) {
        animationView.stop()
        self.viewLottieAnimation.isHidden = true
        self.imgSignup.isHidden = false
        self.viewStartBeeja.backgroundColor = UIColor(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        viewStartBeeja.layer.borderColor = UIColor.clear.cgColor
        self.lblSignup.textColor = UIColor.black
        self.imgSignup.image = UIImage.init(named: "iconToAnimateCopy2")
    }
    
    @IBAction func btnSignupTouchupInside() {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "START_BEEJA", itemName: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        WWMHelperClass.loginSignupBool = false
    }
    
    //MARK: Animate View
    @objc func animateView(){
        animationView.stop()
    }
    
    //Apple button
    @IBAction func AppleButtonTapped() {
        let authorizationProvider = ASAuthorizationAppleIDProvider()
        let request = authorizationProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //Facebook button
    @IBAction func FacebookButtonTapped() {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "FACEBOOK", itemName: "")
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (loginResult, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            }else {
                if (loginResult?.isCancelled)! {
                    //print("User Cancellled To login with fb")
                }else {
                    let req = GraphRequest.init(graphPath: "me", parameters: ["fields":"email,name"], tokenString:loginResult?.token?.tokenString , version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                    req.start(completionHandler: { (connection, result, error) in
                        if error == nil {
                            print(result!)
                            if let fbData = result as? [String:Any] {
                                if let fbEmail = fbData["email"] as? String {
                                    
                                    let param = [
                                        "email": fbEmail,
                                        "password":"",
                                        "deviceId": kDeviceID,
                                        "DeviceType": kDeviceType,
                                        "deviceToken" : self.appPreference.getDeviceToken(),
                                        "loginType": kLoginTypeFacebook,
                                        "profile_image":"http://graph.facebook.com/\(fbData["id"] ?? "")/picture?type=large",
                                        "socialId":"\(fbData["id"] ?? "")",
                                        "name":"\(fbData["name"] ?? "")",
                                        "model": UIDevice.current.model,
                                        "version": UIDevice.current.systemVersion
                                    ]
                                    
                                    //print("param facebook... \(param)")
                                    
                                    self.loginWithSocial(param: param as Dictionary<String, Any>)
                                }else {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignUpFacebookVC") as! WWMSignUpFacebookVC
                                    vc.fbData = fbData
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }else {
                            print(error?.localizedDescription ?? "")
                        }
                    })
                }
            }
        }
    }
    
    //Google button
    @IBAction func GoogleButtonTapped(_ sender: UIButton) {
        WWMHelperClass.sendEventAnalytics(contentType: "SIGN_IN", itemId: "GOOGLE", itemName: "")
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    // Google Login Delegate Method
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            // let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            // let givenName = user.profile.givenName
            // let familyName = user.profile.familyName
            let email = user.profile.email
            let profileImage = user.profile.imageURL(withDimension: 400)
            let param = [
                "email": email,
                "password":"",
                "deviceId": kDeviceID,
                "DeviceType": kDeviceType,
                "deviceToken" : self.appPreference.getDeviceToken(),
                "loginType": kLoginTypeGoogle,
                "profile_image":profileImage?.absoluteString,
                "socialId":userId,
                "name":fullName,
                "model": UIDevice.current.model,
                "version": UIDevice.current.systemVersion
            ]
            
            self.loginWithSocial(param: param as Dictionary<String, Any>)
        }
    }
    
    func loginWithSocial(param:[String : Any]) {
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_LOGIN, context: "WWMLoginVC", headerType: kPOSTHeader, isUserToken: false) { (result, error, sucess) in
            if sucess {
                //print("result.... \(result)")
                if let userProfile = result["userprofile"] as? [String:Any] {
                    //print("userProfile WWMLoginVC... \(userProfile)")
                    
                    if let isProfileCompleted = userProfile["IsProfileCompleted"] as? Bool {
                        self.appPreference.setIsLogin(value: true)
                        self.appPreference.setUserID(value:"\(userProfile["user_id"] as? Int ?? 0)")
                        //Crashlytics.sharedInstance().setUserIdentifier("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        Crashlytics.crashlytics().setUserID("userId \(userProfile["user_id"] as? Int ?? 0)")
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutSuccessful"), object: nil)
                        
                        self.appPreference.setEmail(value: userProfile["email"] as? String ?? "")
                        self.appPreference.setUserToken(value: userProfile["token"] as? String ?? "Unauthorized request")
                        self.appPreference.setUserName(value: userProfile["name"] as? String ?? "Unauthorized request")
                        self.appPreference.setIsProfileCompleted(value: isProfileCompleted)
                        self.appPreference.setType(value: userProfile["type"] as? String ?? "")
                        self.appPreference.setGuideType(value: userProfile["guided_type"] as? String ?? "")
                        self.appPreference.setGuideTypeFor3DTouch(value: userProfile["guided_type"] as? String ?? "")
                        if isProfileCompleted {
                            self.appPreference.setGetProfile(value: true)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                        }else {
                            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMConOnboardingVC") as! WWMConOnboardingVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    GIDSignIn.sharedInstance()?.signOut()
                    WWMHelperClass.showPopupAlertController(sender: self, message: result["message"] as? String ?? "Unauthorized request", title: kAlertTitle)
                }
                
            }else {
                GIDSignIn.sharedInstance()?.signOut()
                if error != nil {
                    if error?.localizedDescription == "The Internet connection appears to be offline."{
                        WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                    }else{
                        WWMHelperClass.showPopupAlertController(sender: self, message: error?.localizedDescription ?? "", title: kAlertTitle)
                    }
                    
                }
                
            }
            //WWMHelperClass.dismissSVHud()
            WWMHelperClass.hideLoaderAnimate(on: self.view)
        }
    }
}


extension WWMSignupSocialVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        let userIdentifier = appleIDCredential.user
        let userFirstName = appleIDCredential.fullName?.givenName
        let userLastName = appleIDCredential.fullName?.familyName
        let userEmail = appleIDCredential.email
        let fullname = (userFirstName ?? "") + " " + (userLastName ?? "")
        
        UserDefaults.standard.set(userIdentifier, forKey: "apple_id")
        
        if appleIDCredential.fullName != nil {
            UserDefaults.standard.set(fullname, forKey: "apple_fullname")
        }
        if userEmail != nil {
            UserDefaults.standard.set(userEmail, forKey: "apple_email")
        }
        
        print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.email))")
        
        self.loginWithApple()

    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
    
    func loginWithApple() {
        let email = UserDefaults.standard.string(forKey: "apple_email")
        let userId = UserDefaults.standard.string(forKey: "apple_id")
        let fullName = UserDefaults.standard.string(forKey: "apple_fullname")
        
        let param = [
            "email": email,
            "password":"",
            "deviceId": kDeviceID,
            "DeviceType": kDeviceType,
            "deviceToken" : self.appPreference.getDeviceToken(),
            "loginType": kLoginTypeApple,
            "profile_image":"",
            "socialId":userId,
            "name":fullName,
            "model": UIDevice.current.model,
            "version": UIDevice.current.systemVersion
        ]
        
        self.loginWithSocial(param: param as Dictionary<String, Any>)
    }
}

extension WWMSignupSocialVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
