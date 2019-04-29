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

let kChimes_JaiGuruDev                          = "JAY GURUDEV"

#if DEVELOPMENT
let URL_BASE  = "https://staging.beejameditation.com/api/v1/"

#else
let URL_BASE  = "https://staging.beejameditation.com/api/v1/"

#endif

// Web Services Method Name

let URL_GETMOODMETERDATA         = URL_BASE + "getmoods"
let URL_GETMEDITATIONDATA        = URL_BASE + "getMeditationData"
let URL_LOGIN                    = URL_BASE + "login"
let URL_SIGNUP                   = URL_BASE + "signup"
let URL_LOGOUT                    = URL_BASE + "logout"
let URL_MEDITATIONDATA           = URL_BASE + "meditationData"
let URL_FORGOTPASSWORD           = URL_BASE + "forgotPassword"
let URL_JOURNALMYPROGRESS        = URL_BASE + "journalMyProgress"
let URL_STATSMYPROGRESS        = URL_BASE + "statsMyProgress"
let URL_MOODPROGRESS               = URL_BASE + "moodProgress"//
let URL_ADDJOURNAL               = URL_BASE + "addJournal"
let URL_MEDITATIONCOMPLETE               = URL_BASE + "meditationComplete"//
let URL_RESETPASSWORD            = URL_BASE + "reset_password"
let URL_SUPPORT                  = URL_BASE + "support"
let URL_COMMUNITYDATA        = URL_BASE + "communityData"
let URL_SUBSCRIPTIONPURCHASE    = URL_BASE + "subscriptionPurchase"//
let URL_GETSUBSCRIPTIONPPLANS    = URL_BASE + "getSubscriptionPlans"//
let URL_GETPROFILE                  = URL_BASE + "getProfile"
let URL_UPLOADHASHTAG                  = URL_BASE + "uploadHashTag"//
let URL_GETVIBESIMAGES                  = URL_BASE + "getVibesImages"//getVibesImages
let URL_ADDSESSION                  = URL_BASE + "addSession"//
let URL_SETMYOWN                  = URL_BASE + "setMyOwn"//
let URL_SETTINGS                  = URL_BASE + "settings"//

let URL_HANDSHAKE                  = "http://10.16.64.73/api/v1/" + "handshake"//

let URL_GETWISDOM                  = URL_BASE + "getWisdom"//

let URL_WISHDOMFEEDBACK            = URL_BASE + "wisdomFeedback"

let URL_GETGUIDEDDATA                 = URL_BASE + "guidedData"//

let URL_GETGUIDEDAudio                = URL_BASE + "guidedAudio"//



/************************************************/

//Validation Message
let Validation_EmailMessage:String!                    = "Hello! Please enter your email address."
let Validation_NameMessage:String!                    = "Please write your name"

let Validation_MinimumCharacter:String!               = "Minimum characters should be three"
let Validation_QueryMessage:String!                    = "Oops. You need to enter a message!"


let Validation_invalidEmailMessage:String!              = "Uh oh, that e-mail address isn't valid."
let Validation_passwordMessage:String!                  = "Oops - don't forget to enter your password..."

let Validation_JournalMessage:String!                  = "Please enter your meditation experience."

let Validation_OldPasswordMessage:String!                  = "Oops. Please enter your current password."
let Validation_NewPasswordMessage:String!                  = "Oops. Please enter your new password."
let Validation_ConfirmPasswordMessage:String!                  = "Oops. Please confirm your new password"
let Validation_PasswordMatchMessage:String!                  = "Uh oh, those passwords don't match. Please try again."
let Validation_OldNewSamePassword:String!                  = "Oops. New password should not be same"
let Validation_EmailName: String!                    = "Oops, please enter your name and email address."

let internetConnectionLostMsg: String!              = "Oh no, we've lost you! Please check your internet connection."

// My Progress Journal

let  Validatation_JournalOfflineMsg  =
"Any new entries posted during no-Internet connection will be listed once it gets synced with server and device gets online."


/**/



/************************************/
//Static Urls

let URL_PrivacyPolicy   = "https://staging.beejameditation.com/privacy"
let URL_TermsnCondition   = "https://staging.beejameditation.com/terms-and-condition"
let URL_Help   = "https://www.willwilliamsmeditation.co.uk/privacy-policy/"
let URL_FAQ   = "https://staging.beejameditation.com/faq"
let URL_WebSite   = "https://www.willwilliamsmeditation.co.uk/"
let URL_FINDCOURSE   = "https://www.willwilliamsmeditation.co.uk/"
let URL_OurStory   = "https://www.willwilliamsmeditation.co.uk/privacy-policy/"
let URL_LEARN   = "https://www.willwilliamsmeditation.co.uk/love-to-learn"
let URL_GUIDED   = "https://www.willwilliamsmeditation.co.uk/please-guide-me/"


// Social Links **************************
let URL_Facebook   = "https://www.facebook.com/BeejaMeditation/"
let URL_Insta   = "https://www.instagram.com/beejameditation/"
let URL_Twitter   = "https://twitter.com/beejameditation"
let URL_LinkedIn   = "https://www.linkedin.com/company/10193966/admin/"
let URL_YouTube = "https://www.youtube.com/channel/UCysJyoHtICcn2vdNeyLhV_A"




