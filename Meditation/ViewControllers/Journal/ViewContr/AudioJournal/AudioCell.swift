//
//  AudioCell.swift
//  MeditationDemo
//
//  Created by Ehsan on 9/7/20.
//  Copyright © 2020 Ehsan. All rights reserved.
//

import UIKit

protocol AudioContainerDelegate {
    func deleteAudio(index: Int)
}


class AudioCell: UITableViewCell {

    @IBOutlet weak var playPauseIcon: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var isSelectedCell = false
    
    var delegate: AudioContainerDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setAudioCell(audioObj: AudioJournal, index: Int) {
        
        self.deleteBtn.tag = index
        self.captionLbl.text = audioObj.caption
        self.durationLbl.text = audioObj.duration
        
        guard let hrMinSec = audioObj.duration?.components(separatedBy: ":") else {return}
        let hr = (hrMinSec.count > 0) ? 00 : 00
        let min = (hrMinSec.count > 1) ? 04 - Int(hrMinSec[1])! : 00
        let sec = (hrMinSec.count > 2) ? 60 - Int(hrMinSec[2])! : 00
        
        let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
        self.durationLbl.text = totalTimeString
    }
    
    func didSelect() {
        //self.playPauseIcon.image = UIImage(named: "pauseIcon.png")
    }
    
    func didDeselect() {
        //self.playPauseIcon.image = UIImage(named: "play.png")
    }
    
    @IBAction func deleteAction(sender: UIButton) {
        
        self.delegate.deleteAudio(index: sender.tag)
    }
}
