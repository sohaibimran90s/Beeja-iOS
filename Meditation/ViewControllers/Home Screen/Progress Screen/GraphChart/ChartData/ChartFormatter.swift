
import UIKit

@objc(BarChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter
{
    var labels: [String]!
    var color: [UIColor] = [
        UIColor(red:1.00, green:0.00, blue:0.14, alpha:1.0),
        UIColor(red:0.09, green:0.24, blue:0.74, alpha:1.0)
        , UIColor(red:0.95, green:0.67, blue:0.11, alpha:1.0)
        , UIColor(red:0.42, green:0.95, blue:0.68, alpha:1.0)]
    
    public override init() {
        self.labels = MoodStruct.getAllStringValues()
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return "     " + labels[Int(value - 1)]
    }
    
    public func getStrip(for value: Double)-> UIColor{
        let index: Int = Int((value - 1)/18)
        return color[index]
    }
}
