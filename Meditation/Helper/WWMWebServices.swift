//
//  WWMWebServices.swift
//  Meditation
//
//  Created by Roshan Kumawat on 21/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//


import Foundation
import UIKit
import SwiftyRSA

class WWMWebServices {
    
    
    
    typealias ASCompletionBlockAsDictionary = (_ result: Dictionary<String, Any>, _ error: Error?, _ success: Bool) -> Void
    typealias ASCompletionBlockAsArray = (_ result: Array<Any>, _ error: Error?, _ success: Bool) -> Void
    typealias ASCompletionBlockAsImage = (_ result: UIImage, _ error: Error?, _ success: Bool) -> Void
    
    //MARK: - Service Methods
    
    class func requestAPIWithBody(param:[String:Any], urlString:String, context: String, headerType:String, isUserToken:Bool, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        
        if (appPreffrence.getUserData() as? [String: Any]) != nil{
            userData = WWMUserData.init(json:appPreffrence.getUserData())
            //print(userData)
        }
        
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
        
        //print("X_Params.... \(X_Params)")
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        //print("Request URL: \(urlString) Data: \(myString!)")
        if param.count>0 {
            request.httpBody = jsonData
        }
        request.httpMethod = headerType
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "cache-control": "no-cache",
            "X-Params": X_Params
        ]
        request.allHTTPHeaderFields = headers
        
        // RSA Implementation
        
        do {
            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
            }
            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            let publicKey = try PublicKey.init(pemEncoded: keyString)
            
            let clear = try ClearMessage(string:"pulse", using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
            let param = "pulse:" + base64String
            
            request.addValue(param, forHTTPHeaderField: "Authorization")
            //Authorize
            //Authorization
            
        } catch {
            //print("Failed")
            print(error)
        }
        
        if isUserToken {
            let appPreference = WWMAppPreference()
            request.setValue(appPreference.getToken(), forHTTPHeaderField: "header")
        }
        
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        // postDataTask.priority = URLSessionDataTask.highPriority
        
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    //let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    //let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    //let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    //print("Result: \(myString ?? "")")
                    
                    completionHandler(json  as! Dictionary<String, Any>, nil, true)
                    return
                }catch {
                    //print(error.localizedDescription)
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
    
    
    
    
    class func request(params : [String:Any], urlString : String, imgData : Data?, image: UIImage?, isHeader : Bool , completionHandler: @escaping ASCompletionBlockAsDictionary) -> Void {
        
        let stringUrl = urlString
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //print("\n\ncomplete Url :-------------- ",stringUrl," \n\n-------------: complete Url")
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // RSA Implementation
        
        do {
            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
            }
            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            let publicKey = try PublicKey.init(pemEncoded: keyString)
            
            let clear = try ClearMessage(string:"pulse", using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
            let param = "pulse:" + base64String
            
            request.addValue(param, forHTTPHeaderField: "Authorization")
            //Authorize
            //Authorization
            
        } catch {
            //print("Failed")
            print(error)
        }
        
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        for(key, value) in params{
            // Add the reqtype field and its value to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)".data(using: .utf8)!)
        }
        
        let fileName: String = "file"
        if image != nil {
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file[]\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(image!.pngData()!)
        }
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            
            if let checkResponse = response as? HTTPURLResponse{
                if checkResponse.statusCode == 200{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) else {
                        completionHandler([:], nil, false)
                        return
                    }
                    //let jsonString = String(data: data, encoding: .utf8)!
                    //print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    //print(json)
                    completionHandler(json as! [String:Any], nil, true)
                    
                }else{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        completionHandler([:], nil, false)
                        return
                    }
                    //let jsonString = String(data: data, encoding: .utf8)!
                    //print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    //print(json)
                    completionHandler(json as! [String:Any], nil, true)
                }
            }else{
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler([:], nil, false)
                    return
                }
                completionHandler([:], nil, false)
            }
            
        }).resume()
        
    }
    
    class func request1(params : [String:Any], urlString : String, imgData : Data?, image: UIImage?, isHeader : Bool , completionHandler: @escaping ASCompletionBlockAsDictionary) -> Void {
        
        let stringUrl = urlString
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //print("\n\ncomplete Url :-------------- ",stringUrl," \n\n-------------: complete Url")
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // RSA Implementation
        do {
            guard let path = Bundle.main.path(forResource: "public", ofType: "pem") else { return
            }
            let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            let publicKey = try PublicKey.init(pemEncoded: keyString)

            let clear = try ClearMessage(string:"pulse", using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let base64String = encrypted.base64String
            let param = "pulse:" + base64String

            request.addValue(param, forHTTPHeaderField: "Authorization")
            //Authorize
            //Authorization

        } catch {
            //print("Failed")
            print(error)
        }
        // RSA Implementation end
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        for(key, value) in params{
            // Add the reqtype field and its value to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)".data(using: .utf8)!)
        }
        
        let fileName: String = "avatar"
        if image != nil {
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(image!.pngData()!)
        }
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            
            if let checkResponse = response as? HTTPURLResponse{
                if checkResponse.statusCode == 200{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) else {
                        completionHandler([:], nil, false)
                        return
                    }
                    //let jsonString = String(data: data, encoding: .utf8)!
                    //print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    //print(json)
                    completionHandler(json as! [String:Any], nil, true)
                    
                }else{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        completionHandler([:], nil, false)
                        return
                    }
                    //let jsonString = String(data: data, encoding: .utf8)!
                    //print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    //print(json)
                    completionHandler(json as! [String:Any], nil, true)
                }
            }else{
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler([:], nil, false)
                    return
                }
                completionHandler([:], nil, false)
            }
            
        }).resume()
        
    }
    
    // RSA Encryption
    
    class func requestAPIRSAEncryption(param:String, urlString:String, headerType:String, context: String, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        
        // let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        // let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        //print("Request URL: \(urlString)")
        //print("Data: \(param)")
        //        if param.count>0 {
        //            request.httpBody = jsonData
        //        }
        request.httpMethod = headerType
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        
        if (appPreffrence.getUserData() as? [String: Any]) != nil{
            userData = WWMUserData.init(json:appPreffrence.getUserData())
            //print(userData)
        }
        
        
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
        
        //print("X_Params.... \(X_Params)")
        
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
                    //print("Result: \(myString ?? "")")
                    
                    completionHandler(json  as! Dictionary<String, Any>, nil, true)
                    return
                }catch {
                    //print(error.localizedDescription)
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
    
    
    class func requestAPIWithBodyForceUpdate(urlString:String, context: String, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        //print("Request URL: \(urlString)")
        request.httpMethod = "GET"
        
        var x_Params: [String: Any] = [:]
        var X_Params: String = ""
        
        var userData = WWMUserData()
        let appPreffrence = WWMAppPreference()
        
        if (appPreffrence.getUserData() as? [String: Any]) != nil{
            userData = WWMUserData.init(json:appPreffrence.getUserData())
            //print(userData)
        }
        
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
        request.allHTTPHeaderFields = headers
        
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        // postDataTask.priority = URLSessionDataTask.highPriority
        
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    //let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    //let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    //let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    //print("Result: \(myString ?? "")")
                    
                    completionHandler(json  as! Dictionary<String, Any>, nil, true)
                    return
                }catch {
                    //print(error.localizedDescription)
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

