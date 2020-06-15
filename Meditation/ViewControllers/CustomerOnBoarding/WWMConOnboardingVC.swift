//
//  WWMConOnboardingVC.swift
//  Meditation
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit


struct OnboardingData: Codable {
    var success: Bool?
    var code: Int?
    var message: String?
    var data: [GetData]?
}

struct GetData: Codable {
    var id: Int?
    var name: String?
    var title: String?
    var multiple_selection: Int?
    var first_question: Int?
    var endQue: Int?
    var isOverlay: Int?
    var max_selection: Int?
    var options: [OptionsData]?
}

class OptionsData: Codable {
    var id: Int?
    var onboarding_id: Int?
    var option_name: String?
    var next_question: Int?
    var exitPoint: String?
    var is_genral: Int?
    var isSelected: Bool?
}


class WWMConOnboardingVC: WWMBaseViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var boardingTable: UITableView!
    @IBOutlet weak var yPosTableConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableBottmConstraints: NSLayoutConstraint!
    @IBOutlet weak var index1Lbl: UILabel!
    @IBOutlet weak var index2Lbl: UILabel!
    @IBOutlet weak var index3Lbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var optionList: [OptionsData] = []
    var dataArray: [GetData] = []
    var pageInfoArray: [Any] = []
    var isMultipleSelection = 0
    var multipleSelectedRow:[Int] = []
    var currentPageData = GetData()
    //var postData: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.getQuestionsAnsAPI()
        
        self.nextBtn.isHidden = true;
        self.getOnboardingDataAPI { (onboardingData, isSuccess) in
            if (isSuccess){                
                let onboardData: OnboardingData = onboardingData
                if let dataArr = onboardData.data{
                    self.dataArray = dataArr
                    let filteredDataArray = self.dataArray.filter({$0.first_question == 1})
                    if (filteredDataArray.count > 0){
                        self.updadtePage(selectedData: filteredDataArray[0])
                        self.boardingTable.reloadData()
                    }
                }
            }
        }
        
        //        // Though locally saved Data
        //        let onboardData = self.loadJson()
        //        if let dataArr = onboardData?.data{
        //            self.dataArray = dataArr
        //            let filteredDataArray = self.dataArray.filter({$0.first_question == 1})
        //            if (filteredDataArray.count > 0){
        //                self.updadtePage(selectedData: filteredDataArray[0])
        //            }
        //        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func updadtePage(selectedData: GetData) {
        
        self.currentPageData = selectedData
        
        self.nameLbl.text = selectedData.name
        self.titleLbl.text = selectedData.title
        
        self.isMultipleSelection = selectedData.multiple_selection ?? 0
        self.boardingTable.allowsMultipleSelection = (self.isMultipleSelection == 1) ? true:false
        
        self.nextBtn.isHidden = (self.isMultipleSelection == 0) ? true:false
        self.handleNextBtn()
        
        self.optionList = selectedData.options ?? []
        self.pageIndex(index: self.pageInfoArray.count + 1)
        self.backBtn.isHidden = (self.pageInfoArray.count == 0) ? true:false
        
        self.setTableHeight()
    }
    
    func setTableHeight() {
        
        let titleLblBottomPos = self.titleLbl.frame.size.height + self.titleLbl.frame.origin.y
        let tableBottomPos = self.boardingTable.frame.size.height + self.boardingTable.frame.origin.y
        
        let disBWTableBtmAndTitleLblBtm = Int(tableBottomPos - titleLblBottomPos)
        let tableReqH = 75 * self.optionList.count  // 75 is each cell height + top/bottom gap
        let diff = disBWTableBtmAndTitleLblBtm - tableReqH
        
        if (diff > 0) {
            self.tableHeightConstraints.constant = CGFloat(tableReqH)
            self.boardingTable.isScrollEnabled = false
        }
        else {
            self.tableHeightConstraints.constant = CGFloat(tableReqH + diff - 10)
            self.boardingTable.isScrollEnabled = true
        }
    }
    
    func reloadTableData(isForward: Bool) {
        
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.forwards
        transition.duration = 0.3
        transition.subtype = (isForward) ? CATransitionSubtype.fromRight : CATransitionSubtype.fromLeft
        self.boardingTable.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        // Update your data source here
        self.boardingTable.reloadData()
    }
    
    func pageIndex(index: Int) {
        
        switch index {
        case 1:
            self.index1Lbl.layer.cornerRadius = self.index1Lbl.frame.size.height / 2
            self.index1Lbl.layer.borderWidth = 3
            self.index1Lbl.layer.borderColor = UIColor.white.cgColor
            self.index1Lbl.text = String(index)
            self.index2Lbl.text = "•"
            self.index3Lbl.text = "•"
            self.index2Lbl.layer.borderColor = UIColor.clear.cgColor
            self.index3Lbl.layer.borderColor = UIColor.clear.cgColor
            
        case 2:
            self.index2Lbl.layer.cornerRadius = self.index2Lbl.frame.size.height / 2
            self.index2Lbl.layer.borderWidth = 3
            self.index2Lbl.layer.borderColor = UIColor.white.cgColor
            self.index2Lbl.text = String(index)
            self.index1Lbl.text = "•"
            self.index3Lbl.text = "•"
            self.index1Lbl.layer.borderColor = UIColor.clear.cgColor
            self.index3Lbl.layer.borderColor = UIColor.clear.cgColor
            
        //        case 3,4:
        default:
            self.index3Lbl.layer.cornerRadius = self.index3Lbl.frame.size.height / 2
            self.index3Lbl.layer.borderWidth = 3
            self.index3Lbl.layer.borderColor = UIColor.white.cgColor
            self.index3Lbl.text = String(index)
            self.index1Lbl.text = "•"
            self.index2Lbl.text = "•"
            self.index1Lbl.layer.borderColor = UIColor.clear.cgColor
            self.index2Lbl.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func getOnboardingDataAPI(completionHandler: @escaping (OnboardingData, Bool) -> Void) {
        
        let url = URL(string: "https://uat.beejameditation.com/api/v2/consumer/onboarding")!
        
        let task = URLSession.shared.dataTask(with: url){(data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                if (httpResponse?.statusCode == 200){
                    guard let data = data else {return}
                    do {
                        let onboardData = try JSONDecoder().decode(OnboardingData.self, from: data)
                        completionHandler(onboardData, true)
                    }
                    catch {
                        print("JSONSerialization error:", error)
                    }
                }
                else {
                    completionHandler(OnboardingData(), false)
                }
            }
        }
        task.resume()
    }
    
    
    //    func getQuestionsAnsAPI() {
    //
    //        WWMHelperClass.showLoaderAnimate(on: self.view)
    //
    //        let param = [:] as [String : Any]
    //        WWMWebServices.requestAPIWithBody(param:param , urlString: URL_CONSUMER_ONBOARDING, context: "WWMMeditationDataVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
    //
    //            WWMHelperClass.hideLoaderAnimate(on: self.view)
    //
    //            if sucess {
    //            }
    //        }
    //    }
    
    
    func loadJson() -> OnboardingData? {
        
        if let url = Bundle.main.path(forResource: "conOnboarding", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url), options: .mappedIfSafe)
                let onboardData = try JSONDecoder().decode(OnboardingData.self, from: data)
                return onboardData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    
    func selectedOption(nextPageId: Int, isNavigateForward: Bool) {
        
        let filteredDataArray = self.dataArray.filter({$0.id == nextPageId})
        
        if (filteredDataArray.count > 0){
            
            let dataObject = filteredDataArray[0]
            if (dataObject.isOverlay == 1){
                // Show popover screen and send self.dataObject
                let VC = self.storyboard!.instantiateViewController(withIdentifier: "PopoverOnboardingVC") as! WWMPopoverOnboardingVC
                VC.modalPresentationStyle = .fullScreen
                VC.dataObj = dataObject
                self.present(VC, animated:true, completion: nil)
                
                return
            }
            else {
                if (isNavigateForward) {    // Update pageInfoArray only navigate forward but not when move back screen
                    let selectedOption = (self.multipleSelectedRow.count > 0) ? self.multipleSelectedRow : []
                    let pageInfo = (self.currentPageData.id, selectedOption)
                    self.pageInfoArray.append(pageInfo)
                    self.multipleSelectedRow.removeAll()
                    
                    
                    // For Post Request.
                    self.createPostData()
                }
            }
            self.updadtePage(selectedData: dataObject)
        }
        
        self.reloadTableData(isForward: isNavigateForward)
    }
    
    func createPostData() {
        
        let selectedOption = self.optionList.filter({$0.isSelected == true})
        //let ids = selectedOption.map { $0.id }
        DataManager.sharedInstance.getOptionList(selectedOptionList: selectedOption, currentPage: self.currentPageData)
        self.unselectAllSelectedOptions()
    }
    
    func unselectAllSelectedOptions() {
        let selectedOption = self.optionList.filter({$0.isSelected == true})
        for option in selectedOption {
            option.isSelected = false
        }
    }
    
    func meditationApi(type: String) {
        self.view.endEditing(true)
        //WWMHelperClass.showSVHud()
        WWMHelperClass.showLoaderAnimate(on: self.view)
        let param = [
            "meditation_id" : 1,
            "level_id"      : 1,
            "user_id"       : self.appPreference.getUserID(),
            "type"          : type,
            "guided_type"   : "Guided", // 'guided_type'
            "personalise"   : DataManager.sharedInstance.postData
            ] as [String : Any]
        
        WWMWebServices.requestAPIWithBody(param:param as [String : Any] , urlString: URL_MEDITATIONDATA, context: "WWMConOnboardingVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                print("result signupletsstartvc meditation data... \(result)")
                self.appPreference.setType(value: type)
                self.appPreference.setGuideType(value: "Guided")
                self.appPreference.setGuideTypeFor3DTouch(value: type)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.appPreference.setGetProfile(value: true)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMTabBarVC") as! WWMTabBarVC
                    UIApplication.shared.keyWindow?.rootViewController = vc
                    //UIApplication.shared.keyWindow?.rootViewController = AppDelegate.sharedDelegate().animatedTabBarController()
                }
            }else {
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
    
    func handleNextBtn() {
        self.nextBtn.isEnabled = (self.multipleSelectedRow.count == 0) ? false : true
        self.nextBtn.setTitleColor((self.multipleSelectedRow.count == 0) ? .gray : .white, for: .normal)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        if let pageInfo = self.pageInfoArray.last{
            self.multipleSelectedRow.removeAll() // new
            self.pageInfoArray.removeLast()
            DataManager.sharedInstance.deletePostData()
            self.unselectAllSelectedOptions()
            
            let pageInformation = pageInfo as! (pageId: Int, multiSelection: [Int])
            
            self.selectedOption(nextPageId: pageInformation.pageId, isNavigateForward: false)
            
            if (pageInformation.multiSelection.count > 0) {
                
                self.multipleSelectedRow = pageInformation.multiSelection
                self.handleNextBtn()
                for selectedSection in self.multipleSelectedRow {
                    
                    let indexPath = IndexPath(row: 0, section: selectedSection)
                    boardingTable.selectRow(at: indexPath, animated: false, scrollPosition: .none )
                    let option = self.optionList[selectedSection]
                    option.isSelected = true
                }
            }
        }
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        
        // fetch priority for nextQuestion/nextPage from the selected options
        var listOfNextQues: [Int] = []
        for selectedCell in self.multipleSelectedRow {
            
            let selectedOpt = self.optionList[selectedCell]
            listOfNextQues.append(selectedOpt.next_question!)
        }
        
        var nextQuestion = -1
        let uniqueQues = Array(Set(listOfNextQues))
        
        if (uniqueQues.count <= 2) {
            nextQuestion = uniqueQues.last!
        }
        else
        {
            let firstIndexQues = uniqueQues[0]
            let secondIndexQues = uniqueQues[1]
            
            let firstQuesArray = listOfNextQues.filter({$0 == firstIndexQues})
            let secondQuesArray = listOfNextQues.filter({$0 == secondIndexQues})
            
            nextQuestion = (firstQuesArray.count > secondQuesArray.count) ? firstQuesArray[0] : secondQuesArray[0]
        }
        
        self.selectedOption(nextPageId: nextQuestion, isNavigateForward: true)
        self.multipleSelectedRow.removeAll()
    }
    
    
    //In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //if let VC = segue.destination as? WWMPopoverOnboardingVC {
        //}
    }
    
}


extension WWMConOnboardingVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.optionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustOnboardingCell")! as! WWMCustOnboardingCell
        
        let image = UIImageView(image: UIImage(named: "smallArrow.png"))
        cell.accessoryView = (self.isMultipleSelection == 0) ? image:nil
        
        let selectedBGImage = UIImageView(image: UIImage(named: "cellSelectedBG.png"))
        cell.selectedBackgroundView = selectedBGImage
        
        let bgImage = UIImageView(image: UIImage(named: "cellBG.png"))
        cell.backgroundView = bgImage
        
        //cell.tintColor = UIColor(red: 0/255, green: 23/255, blue: 108/255, alpha: 1.0) // new
        
        // new
        let chkMarkImage = UIImageView(image: UIImage(named: "selectedChkMark.png")) // new
        cell.accessoryView = (self.multipleSelectedRow.contains(indexPath.section)) ? chkMarkImage : nil
        //cell.accessoryType = (self.multipleSelectedRow.contains(indexPath.section)) ? .checkmark : .none
        cell.setCellData(options: self.optionList[indexPath.section])
        return cell
    }
    
    
}

