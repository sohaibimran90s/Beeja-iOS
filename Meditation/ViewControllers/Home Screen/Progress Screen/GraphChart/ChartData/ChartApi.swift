import Foundation

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
    
    let params = ["user_id": appPreference.getUserID(),"med_type" : appPreference.getType(), "date": xData, "type": type]
    
    print("graph params... \(params)")
    
    let headers = [
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "cache-control": "no-cache"
    ]
    
    var request = URLRequest(url: URL(string: URL_MOODPROGRESS)!)
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
