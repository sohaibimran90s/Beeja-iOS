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
let kUserToken:String!                      = "token"
let KUSERDEFAULTS                           = UserDefaults.standard
let KNOTIFICATIONCENTER                     = NotificationCenter.default





let  kAlertTitle : String!                    = "Alert"
let  kGETHeader : String!                     = "GET"
let  kPOSTHeader : String!                    = "POST"
let  kLoginTypeEmail : String!                = "eml"
let  kLoginTypeGoogle : String!               = "ggl"
let  kLoginTypeFacebook : String!             = "fb"
let  kDeviceType : String!                    = "ios"
let  kDeviceID : String!                      = UIDevice.current.identifierForVendor!.uuidString
let  KFORCETOUPDATETITLE : String = "titleForceToUpdate"
let  KFORCETOUPDATEDES : String = "desForceToUpdate"
let  KBASEURL = "baseURL"
let  KUPGRADEBUTTON = "upgrade"


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

let kChimes_JaiGuruDev                          = "JAI GURU DEVA"

#if DEVELOPMENT
let URL_BASE  = "\(KUSERDEFAULTS.string(forKey: KBASEURL) ?? "https://beta.beejameditation.com")/api/v2/"
let URL_BASE_WEBVIEW = "\(KUSERDEFAULTS.string(forKey: KBASEURL) ?? "https://beta.beejameditation.com")"
//let URL_BASE  = KUSERDEFAULTS.string(forKey: KBASEURL) ?? "https://beta.beejameditation.com" + "/api/v2/"
//let URL_BASE  = "https://beta.beejameditation.com/api/v2/"
//"https://service.launchpad-stage.in/api/v1/"//
#else
let URL_BASE  = "\(KUSERDEFAULTS.string(forKey: KBASEURL) ?? "https://beta.beejameditation.com")/api/v2/"
let URL_BASE_WEBVIEW = "\(KUSERDEFAULTS.string(forKey: KBASEURL) ?? "https://beta.beejameditation.com")"

//let URL_BASE  = "https://beta.beejameditation.com/api/v2/"
//"https://service.launchpad-stage.in/api/v1/"//

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
let URL_GETVIBESIMAGES                  = URL_BASE + "dictionary/vibes"//getVibesImages
let URL_ADDSESSION                  = URL_BASE + "addSession"//
let URL_SETMYOWN                  = URL_BASE + "setMyOwn"//
let URL_SETTINGS                  = URL_BASE + "settings"//
let URL_MILESTONE                  = URL_BASE + "milestone"//

let URL_HANDSHAKE                  = URL_BASE + "handshake"//

let URL_GETWISDOM                  = URL_BASE + "getWisdom"//

let URL_WISHDOMFEEDBACK            = URL_BASE + "wisdomFeedback"

let URL_GETGUIDEDDATA                 = URL_BASE + "dictionary/guided"//

let URL_GETGUIDEDAudio                = URL_BASE + "guidedAudio"//

let URL_MEDITATIONHISTORY          = URL_BASE + "meditationHistory"

let URL_STEPS        =  URL_BASE + "steps"

let URL_MANTRAS      = URL_BASE + "mantras"

let URL_COMBINEDMANTRA = URL_BASE + "combinedMantra"

let URL_STEPFAQ         = URL_BASE + "dictionary/setp_faqs"

let URL_DICTIONARY  = URL_BASE + "dictionary"


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


let KOK = "Ok"
let KOKYOU = "Ok You,"
let KSTEP = "Step"

//WWMLearnStepListVC
let KLEARNANNUALSUBS = "Please subscribe to Annual subscription to open this.\n" + "If you subscribe monthly, you will gain access to further steps after 6 months of Beeja membership."
let KLEARNONESTEP = "Keep your learning to one step per day. Please come back tomorrow!"
let KLEARNJUMPSTEP = "Oops, you seem to have jumped ahead. Return to step"
let KLEARNJUMPSTEP1 = "to get the most from your learning."

//WWMLearnCongratsVC
let KSTEPCONGMSG = "You've completed step"
let KSTEPCONGMSG1 = "of the learn too meditate flow"

