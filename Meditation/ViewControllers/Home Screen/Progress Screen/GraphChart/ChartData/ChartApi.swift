import Foundation
import UIKit

class ChartApi{
    
    static var graphScore: [[String: Any]] = []
//    static func getChartData( completion : @escaping ([MoodData]?, Error?)-> Void){
//
//        let appPreference = WWMAppPreference()
//
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = NSLocale.current
//        dateFormatter.dateFormat = "yyyyMMdd"
//        let xData = dateFormatter.string(from: currentDate)
//        print(xData)
//
//        let param = ["user_id": appPreference.getUserID(),"med_type" : appPreference.getType(), "date": xData, "type": "weekly"]
//        WWMWebServices.requestAPIWithBody(param: param, urlString: URL_MOODPROGRESS, headerType: kPOSTHeader, isUserToken: true) { (result, error, sucess) in
//            if sucess {
//
//                if let statsData = result["result"] as? [String:Any] {
//                    if let graph_score = statsData["graph_score"] as? [[String:Any]] {
//                        print("graph_score.... \(graph_score)")
//
//
//
//
//                        if let model = try? JSONDecoder().decode(Response<Response<MoodResponse>>.self, from: self.stringArrayToData(stringArray: graph_score)!), let moodData = model.result?.result?.graph_score{
//                            completion(moodData, nil)
//                        }
//                    }
//                    print("statsData.... \(statsData)")
//
//                }
//            }
//        }
//    }
    
    static func getChartData( completion : @escaping ([MoodData]?, Error?)-> Void){
        let headers = [
            "Content-Type": "application/json"
        ]
        let parameters = [
            "user_id": 239,
            "type": "yearly",
            "med_type": "timer"
            ] as [String : Any]
        
        let data = Response<MoodResponse>.getMoodData(graphScore: graphScore)
        completion(data, nil)
        return
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://service.launchpad-stage.in/api/v1/graphApi")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if (error != nil) {
                print(error)
                completion(nil, error)
            } else if let data = data{
                if let model = try? JSONDecoder().decode(Response<Response<MoodResponse>>.self, from: data), let moodData = model.result?.result?.graph_score{
                    completion(moodData, nil)
                }
                
            }
        })
        
        dataTask.resume()
    }
    
    static  func stringArrayToData(stringArray: [[String: Any]]) -> Data? {
        print("stringArray... \(stringArray)")
        return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
    }
}
