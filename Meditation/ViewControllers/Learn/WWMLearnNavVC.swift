//
//  WWMLearnNavVC.swift
//  Meditation
//
//  Created by Prema Negi on 09/06/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMLearnNavVC: WWMBaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    var arrLearnList = [WWMLearnData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBarForDashboard(title: "Learn")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.appPreference.get21ChallengeName() == "30 Day Challenge"{
            self.appPreference.setType(value: "learn")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLearn(notification:)), name: Notification.Name("notificationLearn"), object: nil)
        self.fetchLearnDataFromDB()
    }
    
    @objc func notificationLearn(notification: Notification) {
        self.fetchLearnDataFromDB()
    }
    
    func meditationApi() {
        let param = [
            "meditation_id" : self.userData.meditation_id,
            "level_id"         : self.userData.level_id,
            "user_id"       : self.appPreference.getUserID(),
            "type" : "learn",
            "guided_type" : ""
            ] as [String : Any]
        
        //print("param*** \(param)")
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMGuidedNavVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                //print("meditation api in learnNav in background...")
            }
        }
    }
    
    //MARK: Fetch Steps Data From DB
    func fetchLearnDataFromDB() {
        let getLearnDataDB = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
        
        if getLearnDataDB.count > 0 {
            //print("self.stepFaqDataDB... \(getLearnDataDB.count)")
            self.arrLearnList.removeAll()
            
            var jsonData: [String: Any] = [:]
            var jsonStepString: [String: Any] = [:]
            var jsonSteps: [[String: Any]] = []
            var jsonThirtyDaysString: [String: Any] = [:]
            var jsonThirtyDays: [[String: Any]] = []
            var jsonEightWeekString: [String: Any] = [:]
            var jsonEightWeekArray: [[String: Any]] = []
            
            for dict in getLearnDataDB {
                jsonData["name"] = dict.name
                jsonData["intro_url"] = dict.intro_url
                jsonData["intro_completed"] = dict.intro_completed
                jsonData["min_limit"] = dict.min_limit
                jsonData["max_limit"] = dict.max_limit
                jsonData["max_limit"] = dict.max_limit
                jsonData["is_expired"] = dict.is_expired
                
                if dict.name == "30 Day Challenge"{
                    self.appPreference.set30DaysIsExpired(value: dict.is_expired)
                }
                
                var completedCount = 0

                let getLearnDataDB = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                for steps in getLearnDataDB{
                    jsonStepString["step_name"] = steps.step_name
                    jsonStepString["id"] = steps.id
                    jsonStepString["date_completed"] = steps.date_completed
                    jsonStepString["title"] = steps.title
                    jsonStepString["timer_audio"] = steps.timer_audio
                    jsonStepString["description"] = steps.description1
                    jsonStepString["step_audio"] = steps.step_audio
                    jsonStepString["outro_audio"] = steps.outro_audio
                    jsonStepString["completed"] = steps.completed
                    jsonStepString["min_limit"] = steps.min_limit
                    jsonStepString["max_limit"] = steps.max_limit
                    
                    if steps.id == "12"{
                        if steps.date_completed != ""{
                            let date12StepArray = steps.date_completed?.components(separatedBy: " ")
                            self.appPreference.setDate12Step(value: date12StepArray![0])
                        }
                    }
                    
                    if steps.date_completed != ""{
                        completedCount = completedCount + 1
                    }
                    
                    jsonSteps.append(jsonStepString)
                }
                self.appPreference.set12CompletedDaysCount(value: completedCount)
                jsonData["step_list"] = jsonSteps
                
                let getThirtyDaysDataDB = WWMHelperClass.fetchDB(dbName: "DBThirtyDays") as! [DBThirtyDays]
                for day_list in getThirtyDaysDataDB{
                    jsonThirtyDaysString["id"] = day_list.id
                    jsonThirtyDaysString["day_name"] = day_list.day_name
                    jsonThirtyDaysString["auther_name"] = day_list.auther_name
                    jsonThirtyDaysString["description"] = day_list.description1
                    jsonThirtyDaysString["is_milestone"] = day_list.is_milestone
                    jsonThirtyDaysString["min_limit"] = day_list.min_limit
                    jsonThirtyDaysString["max_limit"] = day_list.max_limit
                    jsonThirtyDaysString["prep_time"] = day_list.prep_time
                    jsonThirtyDaysString["meditation_time"] = day_list.meditation_time
                    jsonThirtyDaysString["rest_time"] = day_list.rest_time
                    jsonThirtyDaysString["prep_min"] = day_list.prep_min
                    jsonThirtyDaysString["prep_max"] = day_list.prep_max
                    jsonThirtyDaysString["rest_min"] = day_list.rest_min
                    jsonThirtyDaysString["rest_max"] = day_list.rest_max
                    jsonThirtyDaysString["med_min"] = day_list.med_min
                    jsonThirtyDaysString["med_max"] = day_list.med_max
                    jsonThirtyDaysString["completed"] = day_list.completed
                    jsonThirtyDaysString["date_completed"] = day_list.date_completed
                    
                    jsonThirtyDays.append(jsonThirtyDaysString)
                }
                
                if dict.name == "30 Day Challenge"{
                    self.appPreference.set30IntroCompleted(value: dict.intro_completed)
                    self.appPreference.set30DaysURL(value: dict.intro_url ?? "")
                }
                
                jsonData["day_list"] = jsonThirtyDays
                
                let getEightWeekDB = WWMHelperClass.fetchDB(dbName: "DBEightWeek") as! [DBEightWeek]
                for dayWiseList in getEightWeekDB{
                    jsonEightWeekString["id"] = dayWiseList.id
                    jsonEightWeekString["day_name"] = dayWiseList.day_name
                    jsonEightWeekString["auther_name"] = dayWiseList.auther_name
                    jsonEightWeekString["description"] = dayWiseList.description1
                    jsonEightWeekString["second_description"] = dayWiseList.secondDescription
                    jsonEightWeekString["min_limit"] = dayWiseList.min_limit
                    jsonEightWeekString["max_limit"] = dayWiseList.max_limit
                    jsonEightWeekString["two_step_complete"] = dayWiseList.two_step_complete
                    jsonEightWeekString["completed"] = dayWiseList.completed
                    jsonEightWeekString["date_completed"] = dayWiseList.date_completed
                    jsonEightWeekString["image"] = dayWiseList.image
                    
                    jsonEightWeekArray.append(jsonEightWeekString)
                }
                
                jsonData["daywise_list"] = jsonEightWeekArray

                let learnData = WWMLearnData.init(json: jsonData)
                self.arrLearnList.append(learnData)
                jsonThirtyDays.removeAll()
                jsonEightWeekArray.removeAll()
            }
            
            for view in self.containerView.subviews{
                view.removeFromSuperview()
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnDashboardVC") as! WWMLearnDashboardVC
            vc.arrLearnList = self.arrLearnList
           // vc.type = self.typeTitle
            self.addChild(vc)
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
            self.containerView.addSubview((vc.view)!)
            vc.didMove(toParent: self)
            
        }else{
            self.getLearnAPI1()
        }
    }
    
    //MARK: getLearnSetps API call
    func getLearnAPI1() {
        
        //self.learnStepsListData.removeAll()
        let param = ["user_id": self.appPreference.getUserID()] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_LEARN_, context: "WWMLearnStepListVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            
            print("learn result... \(result)")
            if let _ = result["success"] as? Bool {
                if let total_paid = result["total_paid"] as? Double{
                    //print("total_paid double.. \(total_paid)")
                    WWMHelperClass.total_paid = Int(round(total_paid))
                }
                
                if let data = result["data"] as? [[String: Any]]{
                    
                    print("getLearnAPI count... \(data.count)")
                    let getDBLearn = WWMHelperClass.fetchDB(dbName: "DBLearn") as! [DBLearn]
                    if getDBLearn.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBLearn")
                    }
                    
                    let getStepsData = WWMHelperClass.fetchDB(dbName: "DBSteps") as! [DBSteps]
                    if getStepsData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBSteps")
                    }
                    
                    let getThirtyDaysData = WWMHelperClass.fetchDB(dbName: "DBThirtyDays") as! [DBThirtyDays]
                    if getThirtyDaysData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBThirtyDays")
                    }
                    
                    let getEightWeekData = WWMHelperClass.fetchDB(dbName: "DBEightWeek") as! [DBEightWeek]
                    if getEightWeekData.count > 0 {
                        WWMHelperClass.deletefromDb(dbName: "DBEightWeek")
                    }
                    
                    for dict in data{
                        
                        let dbLearnData = WWMHelperClass.fetchEntity(dbName: "DBLearn") as! DBLearn
                        
                        let timeInterval = Int(Date().timeIntervalSince1970)
                        //print("timeInterval.... \(timeInterval)")
                        dbLearnData.last_time_stamp = "\(timeInterval)"
                        
                        if let name = dict["name"] as? String{
                            print(name)
                            dbLearnData.name = name
                        }
                        
                        if let intro_url = dict["intro_url"] as? String{
                            dbLearnData.intro_url = intro_url
                        }
                        
                        if let intro_completed = dict["intro_completed"] as? Bool{
                            dbLearnData.intro_completed = intro_completed
                        }
                        
                        if let min_limit = dict["min_limit"] as? String{
                            dbLearnData.min_limit = min_limit
                        }
                        
                        if let max_limit = dict["max_limit"] as? String{
                            dbLearnData.max_limit = max_limit
                        }
                        
                        if let is_expired = dict["is_expired"] as? Bool{
                            dbLearnData.is_expired = is_expired
                        }else{
                            dbLearnData.is_expired = false
                        }
                        
                        if let step_list = dict["step_list"] as? [[String: Any]]{
                            for dict in step_list{
                                let dbStepsData = WWMHelperClass.fetchEntity(dbName: "DBSteps") as! DBSteps
                                if let completed = dict["completed"] as? Bool{
                                    dbStepsData.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbStepsData.date_completed = date_completed
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbStepsData.description1 = description
                                }
                                
                                if let id = dict["id"]{
                                    dbStepsData.id = "\(id)"
                                }
                                
                                if let outro_audio = dict["outro_audio"] as? String{
                                    dbStepsData.outro_audio = outro_audio
                                }
                                
                                if let step_audio = dict["step_audio"] as? String{
                                    dbStepsData.step_audio = step_audio
                                }
                                
                                if let step_name = dict["step_name"] as? String{
                                    dbStepsData.step_name = step_name
                                }
                                
                                if let timer_audio = dict["timer_audio"] as? String{
                                    dbStepsData.timer_audio = timer_audio
                                }
                                
                                if let title = dict["title"] as? String{
                                    dbStepsData.title = title
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbStepsData.min_limit = min_limit
                                }else{
                                    dbStepsData.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbStepsData.max_limit = max_limit
                                }else{
                                    dbStepsData.max_limit = "98"
                                }
                                
                                WWMHelperClass.saveDb()
                                
                            }
                        }
                        
                        if let day_list = dict["day_list"] as? [[String: Any]]{
                            for dict in day_list{
                                let dbThirtyDays = WWMHelperClass.fetchEntity(dbName: "DBThirtyDays") as! DBThirtyDays
                            
                                if let id = dict["id"]{
                                    dbThirtyDays.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbThirtyDays.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbThirtyDays.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbThirtyDays.description1 = description
                                }
                                
                                if let is_milestone = dict["is_milestone"] as? Bool{
                                    dbThirtyDays.is_milestone = is_milestone
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbThirtyDays.min_limit = min_limit
                                }else{
                                    dbThirtyDays.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbThirtyDays.max_limit = max_limit
                                }else{
                                    dbThirtyDays.max_limit = "98"
                                }
                                
                                if let prep_time = dict["prep_time"] as? String{
                                    dbThirtyDays.prep_time = prep_time
                                }else{
                                    dbThirtyDays.prep_time = "60"
                                }
                                
                                if let meditation_time = dict["meditation_time"] as? String{
                                    dbThirtyDays.meditation_time = meditation_time
                                }else{
                                    dbThirtyDays.meditation_time = "1200"
                                }
                                
                                if let rest_time = dict["rest_time"] as? String{
                                    dbThirtyDays.rest_time = rest_time
                                }else{
                                    dbThirtyDays.rest_time = "120"
                                }
                                
                                if let prep_min = dict["prep_min"] as? String{
                                    dbThirtyDays.prep_min = prep_min
                                }else{
                                    dbThirtyDays.prep_min = "0"
                                }
                                
                                if let prep_max = dict["prep_max"] as? String{
                                    dbThirtyDays.prep_max = prep_max
                                }else{
                                    dbThirtyDays.prep_max = "300"
                                }
                                
                                if let rest_min = dict["rest_min"] as? String{
                                    dbThirtyDays.rest_min = rest_min
                                }else{
                                    dbThirtyDays.prep_max = "0"
                                }
                                
                                if let rest_max = dict["rest_max"] as? String{
                                    dbThirtyDays.rest_max = rest_max
                                }else{
                                    dbThirtyDays.prep_max = "600"
                                }
                                
                                if let med_min = dict["med_min"] as? String{
                                    dbThirtyDays.med_min = med_min
                                }else{
                                    dbThirtyDays.med_min = "0"
                                }
                                
                                if let med_max = dict["med_max"] as? String{
                                    dbThirtyDays.med_max = med_max
                                }else{
                                    dbThirtyDays.med_max = "2400"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbThirtyDays.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbThirtyDays.date_completed = date_completed
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        //8 week
                        if let daywise_list = dict["daywise_list"] as? [[String: Any]]{
                            for dict in daywise_list{
                                let dbEightWeek = WWMHelperClass.fetchEntity(dbName: "DBEightWeek") as! DBEightWeek
                                                                
                                if let id = dict["id"]{
                                    dbEightWeek.id = "\(id)"
                                }
                                
                                if let day_name = dict["day_name"] as? String{
                                    dbEightWeek.day_name = day_name
                                }
                                
                                if let auther_name = dict["auther_name"] as? String{
                                    dbEightWeek.auther_name = auther_name
                                }
                                
                                if let description = dict["description"] as? String{
                                    dbEightWeek.description1 = description
                                }
                                
                                if let secondDescription = dict["second_description"] as? String{
                                    dbEightWeek.secondDescription = secondDescription
                                }else{
                                    dbEightWeek.secondDescription = ""
                                }
                                
                                if let image = dict["image"] as? String{
                                    dbEightWeek.image = image
                                }else{
                                    dbEightWeek.image = ""
                                }
                                
                                if let min_limit = dict["min_limit"] as? String{
                                    dbEightWeek.min_limit = min_limit
                                }else{
                                    dbEightWeek.min_limit = "95"
                                }
                                
                                if let max_limit = dict["max_limit"] as? String{
                                    dbEightWeek.max_limit = max_limit
                                }else{
                                    dbEightWeek.max_limit = "98"
                                }
                                
                                if let completed = dict["completed"] as? Bool{
                                    dbEightWeek.completed = completed
                                }
                                
                                if let date_completed = dict["date_completed"] as? String{
                                    dbEightWeek.date_completed = date_completed
                                }
                                
                                if let two_step_complete = dict["two_step_complete"] as? Bool{
                                    dbEightWeek.two_step_complete = two_step_complete
                                }
                                
                                WWMHelperClass.saveDb()
                            }
                        }
                        
                        WWMHelperClass.saveDb()
                        self.fetchLearnDataFromDB()
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationLearnSteps"), object: nil)
                }
            }
        }
    }
}