//WWMHomeTabVC
let KWELCOME = "Welcome"
let KHOMELBL = "How can we help you today?"
let KHOMELBL1 = "To get started, try our 12-step learn to meditate series."
let KSHARETEXT = "Lorem ipsum"
let KNICEONE = "Nice one!"
let KMSGSHARED = "Your Message has been shared."
let KPODCAST1 = "Will Williams Podcast with Howard Donald from Take That"
let KPODCAST2 = "Will Williams Podcast with Jasmine Hemsley"
let KPODCAST3 = "Will Williams Podcast with Sam Branson"
let KPODCAST4 = "Will Williams Podcast with Madeleine Shaw"
let KPODCASTNAME1 = "HOWARD_DONALD"
let KPODCASTNAME2 = "JASMINE_HEMSLEY"
let KPODCASTNAME3 = "SAM_BRANSON"
let KPODCASTNAME4 = "MADELEINE_SHAW"
let KMEDITATIONFOR = "Meditation for"
let KBUYBOOK = "Buy Book"
let KJUSTNOW = "just now"
let KMOREINFORMATION = "More Information"
let KSHOWALL = "Show all"
let kAFTERNOON = "Good Afternoon"
let kEVENING = "Good Evening"
let kMORNING = "Good Morning"
let kMEDITATIONSESSINO = "Meditation session"
let kTIMER = "TIMER"
let kLEARN = "LEARN"
let kGUIDED = "GUIDED"

//WWMGuidedAudioListVC
let KFREEAUDIO = "(Free for 15:00 min)"

//WWMGuidedMeditationTimerVC
let KPRACTICAL = "Practical"
let KSPIRITUAL = "Spiritual"

//WWMTabBarVC
let KRETRY = "Retry"

//WWMSideMenuVC
let KOURSTORY = "Our Story"
let KINSTAGRAM = "Instagram"
let KFACEBOOK = "Facebook"
let KYOUTUBE = "You Tube"
let KTWITTER = "Twitter"
let KLINKEDIN = "LinkedIn"
let KBEEJA = "Beeja"
let KFAQ = "FAQ"
let KFINDCOURSE = "Find a Course"
let KLEARN = "Learn"
let KGUIDED = "Guided"

//WWMSupportVC
let KVALIDATIONNAME = "Oops. Please write your valid name"
let KSUPPORTMSG = "Thanks for your message! The team will be in touch soon."

//WWMUpgradeBeejaVC
let KBUYBOOKTITLE = "What do you want to do?"
let KBUY = "Buy"
let KBILLEDTEXT = "*that's just £3.50 a month"

//WWMWisdomFeedbackVC
let KSESSIONMSG = "Did you like the\nsession?"

//WWMSettingsVC
let KTIMESCHIMES = "Times & Chimes"
let KPRESET = "Preset"
let KREMINDERS = "Reminders"
let KLEARNTOMEDITATE = "Learn To Meditate"
let KLEARNTOMEDITATE1 = "Learn to meditate"
let KBEMORECONNECTED = "Be more connected with the Beeja app..."
let KPRIVACYPOLICY = "Privacy Policy"
let KTERMSCONDITION = "Terms & Conditions"
let KHELP = "Help"

//WWMLoginWithEmailVC
let KNEXT = "Next"
let KDONTFORGETEMAIL = "Oops, don't forget to enter your email."

//WWMSignUpPasswordVC
let KENTERPASS = "Oops. Please enter a password."
let KRETYPECONFIRMPASS = "Oops. Please enter confirm password."
let KPASSLENGTH = "Oops. The password should have min 6 chars."
let KPASSNOTMATCH = "Oops. The password doesn't match with confirm password."

//WWMMyProgressJournalVC
let KPOSTMEDITATION = "Post Meditation"
let KPREMEDITATION = "Pre Meditation"

//WWMMoodJournalVC
let KTIMETOUPDATEJOUR = "Time to update your journal"

//WWMMoodMeterVC
let KSKIP = "Skip"
let KMOVEDOTSELECT = "Move dot to select your current feeling"

//WWMLearnReminderVC
let KDONE = "Done"
let KCANCEL = "Cancel"

