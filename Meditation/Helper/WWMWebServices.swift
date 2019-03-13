//
//  WWMWebServices.swift
//  Meditation
//
//  Created by Roshan Kumawat on 21/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//


import Foundation
import UIKit

class WWMWebServices {
    
    
    
    typealias ASCompletionBlockAsDictionary = (_ result: Dictionary<String, Any>, _ error: Error?, _ success: Bool) -> Void
    typealias ASCompletionBlockAsArray = (_ result: Array<Any>, _ error: Error?, _ success: Bool) -> Void
    
    
    
    //MARK: - Service Methods
    
   class func requestAPIWithBody(param:[String:Any], urlString:String, headerType:String, isUserToken:Bool, completionHandler:@escaping ASCompletionBlockAsDictionary) -> Void {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
    
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
    
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        print("Request URL: \(urlString)")
        print("Data: \(myString!)")
        if param.count>0 {
            request.httpBody = jsonData
        }
        request.httpMethod = headerType
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "cache-control": "no-cache"
        ]
        request.allHTTPHeaderFields = headers
        
        
        if isUserToken {
            let appPreference = WWMAppPreference()
            request.setValue(appPreference.getToken(), forHTTPHeaderField: "header")
        }
        
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        postDataTask.priority = URLSessionDataTask.highPriority
        
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
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
        postDataTask.resume()
    }
    
    
    class func formRequestApiWithBody( param : [String:Any], urlString : String, imgData : Data?, isHeader : Bool , completionHandler : @escaping ASCompletionBlockAsDictionary) -> Void {

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        print("Request URL: \(urlString)")
        print("Data: \(myString!)")
        if param.count>0 {
            request.httpBody = jsonData
        }
        request.httpMethod = "POST"
        let headers = [
            "Content-Type": "application/json",
            "X-Requested-With": "XMLHttpRequest",
            "cache-control": "no-cache"
        ]
        request.allHTTPHeaderFields = headers
        
        
        if isHeader {
            let appPreference = WWMAppPreference()
            request.setValue(appPreference.getToken(), forHTTPHeaderField: "header")
        }

        var body = Data()
        let boundary: String = "0xKhTmLbOuNdArY"
        let kNewLine: String = "\r\n"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        // Add the parameters from the dictionary to the request body
        let arrKeys = param.keys
        for name: String in arrKeys {
            let value: Data? = "\( param[name] as! String)".data(using: String.Encoding.utf8)
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\("file[]")\"".data(using: String.Encoding.utf8)!)
            // For simple data types, such as text or numbers, there's no need to set the content type
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(value!)
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
        }

        // Add the image to the request body
        if imgData != nil {
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"file[]\"; filename=\"uploadPhoto.jpeg\"\("image")".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: image/jpeg".data(using: String.Encoding.utf8)!)
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(imgData ?? Data())
            print(imgData ?? Data())
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
        }
        // Add the terminating boundary marker to signal that we're at the end of the request body
        body.append("--\(boundary)--".data(using: String.Encoding.utf8)!)

        request.httpBody = body;
        var postDataTask = URLSessionDataTask()
        postDataTask.priority = URLSessionTask.highPriority

        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    print("Result: \(myString ?? "")")

                    completionHandler(json as! [String:Any], nil, true)
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
    
    
}

