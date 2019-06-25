import Foundation

class ChartApi{
    
  static var graphScore: [[String: Any]] = []
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
}
