//
//  WWMEditProfileVC.swift
//  Meditation
//
//  Created by Prema Negi on 08/01/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class WWMEditProfileVC: WWMBaseViewController {

    @IBOutlet weak var textFieldDOB: UITextField!
    @IBOutlet weak var textFieldGender: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintHeightTV: NSLayoutConstraint!
    @IBOutlet weak var btnGender1Action: UIButton!
    
    //Uidate picker
    let datePicker = UIDatePicker()
    var picker  = UIPickerView()
    var toolBar = UIToolbar()
    
    var genderList: [String] = ["Female", "Male", "Non-binary", "I'd rather not say"]
    var hideUnhideTable = false
    
    var imageData = Data()
    
    let reachable = Reachabilities()
    var tap = UITapGestureRecognizer()
    
    var alertProfileSuccessPopup = WWMProfileUpdatedPopUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar(isShow: false, title: "")
        self.placeholderColor()
        
        self.tableView.isHidden = true
        self.tableView.layer.cornerRadius = 5
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.constraintHeightTV.constant = 130
        self.textFieldName.delegate = self
        
        self.tap = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.view.addGestureRecognizer(self.tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnGender1Action.isHidden = false
        self.textFieldGender.isUserInteractionEnabled = false
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        btnGender1Action.isHidden = false
        self.textFieldGender.isUserInteractionEnabled = false
        self.view.endEditing(true)
    }
    
    func placeholderColor(){
        self.textFieldDOB.delegate = self
        textFieldDOB.attributedPlaceholder = NSAttributedString(string: "dd-MMM-yyyy",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textFieldGender.attributedPlaceholder = NSAttributedString(string: "select gender",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.getProfileInformation()
    }
    
    func getProfileInformation(){
        
        let profile_img = self.appPreference.getProfileImgURL()
        if profile_img != ""{
            self.profileImg.sd_setImage(with: URL(string: profile_img), placeholderImage: UIImage(named: "editProfileImg"))
        }else{
            self.profileImg.image = UIImage(named: "editProfileImg")
        }
        
        self.textFieldEmail.text = self.appPreference.getEmail()
        self.textFieldName.text = self.appPreference.getUserName()
        self.textFieldGender.text = self.appPreference.getGender()
        self.textFieldDOB.text = self.appPreference.getDob()
    }
    
    @IBAction func btnUploadImgAction(_ sender: UIButton) {
        print("btnUploadHashTagsAction detect")
        let ImagePickerManager = WWMImagePickerManager()
        ImagePickerManager.pickImage(self){ image in
            //here is the image
            self.imageData = image.jpegData(compressionQuality: 0.75)!
            self.profileImg.backgroundColor = UIColor.clear
            self.profileImg.image = image
            print("%@",self.imageData)
            print("Get Image Data")
        }
    }
    
    @IBAction func btnUploadImg1Action(_ sender: UIButton) {
        print("btnUploadHashTagsAction detect")
        let ImagePickerManager = WWMImagePickerManager()
        ImagePickerManager.pickImage(self){ image in
            //here is the image
            self.imageData = image.jpegData(compressionQuality: 0.75)!
            self.profileImg.backgroundColor = UIColor.clear
            self.profileImg.image = image
            print("%@",self.imageData)
            print("Get Image Data")
        }
    }
    
    @IBAction func btnGenderAction(_ sender: UIButton) {
        
        self.showGenderPicker()
        
//        if hideUnhideTable{
//            self.tableView.isHidden = true
//            hideUnhideTable = false
//        }else{
//            self.tableView.isHidden = false
//            hideUnhideTable = true
//        }
    }
    
    @IBAction func btnGender1Action(_ sender: UIButton) {
        btnGender1Action.isHidden = true
        self.showGenderPicker()
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        
        if reachable.isConnectedToNetwork() {
            print("name... \(String(describing: self.textFieldName.text))")
            print("trim name... \(String(describing: self.textFieldName.text?.trimmingCharacters(in: .whitespaces)))")
            print("email... \(String(describing: self.textFieldEmail.text))")
            print("gender... \(String(describing: self.textFieldGender.text))")
            print("dob... \(String(describing: self.textFieldDOB.text))")
            
            self.uploadProfileAPI(image: self.profileImg.image ?? UIImage(named: "editProfileImg")!)
         }else {
            WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
        }
    }
    
    func showDatePicker(){
      //Formate Date
      datePicker.datePickerMode = .date
      datePicker.maximumDate = Date()

      //ToolBar
      let toolbar = UIToolbar()
      toolbar.sizeToFit()
        
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
      doneButton.tintColor = UIColor.white
    
      let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
      cancelButton.tintColor = UIColor.white

      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      
      toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)

      textFieldDOB.inputAccessoryView = toolbar
      textFieldDOB.inputView = datePicker
    }

     @objc func donedatePicker(){

      let formatter = DateFormatter()
      formatter.dateFormat = "dd-MMM-yyyy"
      textFieldDOB.text = formatter.string(from: datePicker.date)
      self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
       self.view.endEditing(true)
     }
    
    func showGenderPicker(){
        
        btnGender1Action.isHidden = false
        self.textFieldGender.isUserInteractionEnabled = true
        picker.delegate = self
        picker.dataSource = self
        self.textFieldGender.inputView = picker
        self.textFieldGender.becomeFirstResponder()
    }
}

