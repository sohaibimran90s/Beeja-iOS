//
//  WWMStringDefine.swift
//  Meditation
//
//  Created by Roshan Kumawat on 21/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import Foundation
import UIKit



///////**********************////////
let kDeviceToken:String!                    = "DeviceToken"
let kUserData:String!                       = "LoginKey"
let kUserToken:String!                       = "token"






let  kAlertTitle : String!                    = "Alert"
let  kGETHeader : String!                     = "GET"
let  kPOSTHeader : String!                    = "POST"
let  kLoginTypeEmail : String!                = "eml"
let  kLoginTypeGoogle : String!               = "ggl"
let  kLoginTypeFacebook : String!             = "fb"
let  kDeviceType : String!                    = "ios"
let  kDeviceID : String!                      = UIDevice.current.identifierForVendor!.uuidString




/************************************************/
let themeColor : UIColor! = UIColor.init(hexString: "#e21921")


/*************************************/
// MARK:- Chimes

let kChimes_THRUSH                              = "THRUSH"
let kChimes_HARP                                = "HARP"
let kChimes_CHIME                               = "CHIME"
let kChimes_SITAR                               = "SITAR"
let kChimes_SPARROW                             = "SPARROW"
let kChimes_HIMALAYAN_BELL                      = "HIMALAYAN BELL"
let kChimes_CONCH                               = "CONCH"
let kChimes_MOON_KOSHI                          = "MOON KOSHI"
let kChimes_BURMESE_BELL                        = "BURMESE BELL"
let kChimes_CRYSTAL_BOWL                        = "CRYSTAL BOWL"
let kChimes_SUN_KOSHI                           = "SUN KOSHI"

// MARK:-   Ambient sound

let kAmbient_WAVES_CHIMES                       = "WAVES & CHIMES"
let kAmbient_WAVES_ONLY                         = "WAVES ONLY"
let kAmbient_JUNGLE_AT_DAWN                     = "JUNGLE AT DAWN"
let kAmbient_CHIMES_ONLY                        = "CHIMES ONLY"
let kAmbient_BIRDSONG_2                         = "BIRDSONG 2"
let kAmbient_BIRDSONG_1                         = "BIRDSONG 1"

// MARK:- Jai Guru Dev Mantra

let kChimes_JaiGuruDev                          = "ww_vo_jaygudurday_tk2"

#if DEVELOPMENT
let URL_BASE  = "http://staging.beejameditation.com/api/v1/"

#else
let URL_BASE  = "http://staging.beejameditation.com/api/v1/"

#endif

// Web Services Method Name

let URL_GETMOODMETERDATA         = URL_BASE + "getmoods"
let URL_GETMEDITATIONDATA        = URL_BASE + "getMeditationData"
let URL_LOGIN                    = URL_BASE + "login"
let URL_SIGNUP                   = URL_BASE + "signUp"
let URL_LOGOUT                    = URL_BASE + "logout"
let URL_MEDITATIONDATA           = URL_BASE + "meditationData"
let URL_FORGOTPASSWORD           = URL_BASE + "forgotPassword"
let URL_JOURNALMYPROGRESS        = URL_BASE + "journalMyProgress"
let URL_RESETPASSWORD            = URL_BASE + "reset_password"
let URL_SUPPORT                  = URL_BASE + "support"
let URL_COMMUNITYDATA        = URL_BASE + "communityData"
let URL_SUBSCRIPTIONPURCHASE    = URL_BASE + "subscriptionPurchase"
let URL_GETPROFILE                  = URL_BASE + "getProfile"




/************************************************/

//Validation Message
let Validation_EmailMessage:String!                    = "Please write your email address, this will help you keep score of all your progress"
let Validation_NameMessage:String!                    = "Please write your name"

let Validation_QueryMessage:String!                    = "Please write your query"


let Validation_invalidEmailMessage:String!              = "Please write valid email address"
let Validation_passwordMessage:String!                  = "Please enter your password (‘open sesame’ not allowed!)"

let Validation_JournalMessage:String!                  = "Please enter your meditation experience."

let Validation_OldPasswordMessage:String!                  = "Please enter old password"
let Validation_NewPasswordMessage:String!                  = "Please enter new password"
let Validation_ConfirmPasswordMessage:String!                  = "Please enter confirm password"
let Validation_PasswordMatchMessage:String!                  = "New password and Confirm password does not match"
/**/



/************************************/
//Static Urls

let URL_PrivacyPolicy   = "http://staging.beejameditation.com/privacy"
let URL_TermsnCondition   = "http://staging.beejameditation.com/terms-and-condition"
let URL_Help   = "https://www.willwilliamsmeditation.co.uk/privacy-policy/"
let URL_FAQ   = "http://staging.beejameditation.com/faq"
let URL_WebSite   = "https://www.willwilliamsmeditation.co.uk/"
let URL_FINDCOURSE   = "https://www.willwilliamsmeditation.co.uk/"
let URL_OurStory   = "https://www.willwilliamsmeditation.co.uk/privacy-policy/"

// Social Links **************************
let URL_Facebook   = "https://www.facebook.com/WillWilliamsMeditation"
let URL_Insta   = "http://www.instagram.com/willwilliamsmeditation/"
let URL_Twitter   = "http://twitter.com/wwmeditation"
let URL_LinkedIn   = "http://www.linkedin.com/pub/will-williams/64/56/b"
let URL_YouTube = "https://www.youtube.com/channel/UCysJyoHtICcn2vdNeyLhV_A/feed"






