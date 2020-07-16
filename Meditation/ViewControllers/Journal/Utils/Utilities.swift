//
//  Utilities.swift
//  DLP
//
//  Created by Invenco  on 08/09/18.
//  Copyright © 2018 Invenco Solutions . All rights reserved.
//

import UIKit

class Utilities: NSObject {
    
    class func getAppVersionNumber() -> String
    {
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "0.0.0"
    }
    
    class func getDocumentsDirectory() -> URL
     {
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         let documentsDirectory = paths[0]
         return documentsDirectory
     }

    class func getFileUrl(fileName: String) -> URL
     {
        //let filename = "myRecording.m4a"
        let filePath = Utilities.getDocumentsDirectory().appendingPathComponent(fileName)
        return filePath
     }

    class func paymentController(container: AnyObject) {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentView") as! PaymentVC
        vc.modalPresentationStyle = .overFullScreen
        container.present(vc, animated: true, completion: nil)
    }
}