extension WWMEditProfileVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.textFieldDOB{
            self.showDatePicker()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.textFieldName{
            let str = (textFieldName.text ?? "") + string
                if string == "" {
                    return true
                }
                let strRegEx = "[A-Z a-z]"
                let emailTest = NSPredicate(format:"SELF MATCHES %@", strRegEx)
                if !emailTest.evaluate(with: string) {
                    return false
                }
                    
                if str.count > 26 {
                    return false
                }
            return true
        }
            return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        btnGender1Action.isHidden = false
        self.textFieldGender.isUserInteractionEnabled = false
        self.view.endEditing(true)
        return true
    }
}

extension WWMEditProfileVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WWMEditProfileTVC") as! WWMEditProfileTVC
        cell.lblGender.text = self.genderList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! WWMEditProfileTVC
        cell.radioImg.image = UIImage(named: "heartFillMedHis")
        self.textFieldGender.text = self.genderList[indexPath.row]
        print("abc")
        
        if hideUnhideTable{
          self.tableView.isHidden = true
          hideUnhideTable = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WWMEditProfileTVC
        cell.radioImg.image = UIImage(named: "heartMedHis")
    }
}

extension WWMEditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(self.genderList[row])
        return self.genderList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print((self.genderList[row]))
        btnGender1Action.isHidden = false
        self.textFieldGender.isUserInteractionEnabled = false
        self.textFieldGender.text = self.genderList[row]
        self.view.endEditing(true)
    }
    
    func uploadProfileAPI(image: UIImage) {
       //WWMHelperClass.showSVHud()
       WWMHelperClass.showLoaderAnimate(on: self.view)
        
        var userName: String = self.textFieldName.text?.trimmingCharacters(in: .whitespaces) ?? "You"
        if userName == ""{
            userName = "You"
        }
        
       let param = [
           "user_id":self.appPreference.getUserID(),
           "dob": self.textFieldDOB.text ?? "",
           "name": userName,
           "gender": self.textFieldGender.text ?? ""
           ] as [String : Any]
        
       print("param... \(param)")
       
       WWMWebServices.request1(params: param, urlString: URL_UPDATE_PROFILE, imgData: self.imageData, image: image, isHeader: true) { (result, error, success) in

           if success {
                print("success... \(result)")
                WWMHelperClass.hideLoaderAnimate(on: self.view)
                
                self.appPreference.setGender(value: result["gender"] as? String ?? "")
                self.appPreference.setDob(value: result["dob"] as? String ?? "")
            
                if let data = result["data"] as? [String: Any]{
                    self.appPreference.setUserName(value: data["name"] as? String ?? "")
                    self.appPreference.setProfileImgURL(value: data["profile_image"] as? String ?? "")
                    self.appPreference.setEmail(value: data["email"] as? String ?? "")
                }
            
                DispatchQueue.main.async{
                    self.xibCall()
                }
           }else {
               if error != nil {
               
                   if error?.localizedDescription == "The Internet connection appears to be offline."{
                       WWMHelperClass.showPopupAlertController(sender: self, message: internetConnectionLostMsg, title: kAlertTitle)
                   }else{
                       WWMHelperClass.showPopupAlertController(sender: self, message: (error?.localizedDescription)!, title: kAlertTitle)
                   }
               
               }
           }
           WWMHelperClass.hideLoaderAnimate(on: self.view)
       }
    }
    
    func xibCall(){
        alertProfileSuccessPopup = UINib(nibName: "WWMProfileUpdatedPopUp", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WWMProfileUpdatedPopUp
        let window = UIApplication.shared.keyWindow!
        
        alertProfileSuccessPopup.frame = CGRect.init(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
        
        alertProfileSuccessPopup.lblTitle.text = kPROFILEUPDATEDSUCCESS
        alertProfileSuccessPopup.btnOK.layer.borderWidth = 2.0
        alertProfileSuccessPopup.btnOK.layer.borderColor = UIColor.init(hexString: "#00eba9")!.cgColor
        
        alertProfileSuccessPopup.btnOK.addTarget(self, action: #selector(btnDoneAction(_:)), for: .touchUpInside)
        window.rootViewController?.view.addSubview(alertProfileSuccessPopup)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.alertProfileSuccessPopup.removeFromSuperview()
    }
}
