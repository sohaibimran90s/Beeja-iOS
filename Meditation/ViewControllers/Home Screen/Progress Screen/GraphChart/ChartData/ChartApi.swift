import Foundation
import SwiftyRSA
import UIKit

class ChartApi{
    
  static var type: String = ""
  static func getChartData( completion : @escaping ([MoodData]?, Error?)-> Void){
    
    
//    let data = Response<MoodResponse>.getMoodData()
//    completion(data, nil)
//    return
    
    
    let appPreference = WWMAppPreference()
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "yyyyMMdd"
    let xData = dateFormatter.string(from: currentDate)
    print(xData)
    
    
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
    x_Params["Context"] = "ChartApi"
    x_Params["Manufacturer"] = "iPhone"
    x_Params["Model"] = UIDevice.modelName
    x_Params["OS"] = "iOS" + os_version
    x_Params["Missing Permissions"] = ""
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
    
    
    
    let params = ["user_id": appPreference.getUserID(),"med_type" : appPreference.getType(), "date": xData, "type": type]
    
    print("graph params... \(params)")
    
    let headers = [
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "cache-control": "no-cache",
        "X-Params": X_Params
    ]
    
    
    var request = URLRequest(url: URL(string: URL_MOODPROGRESS)!)
    
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
        print("Failed")
        print(error)
    }
    
    
    request.httpMethod = "POST"
    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
    request.allHTTPHeaderFields = headers
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        print("response.... \(response) data.... \(data)")
       
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            //print("json++++++.. \(json)")
            if let data = data{
                
                let response = try! JSONDecoder().decode(Response<MoodResponse>.self, from: data)
                print("response.result!.graph_score... \(response.result!.graph_score)")
                
                var model1: [MoodData] = []
                model1 = response.result!.graph_score
                
                completion(model1, nil)
            }
            
        } catch {
            print("error")
        }
    })
    
    task.resume()
    }
}
