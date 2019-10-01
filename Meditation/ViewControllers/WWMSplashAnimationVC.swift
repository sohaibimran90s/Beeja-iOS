//
//  WWMSplashAnimationVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 03/12/18.
//  Copyright © 2018 Cedita. All rights reserved.
//

import UIKit

class WWMSplashAnimationVC: WWMBaseViewController {

    @IBOutlet weak var lblSplashTxt: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var splashtapGesture = UITapGestureRecognizer()
    var isNext =  false
    var imageTag = 0
    var i = 0
    
//    let arrSplashtxt = ["be more aware","be more radical","be a better friend","partner","lover"]
    
    let arrFirstTimeUserSplashtxt = ["be more aware","be more human","be a better friend","partner","lover"]
    let arrFirstTimeUserImage = ["Background_Splash1","Background_Splash1","Background_Splash2","Background_Splash3","Background_Splash4","Background_Splash5"]
    let arrSecondTimeUserSplashTxt = ["Nice to see you","To see you nice","lets get to it","and inject some spice"]
    
    let arrOccasionUserSplash = ["Great to see you back!","Elevate your life / experience","keep the good vibes going","There's extraordinary in all of us","Live life in high definition"]
    
    var arrViewSplashTxt = [String]()
    var currentIndex = 0
    var arrData1:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        splashtapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnSplash(_:)))
        splashtapGesture.delegate = self as? UIGestureRecognizerDelegate
        self.imgView.isUserInteractionEnabled = true
        self.imgView.tag = currentIndex
        self.imgView.addGestureRecognizer(splashtapGesture)
        
        self.setNavigationBar(isShow: false, title: "")
        self.setUp()
    }
    
    @objc func handleTapOnSplash(_ sender: AnyObject){
        print("splash current index.... \(sender.view.tag)")
        
        self.arrData1 = self.arrViewSplashTxt
        imageTag = sender.view.tag
        if sender.view.tag == arrData1.count - 1 {
            self.moveToInitialVC()
            return
        }
        
        UIView.animate(withDuration: 0.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
            
            if sender.view.tag == self.arrData1.count - 1 {
                self.moveToInitialVC()
                return
            }
            self.lblSplashTxt.alpha = 1.0
            self.imageTag += 1
            self.i = 1
            
        }) { (_) in
            
            self.lblSplashTxt.text = self.arrData1[self.imageTag]
            self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage[self.imageTag+1])
            self.imgView.tag = self.imageTag
            
            UIView.animate(withDuration: 0.0, animations: {
                self.lblSplashTxt.alpha = 1.0
            }, completion: { (_) in
                if sender.view.tag == self.arrData1.count - 1 {
                    self.moveToInitialVC()
                }else{
                    self.showSplashAnimatedWord(arrData: self.arrData1)
                }
            })
        }
    }
    
    func setUp() {
        
        self.arrViewSplashTxt = []
        let days = Calendar.current.dateComponents([.day], from: self.appPreference.lastLoginDate(), to: Date()).day ?? 0
        if !self.appPreference.isFirstTimeSplash() {
            self.appPreference.setIsFirstTimeSplash(value: true)
            self.arrViewSplashTxt = self.getFirstTimeUserSplashTxt()
            
        }else if !self.appPreference.isSecondTimeSplash() {
            self.appPreference.setIsSecondTimeSplash(value: true)
            self.arrViewSplashTxt = self.arrSecondTimeUserSplashTxt
        }else if days > 2{
            self.arrViewSplashTxt = self.getOccassionalUserSplashTxt()
        }else {
            self.arrViewSplashTxt = self.getDailyUserSplashTxt()
        }
        
        self.appPreference.setLastLoginDate(value: Date())
        
        if self.arrViewSplashTxt.count > 0 {
            self.imgView.tag = currentIndex
            self.lblSplashTxt.text = self.arrViewSplashTxt.first
            self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage[currentIndex])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showSplashAnimatedWord(arrData: self.arrViewSplashTxt)
        }
    }
    
    func showSplashAnimatedWord(arrData:[String]) {
        self.arrData1 = arrData
        if currentIndex == arrData.count - 1 {
            self.moveToInitialVC()
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .transitionCrossDissolve, animations: {
            self.lblSplashTxt.alpha = 0.0
            
            if self.i == 0{
                self.currentIndex += 1
            }else{
                self.currentIndex = self.imageTag
            }
            self.i = 0
            
           /* self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage[self.currentIndex])*/
        }) { (_) in
            self.lblSplashTxt.text = arrData[self.currentIndex]
            self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage[self.currentIndex+1])
            self.imgView.tag = self.currentIndex
            
            UIView.animate(withDuration: 0.5, animations: {
                self.lblSplashTxt.alpha = 1.0
            }, completion: { (_) in
                self.showSplashAnimatedWord(arrData: arrData)
            })
        }
        
