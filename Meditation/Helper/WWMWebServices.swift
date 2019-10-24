//
//  WWMWebServices.swift
//  Meditation
//
//  Created by Akram khan on 22/10/19.
//  Copyright © 2019 Cedita. All rights reserved.
//


import Foundation
import UIKit
import SwiftyRSA
import Alamofire

class WWMWebServices {
    
    typealias ASCompletionBlockAsDictionary = (_ result: Dictionary<String, Any>, _ error: Error?, _ success: Bool) -> Void
    typealias ASCompletionBlockAsArray = (_ result: Array<Any>, _ error: Error?, _ success: Bool) -> Void
    typealias ASCompletionBlockAsImage = (_ result: UIImage, _ error: Error?, _ success: Bool) -> Void
    
    // 1st Calls of API
    class func requestAPIWithBodyForceUpdate(urlString:String, context: String, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        //Modified By Akram.
        //   let configuration = URLSessionConfiguration.default
        //  let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        // var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        //  print("Request URL: \(urlString)")
        // request.httpMethod = "GET"
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        userData = WWMUserData.init(json:appPreffrence.getUserData())
        print(userData)
        
        let os = ProcessInfo().operatingSystemVersion
        let os_version: String = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        
        x_Params["app_ver"] = WWMHelperClass.getVersion()
        x_Params["build_no"] = WWMHelperClass.getBuildVersion()
        x_Params["LC"] = userData.country
        x_Params["LG"] = "en"
        x_Params["Context"] = context
        x_Params["Manufacturer"] = "iPhone"
        x_Params["Model"] = UIDevice.modelName
        x_Params["OS"] = "iOS" + os_version
        x_Params["Missing Permissions"] = appPreffrence.getLoctionDenied()
        x_Params["Architecture"] = ""
        x_Params["Connection_type"] = appPreffrence.getConnectionType()
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: x_Params,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            X_Params = theJSONText ?? ""
            //print("JSON string = \(theJSONText!)")
        }
        
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "cache-control": "no-cache",
            "X-Params": X_Params
        ]
        // request.allHTTPHeaderFields = headers
        
        Alamofire.request(urlString, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                if response.data != nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: [])
                        let results = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                        print("Result: \(myString ?? "")")
                        
                        completionHandler(json  as! Dictionary<String, Any>, nil, true)
                        return
                    }catch {
                        print(error.localizedDescription)
                        completionHandler([:], error, false)
                        return;
                    }
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    //2nd Call of API
    //MARK: - Service Methods
    class func requestAPIWithBody(param:[String:Any], urlString:String, context: String, headerType:String, isUserToken:Bool, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        
        var RSAparam: String = ""
        //    let configuration = URLSessionConfiguration.default
        //  let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        userData = WWMUserData.init(json:appPreffrence.getUserData())
        print(userData)
        
        let os = ProcessInfo().operatingSystemVersion
        let os_version: String = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        
        x_Params["app_ver"] = WWMHelperClass.getVersion()
        x_Params["build_no"] = WWMHelperClass.getBuildVersion()
        x_Params["LC"] = userData.country
        x_Params["LG"] = "en"
        x_Params["Context"] = context
        x_Params["Manufacturer"] = "iPhone"
        x_Params["Model"] = UIDevice.modelName
        x_Params["OS"] = "iOS" + os_version
        x_Params["Missing Permissions"] = appPreffrence.getLoctionDenied()
        x_Params["Architecture"] = ""
        x_Params["Connection_type"] = appPreffrence.getConnectionType()
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: x_Params,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            X_Params = theJSONText ?? ""
            //print("JSON string = \(theJSONText!)")
        }
        
        print("X_Params.... \(X_Params)")
        
        //   var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        
        //  let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        //   let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        // print("Request URL: \(urlString)")
        //print("Data: \(myString!)")
        if param.count>0 {
            //  request.httpBody = jsonData
        }
        //   request.httpMethod = headerType
        
        // RSA Implementation
        do {
            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
            }
            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            let publicKey = try PublicKey.init(pemEncoded: keyString)
            
            let clear = try ClearMessage(string:"pulse", using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
            RSAparam = "pulse:" + base64String
            
            //    request.addValue(param, forHTTPHeaderField: "Authorization")
            //Authorize
            //Authorization
            
        } catch {
            print("Failed")
            print(error)
        }
        
        if isUserToken {
            let appPreference = WWMAppPreference()
            //  request.setValue(appPreference.getToken(), forHTTPHeaderField: "header")
        }
        
        
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "cache-control": "no-cache",
            "X-Params": X_Params,
            "Authorization": RSAparam,
            "header": appPreffrence.getToken()
        ]
        //   request.allHTTPHeaderFields = headers
        
        
        
        if isUserToken {
            let appPreference = WWMAppPreference()
            //   request.setValue(appPreference.getToken(), forHTTPHeaderField: "header")
        }
        
        //  request.timeoutInterval = 45
        // var postDataTask = URLSessionDataTask()
        // postDataTask.priority = URLSessionDataTask.highPriority
        
        /*   postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
         //            var json : (Any);
         if data != nil && response != nil {
         do {
         let json = try JSONSerialization.jsonObject(with: data!, options: [])
         let results = try? JSONSerialization.jsonObject(with: data!, options: [])
         let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
         let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
         print("Result: \(myString ?? "")")
         
         completionHandler(json  as! Dictionary<String, Any>, nil, true)
         return
         }catch {
         print(error.localizedDescription)
         completionHandler([:], error, false)
         return;
         }
         
         }else if error != nil {
         
         completionHandler([:], error, false)
         }else {
         completionHandler([:], nil, false)
         }
         })
         postDataTask.resume()*/
        var methodTypes: HTTPMethod = .get
        if(headerType == kPOSTHeader)
        {
            print("Postingo")
            methodTypes = .post
        }
        else{
            print("Getingo")
            methodTypes = .get
        }
        
        Alamofire.request(urlString, method: methodTypes, parameters: param,encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                if response.data != nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: [])
                        let results = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                        print("Result: \(myString ?? "")")
                        
                        completionHandler(json  as! Dictionary<String, Any>, nil, true)
                        return
                    }catch {
                        print(error.localizedDescription)
                        completionHandler([:], error, false)
                        return;
                    }
                }
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //3rd Call Of Api
    class func request(params : [String:Any], urlString : String, imgData : Data?, image: UIImage?, isHeader : Bool , completionHandler: @escaping ASCompletionBlockAsDictionary) -> Void {
        
        var param: String = ""
        
        let stringUrl = urlString
        
        // generate boundary string using a unique per-app string
        //   let boundary = UUID().uuidString
        
        // let config = URLSessionConfiguration.default
        //   let session = URLSession(configuration: config)
        
        print("\n\ncomplete Url :-------------- ",stringUrl," \n\n-------------: complete Url")
        //guard let url = URL(string: stringUrl) else { return }
        // var request = URLRequest(url: url)
        // request.httpMethod = "POST"
        // RSA Implementation
        
        do {
            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
            }
            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            let publicKey = try PublicKey.init(pemEncoded: keyString)
            
            let clear = try ClearMessage(string:"pulse", using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
            //let param = "pulse:" + base64String
            param = "pulse:" + base64String
            
            //  request.addValue(param, forHTTPHeaderField: "Authorization")
            //Authorize
            //Authorization
            
        } catch {
            print("Failed")
            print(error)
        }
        
        //let url1 = urlString
        //  let token = getUserToken() as NSString
        // let str = params
        
        let headers: HTTPHeaders = [
            "Authorization":param,
            "Content-type": "multipart/form-data",
            //  "User-Agent": "Skor/3 \(getDeviceInfo())"
            
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imgData{
                multipartFormData.append(data, withName: "file[]", fileName: "file", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: urlString, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    switch response.result {
                    case .success:
                        print(response)
                        if response.data != nil {
                            do {
                                let json = try JSONSerialization.jsonObject(with: response.data!, options: [])
                                let results = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                                let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                                print("Result: \(myString ?? "")")
                                
                                completionHandler(json  as! Dictionary<String, Any>, nil, true)
                                return
                            }catch {
                                print(error.localizedDescription)
                                completionHandler([:], error, false)
                                return;
                            }
                        }
                        break
                    case .failure(let error):
                        print(error)
                    }
                    
                    /*
                     if let err = response.error{
                     //  onError?(err)
                     return
                     }*/
                    
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                //  onError?(error)
            }
        }
        
        
    }
    
    //4th Call Of API- This API is not calling anywhere in whole source code So Alamofire not implemented in this method.
    // RSA Encryption
    class func requestAPIRSAEncryption(param:String, urlString:String, headerType:String, context: String, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        
        // let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        
        // let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        print("Request URL: \(urlString)")
        print("Data: \(param)")
        //        if param.count>0 {
        //            request.httpBody = jsonData
        //        }
        request.httpMethod = headerType
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        userData = WWMUserData.init(json:appPreffrence.getUserData())
        print(userData)
        
        let os = ProcessInfo().operatingSystemVersion
        let os_version: String = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        
        x_Params["app_ver"] = WWMHelperClass.getVersion()
        x_Params["build_no"] = WWMHelperClass.getBuildVersion()
        x_Params["LC"] = userData.country
        x_Params["LG"] = "en"
        x_Params["Context"] = context
        x_Params["Manufacturer"] = "iPhone"
        x_Params["Model"] = UIDevice.modelName
        x_Params["OS"] = "iOS" + os_version
        x_Params["Missing Permissions"] = appPreffrence.getLoctionDenied()
        x_Params["Architecture"] = ""
        x_Params["Connection_type"] = appPreffrence.getConnectionType()
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: x_Params,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            X_Params = theJSONText ?? ""
            //print("JSON string = \(theJSONText!)")
        }
        
        print("X_Params.... \(X_Params)")
        
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "X-Params": X_Params
        ]
        request.allHTTPHeaderFields = headers
        request.addValue(param, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        // postDataTask.priority = URLSessionDataTask.highPriority
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    print("Result: \(myString ?? "")")
                    
                    completionHandler(json  as! Dictionary<String, Any>, nil, true)
                    return
                }catch {
                    print(error.localizedDescription)
                    completionHandler([:], error, false)
                    return;
                }
                
            }else if error != nil {
                completionHandler([:], error, false)
            }else {
                completionHandler([:], nil, false)
            }
        })
        postDataTask.resume()
    }
    
    
    
    //5th Call of API
    class func requestwithImageUrl(url: URL, completionHandler: @escaping ASCompletionBlockAsImage) -> Void {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if  let data = data, error == nil{
                if let image = UIImage(data: data) {
                    
                    completionHandler(image, nil, true)
                }else {
                    let imageDefault = UIImage.init(named: "AppIcon")
                    completionHandler(imageDefault!, nil, true)
                }
            } else if error != nil {
                completionHandler(UIImage(), error, false)
            }else {
                completionHandler(UIImage(), nil, false)
            }
            }.resume()
        
    }
}

