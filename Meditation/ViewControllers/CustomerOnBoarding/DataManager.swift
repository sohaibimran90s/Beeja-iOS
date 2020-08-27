//
//  DataManager.swift
//  MeditationDemo
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit
import Alamofire

class DataManager: NSObject {
    static let sharedInstance = DataManager ()
    var isPaidAc = false
    
    var postData: [Any] = []

    func getOptionList(selectedOptionList: [OptionsData], currentPage: GetData) {
        var selectedId: [Int] = []
        for option in selectedOptionList {
            if let id = option.id{
                selectedId.append(id)
            }
        }
        let postBody = self.postBody(currentPageId: currentPage.id!, selectedOption: selectedId, isMultiple: Bool(truncating: currentPage.multiple_selection! as NSNumber))
        self.postData.append(postBody)
    }
    
    func deletePostData() {
        self.postData.removeLast()
    }
    
    func postBody(currentPageId: Int, selectedOption: [Int], isMultiple: Bool) -> Any
    {
        let jsonBody = ["question_id":currentPageId,
                        "answer":selectedOption,
                        "is_multiple": isMultiple
                           ] as [String : Any];
        
        return jsonBody;
    }

    func postOnboardingRequest() {
        print(self.postData)
    }
    
    
    
    
    //MARK: Journal APIs
    
    func addJournalAPI(body: Any, completion:@escaping (Bool, Int, String) -> Void) {
        
        WWMWebServices.requestAPIWithBody(param: body as! [String : Any], urlString: URL_ADDJOURNAL, context: "WWMMyProgressJournalVC", headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
            if sucess {
                let journalID = (result["journal_id"] as AnyObject? as? Int) ?? 0
                if (journalID != 0) {
                    
                    completion(true, journalID, "")
                }
                else {
                    completion(false, 0, "")
                }
            }
            else {
                completion(false, 0, error!.localizedDescription)
            }
        }
    }
//    multipartFormData.append(imageData, withName: "audios[]",
//                             fileName: "\(Date().timeIntervalSince1970).m4a", mimeType: "audio/m4a")

    func uploadAssets(imageDataArray: [Data], parameter: [String: AnyObject], completion:@escaping(Bool, String) -> Void) {

        let assetsType = parameter["journal_type"] as! String
        let withName = (assetsType == "audio") ? "audios[]" : "images[]"
        //let exten = (assetsType == "audio") ? "m4a" : "jpeg"
        let mineType = (assetsType == "audio") ? "audio/m4a" : "image/jpeg"
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 420
        manager.upload(multipartFormData: { multipartFormData in
        //Alamofire.upload(multipartFormData: { multipartFormData in
            // import image to request
            for imageData in imageDataArray {
                multipartFormData.append(imageData, withName: withName,
                                         fileName: "\(Date().timeIntervalSince1970)", mimeType: mineType)
            }
            
            //let param = parameter as! [String: AnyObject]
            for (key, value) in parameter {
                
                let valueStr = String(describing: value)
                if let data = valueStr.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    multipartFormData.append(data, withName: key)
                }
            }

        }, to: URL_UPLOADASSETS,

            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload
                        .validate()
                        .responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                print("responseObject: \(value)")
                                completion(true, "")
                            case .failure(let responseError):
                                print("responseError: \(responseError)")
                                completion(false, responseError.localizedDescription)
                            }
                    }

                case .failure(let error):
                    print(error)
                    completion(false, error.localizedDescription)
                }
        })
    }


}
