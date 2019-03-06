//
//  WWMBackgroundVedioView.swift
//  Meditation
//
//  Created by Roshan Kumawat on 05/03/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVFoundation

class WWMBackgroundVedioView: UIView {

    var player: AVPlayer?
    
    func createBackground(name: String, type: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else { return }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.insertSublayer(playerLayer, at: 0)
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
