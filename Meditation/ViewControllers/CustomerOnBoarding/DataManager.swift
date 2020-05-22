//
//  DataManager.swift
//  MeditationDemo
//
//  Created by Ehsan on 16/5/20.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    static let sharedInstance = DataManager ()
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
}