extension WWMConOnboardingVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //let cell:WWMCustOnboardingCell = tableView.cellForRow(at: indexPath) as! WWMCustOnboardingCell
        let selectedOpt = self.optionList[indexPath.section]
        selectedOpt.isSelected = true
        
        if (self.isMultipleSelection == 0) {
            if let nextQues = selectedOpt.next_question {
                self.selectedOption(nextPageId: nextQues, isNavigateForward: true)
            }
            else {
                self.createPostData()
                DataManager.sharedInstance.postOnboardingRequest()
                if let exitPoint = selectedOpt.exitPoint {
                    self.meditationApi(type: exitPoint);
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Next_Question: Null", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else {
            
            let image = UIImageView(image: UIImage(named: "selectedChkMark.png")) // new
            tableView.cellForRow(at: indexPath)?.accessoryView = image
            
            //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.multipleSelectedRow.append(indexPath.section)
            self.handleNextBtn()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryView = nil // new
        //tableView.cellForRow(at: indexPath)?.accessoryType = .none
        self.multipleSelectedRow.removeAll(where: { $0 == indexPath.section } )
        
        let selectedOpt = self.optionList[indexPath.section]
        selectedOpt.isSelected = false
        self.handleNextBtn()
    }
    
    
}


// Maintain multiple selection when moved forward
