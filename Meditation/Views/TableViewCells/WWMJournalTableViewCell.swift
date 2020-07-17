//
//  WWMJournalTableViewswift
//  Meditation
//
//  Created by Roshan Kumawat on 09/01/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMJournalTableViewCell: UITableViewCell {

    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UILabel!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


//Prashant
//Image
class WWMJournalImageTableViewCell: UITableViewCell {
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UILabel!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgJournal: UIImageView!
    @IBOutlet weak var imgMultiple: UIImageView!
    
    
    func assignValues(data: WWMJournalProgressData) {
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 0.3
        viewShadow.layer.shadowRadius = 5.0
        viewShadow.layer.cornerRadius = 5.0
        viewShadow.layer.masksToBounds = false
        
        lblJournalDesc.adjustsFontSizeToFitWidth = false
        lblJournalDesc.lineBreakMode = .byTruncatingTail
        
        lblJournalDesc.text = data.text
        
        if data.mood_status.lowercased() == "post" {
            lblMeditationType.text = KPOSTMEDITATION
        }else if data.mood_status.lowercased() == "pre" {
            lblMeditationType.text = KPREMEDITATION
        }else if lblJournalDesc.text?.contains("Journaling works best when we simply pour out a stream of consciousness into our") ?? false{
            lblMeditationType.text = "How to journal"
        }else if lblJournalDesc.text?.contains("Keeping a journal is an amazing way to start and end your day") ?? false{
            lblMeditationType.text = "Why Journal"
        }else{
            lblMeditationType.text = "Journal Entry"
        }
        
        let date = Date(timeIntervalSince1970: Double(data.date_time)!/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
        dateFormatter.dateFormat = "EEEE, hh:mm a" //Spegicify your format that you want
        let strWeekDayAndtime = dateFormatter.string(from: date)
        lblWeekDayAndTime.text = strWeekDayAndtime
        
        dateFormatter.dateFormat = "dd"
        
        lblDateDay.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMM"
        lblDateMonth.text = dateFormatter.string(from: date)
        
        
        //handling image
        imgJournal.sd_setImage(with: URL(string: data.assets_images[0].name), placeholderImage: UIImage(named: "onboardingImg1"))
        imgMultiple.isHidden = data.assets_images.count == 1 ? true : false
    }
}

//Audio
class WWMJournalAudioTableViewCell: UITableViewCell {
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblWeekDayAndTime: UILabel!
    @IBOutlet weak var lblJournalDesc: UILabel!
    @IBOutlet weak var lblDateMonth: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblMeditationType: UILabel!
    
    @IBOutlet weak var viewAudio: UIView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var beginTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    
    var player: AVPlayer?
    var isPlayComplete: Bool = false
    var isPlay: Bool = false
    var timer = Timer()
    
    func assignValues(data: WWMJournalProgressData) {
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 0.3
        viewShadow.layer.shadowRadius = 5.0
        viewShadow.layer.cornerRadius = 5.0
        viewShadow.layer.masksToBounds = false
        
        lblJournalDesc.adjustsFontSizeToFitWidth = false
        lblJournalDesc.lineBreakMode = .byTruncatingTail
        
        lblJournalDesc.text = data.text
        
        if data.mood_status.lowercased() == "post" {
            lblMeditationType.text = KPOSTMEDITATION
        }else if data.mood_status.lowercased() == "pre" {
            lblMeditationType.text = KPREMEDITATION
        }else if lblJournalDesc.text?.contains("Journaling works best when we simply pour out a stream of consciousness into our") ?? false{
            lblMeditationType.text = "How to journal"
        }else if lblJournalDesc.text?.contains("Keeping a journal is an amazing way to start and end your day") ?? false{
            lblMeditationType.text = "Why Journal"
        }else{
            lblMeditationType.text = "Journal Entry"
        }
        
        let date = Date(timeIntervalSince1970: Double(data.date_time)!/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: dateFormatter.locale.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: dateFormatter.timeZone.abbreviation() ?? "GMT")
        
        dateFormatter.dateFormat = "EEEE, hh:mm a" //Spegicify your format that you want
        let strWeekDayAndtime = dateFormatter.string(from: date)
        lblWeekDayAndTime.text = strWeekDayAndtime
        
        dateFormatter.dateFormat = "dd"
        
        lblDateDay.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMM"
        lblDateMonth.text = dateFormatter.string(from: date)
        
        
        //audio setup
        let playerItem = AVPlayerItem.init(url:URL.init(string: data.assets_audios[0].name)!)
        self.player = AVPlayer(playerItem: playerItem)
        
        let duration = CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!)
        let duration1 = Int(round(duration))
        let totalAudioLength = self.secondToMinuteSecond(second : duration1)
        
        self.endTimeLbl.text = "\(totalAudioLength)"
    }
    
    func secondToMinuteSecond(second : Int) -> String {
        return String.init(format: "%02d:%02d", second/60,second%60)
    }
    
    @IBAction func clickPlayButton() {
        
    }
    
    
}


//----------------------