//        UIView.animateWithDuration(self.lblSplashTxt, delay: 1, options: .transitionCrossDissolve, animations: { () -> Void in
//            self.label.alpha = 0.0
//        }) { (_) -> Void in
//            self.label.text = self.words[++self.currentIndex]
//            UIView.animateWithDuration(1, animations: { () -> Void in
//                self.label.alpha = 1.0
//            }, completion: { (_) -> Void in
//                self.showNextWord()
//            })
//        }
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        for (index, element) in arrSplashtxt.enumerated() {
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.splashTextChangeAnimation(index: index, txt: element)
//            }
//        }
//    }
    
    func splashTextChangeAnimation(index:Int,txt:String) -> Void {
        
        UIView.transition(with: self.lblSplashTxt, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.lblSplashTxt.text = txt
        }) { (isComplete) in
            if index == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.moveToInitialVC()
                }
            }
        }
    }
    
    func moveToInitialVC() -> Void {
        
        if !isNext {
            isNext = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.lblSplashTxt.alpha = 0.0
                
                if self.appPreference.isLogin() {
                    if !self.appPreference.isProfileComplete() {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if self.appPreference.isLogout() {
                        if #available(iOS 13.0, *) {
                            let vc = self.storyboard?.instantiateViewController(identifier: "WWMTabBarVC") as! WWMTabBarVC
                            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                            window?.rootViewController = vc
                        } else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }else if self.appPreference.isLogout() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                    self.navigationController?.pushViewController(vc, animated: false)
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                
                
                
                
                
                
                
                
                
                
                //                if self.appPreference.isLogin() {
                //                    if self.appPreference.isLogout() {
                //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                //                        UIApplication.shared.keyWindow?.rootViewController = vc
                //
                //                    }else {
                //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                //                        self.navigationController?.pushViewController(vc, animated: true)
                //                    }
                //
                //                }else if self.appPreference.isLogout() {
                //                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMWelcomeBackVC") as! WWMWelcomeBackVC
                //                            self.navigationController?.pushViewController(vc, animated: false)
                //
                //                }else {
                //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginVC") as! WWMLoginVC
                //                        self.navigationController?.pushViewController(vc, animated: false)
                //                }
            }
        }
        
        
    }
    
    func getDailyUserSplashTxt() -> [String] {
        
        self.arrViewSplashTxt = []
       
        let randomInt = Int.random(in: 0..<5)
        var arrDailyUser = [String]()
        switch randomInt {
        case 0:
            arrDailyUser = ["Buongiorno!","Loving your dedication","Let the good times roll"]
        case 1:
            arrDailyUser = ["Hola!","Hope you're feeling tip top 🙂","Keep up the good work"]
        case 2:
            arrDailyUser = ["Get ready!","Get steady!","Let's get ready to rumble","Let's dive in"]
            //"Let's get ready to rumble"(UK only)
        case 3:
            arrDailyUser = ["Beeja up baby!","Let's continue the good vibes"]
        case 4:
            arrDailyUser = ["It's Beeja time","Sit back","Relax","This is for you"]
        default:
            arrDailyUser = [""]
        }
        return arrDailyUser
    }
    
    func getFirstTimeUserSplashTxt() -> [String] {
        let randomInt = Int.random(in: 0..<5)
        var arrDailyUser = [String]()
        switch randomInt {
        case 0:
            arrDailyUser = ["Young of heart","Wise of mind","All of these treasures","You will find"]
        case 1:
            arrDailyUser = ["Hey, you found us!","Get ready...","to discover","YOUR BEST YOU"]
        case 2:
            arrDailyUser = ["Don't worry","Be happy ","Just add Beeja!"]
        case 3:
            arrDailyUser = ["This","Could","Change","EVERYTHING"]
        case 4:
            arrDailyUser = ["Inside your mind","You've got everything","You need to become","Your own super-hero"]
        default:
            arrDailyUser = [""]
        }
        return arrDailyUser
    }
    
    func getOccassionalUserSplashTxt() -> [String] {
        let randomInt = Int.random(in: 0..<5)
        var arrDailyUser = [String]()
        switch randomInt {
        case 0:
            arrDailyUser = ["Great to see you!","Keep the good vibes going","Never forget","There's extraordinary in all of us"]
        case 1:
            arrDailyUser = ["Feel the rhythm","Feel the rhyme","Get on up","IT'S BEEJA TIME!"]
        case 2:
            arrDailyUser = ["Let's beeja baby!","Don't stop","'til you get enough","KEEP ON!"]
        case 3:
            arrDailyUser = ["Howdy","We're so glad you're back","It's never too late","To live your life in high definition"]
        case 4:
            arrDailyUser = ["Phew!","We thought you'd forgotten us","Theres always time","To reboot and recharge"]
        default:
            arrDailyUser = [""]
        }
        return arrDailyUser
    }

}