//WWMMoodMeterLogVC
let KJOURNALUPDATED = "Great job! Your journal has been updated."
let KMOODTRACKERUPDATED = "Thanks! Your mood tracker has been updated."
let KMEDITATIONUPDATED = "Great stuff! Your meditation experience has been logged. "

//POPUP ALERTS
let KSAYGOODBYE = "Do you really want to say goodbye?"
let KSAYGOODBYEYES = "Yes, I'm off"
let KSAYGOODBYENO = "No, I'll stay"
let KSUBSPLANEXP = "Subscribe for more."
let KSUBSPLANEXPDES = "Don't worry, we already have a new plan for you. Please purchase any subscription plan to listen this audio."
let KRESTOREPROBTITLE = "Please contact us if problem still persists."
let KRESTOREPROBSUBTITLE = "There was some problem restoring your subscription. Please try after some time."
let KFORCEUPDATETITLE = "New Version Available"
let KFORCEUPDATESUBTITLE = "There is a newer version available for download! Please update the app by visiting the Apple Store."
let KRESTOREMSG = "Your subscription has been restored."
let KNOFREEJOURNAL = "You have used your free journal entries. Subscribe now for unlimited access."
let KYOUHAVE = "You have"
let KNOFREEJOURNALMSG = "journal entries left. Subscribe for more."
let KENTERJOURNAL = "Please enter your journal."
let KNOFREEMOODJOU = "You have used your free mood and journal entries. Subscribe now for unlimited access."
let KNOFREEMOOD = "You have used your free mood entries. Subscribe now for unlimited access."
let KSUCCESSRESETLINK = "We've sent you a magic link to reset your password. Please check your inbox."
let KFAILRESETLINK = "Oops, this email isn't registered with the Beeja App / Oops, looks like this email has been registered using Facebook or Google. Try logging in again via one of them."
let KFAILTORECOGNISEEMAIL = "Argh, sorry. We don't recognise that email address. Please try again or create a new account."

//appdelegate
let KGOODMORNING = "Good morning!"
let KGOODAFTERNOON = "Good afternoon!"
let KGOODEVENING = "Good evening!"
let KITSTIMEFORBEEJA = "It's time for Beeja."
let KUPDATE = "Update"
let KTIMETOLEARN = "It's time to learn Beeja"

// My Progress Journal
let  Validatation_JournalOfflineMsg  =
"Any new entries posted during no-Internet connection will be listed once it gets synced with server and device gets online."
/**/


// If kBETA_ENABLED is true its mean we are using beta_url else using staging_url
let kBETA_ENABLED = true


let URL_PrivacyPolicy   =  URL_BASE_WEBVIEW + "/privacy-policy?mobile_view=1"
let URL_TermsnCondition   = URL_BASE_WEBVIEW + "/beeja-terms-conditions?mobile_view=1"
let URL_Help   = URL_BASE_WEBVIEW + "/contact-us?mobile_view=1"
let URL_FAQ   = URL_BASE_WEBVIEW + "/faqs?mobile_view=1"
let URL_WebSite   = "https://www.beejameditation.com/"
let URL_FINDCOURSE   = URL_BASE_WEBVIEW + "/courses/beginners?mobile_view=1"
let URL_OurStory   = "https://www.beejameditation.com/about-us/"
let URL_LEARN   = URL_BASE_WEBVIEW + "/love-to-learn/"
let URL_GUIDED   = URL_BASE_WEBVIEW + "/please-guide-me/"
let URL_MOREINFO   = URL_BASE_WEBVIEW + "/more-info?mobile_view=1"


// Social Links **************************
let URL_Facebook   = "https://www.facebook.com/BeejaMeditation/"
let URL_Insta   = "https://www.instagram.com/beejameditation/"
let URL_Twitter   = "https://twitter.com/beejameditation"
let URL_LinkedIn   = "https://www.linkedin.com/company/10193966/admin/"
let URL_YouTube = "https://www.youtube.com/channel/UCysJyoHtICcn2vdNeyLhV_A"


// in app repurchase status links *********
#if DEBUG
let kURL_INAPPS_RECEIPT = "https:/sandbox.itunes.apple.com/verifyReceipt"
#else
let kURL_INAPPS_RECEIPT = "https://buy.itunes.apple.com/verifyReceipt"
#endif


