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
    
    
    
//    let arrSplashtxt = ["be more aware","be more radical","be a better friend","partner","lover"]
    
    let arrFirstTimeUserSplashtxt = ["be more aware","be more human","be a better friend","partner","lover"]
    let arrFirstTimeUserImage = ["Background_Splash1","Background_Splash1","Background_Splash2","Background_Splash3","Background_Splash4","Background_Splash5"]
    let arrSecondTimeUserSplashTxt = ["we meet again 🙂","ready for a boost?","let's do this..."]
    
    let arrOccasionUserSplash = ["Great to see you back!","Elevate your life / experience","keep the good vibes going","There's extraordinary in all of us","Live life in high definition"]
    
    var arrViewSplashTxt = [String]()
    
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar(isShow: false, title: "")
        self.setUp()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    func setUp() {
        let days = Calendar.current.dateComponents([.day], from: self.appPreference.lastLoginDate(), to: Date()).day ?? 0
        if !self.appPreference.isFirstTimeSplash() {
            self.appPreference.setIsFirstTimeSplash(value: true)
            self.arrViewSplashTxt = self.arrFirstTimeUserSplashtxt
            
        }else if !self.appPreference.isSecondTimeSplash() {
            self.appPreference.setIsSecondTimeSplash(value: true)
            self.arrViewSplashTxt = self.arrSecondTimeUserSplashTxt
        }else if days > 2{
            self.arrViewSplashTxt = self.arrOccasionUserSplash
        }else {
            self.arrViewSplashTxt = self.getDailyUserSplashTxt()
        }
        
        self.appPreference.setLastLoginDate(value: Date())
        
        if self.arrViewSplashTxt.count > 0 {
            self.lblSplashTxt.text = self.arrViewSplashTxt.first
            self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage.first!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showSplashAnimatedWord(arrData: self.arrViewSplashTxt)
        }
    }
    
    func showSplashAnimatedWord(arrData:[String]) {
        if currentIndex == arrData.count - 1 {
            self.moveToInitialVC()
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .transitionCrossDissolve, animations: {
            self.lblSplashTxt.alpha = 0.0
            self.currentIndex += 1
            self.imgView.image = UIImage.init(named: self.arrFirstTimeUserImage[self.currentIndex])
        }) { (_) in
            self.lblSplashTxt.text = arrData[self.currentIndex]
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.lblSplashTxt.alpha = 0.0
            
            if self.appPreference.isLogin() {
                if self.appPreference.isLogout() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }else if !self.appPreference.isProfileComplete() {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupLetsStartVC") as! WWMSignupLetsStartVC
                    self.navigationController?.pushViewController(vc, animated: true)
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
    
    func getDailyUserSplashTxt() -> [String] {
        let randomInt = Int.random(in: 0..<4)
        var arrDailyUser = [String]()
        switch randomInt {
        case 0:
            arrDailyUser = ["Hola!","On Your marks","Get Set","Go!"]
        case 1:
            arrDailyUser = ["Howdy!","Hope you're feeling tip top 🙂","Let's keep up the good work"]
        case 2:
            arrDailyUser = ["Buongiorno!","It's time for another blast","Let's get ready to rumble (UK only)","Let's dive in"]
        case 3:
            arrDailyUser = ["Buongiorno!","It's time for another blast","Let's continue the good vibes","Let's dive in"]
        default:
            arrDailyUser = [""]
        }
        return arrDailyUser
    }

}
