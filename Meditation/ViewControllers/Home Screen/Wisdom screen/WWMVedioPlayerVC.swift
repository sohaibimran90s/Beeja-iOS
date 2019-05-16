//
//  WWMVedioPlayerVC.swift
//  Meditation
//
//  Created by Roshan Kumawat on 14/05/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit
import AVKit

class WWMVedioPlayerVC: AVPlayerViewController {

    var btnFavourite = UIButton()
    var rating = -1
    var isFavourite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnFavourite = UIButton.init(frame: CGRect.init(x: (self.view.frame.size.width/2)-50, y: 24, width: 48, height: 44))
        btnFavourite.layer.cornerRadius = 10
        btnFavourite.clipsToBounds = true
        btnFavourite.backgroundColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 0.25)
        btnFavourite.contentMode = .scaleAspectFit
        btnFavourite.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
        
        btnFavourite.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        let controller = AVPlayerViewController()
        controller.player = self.player
        let yourView = controller.view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCustomTap(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.delegate = self
        yourView?.addGestureRecognizer(tapGestureRecognizer)
        
        controller.view.addSubview(btnFavourite)
        parent?.modalPresentationStyle = .fullScreen
        self.parent?.present(controller, animated: false, completion: nil)
       // parentViewController.presentViewController(controller, animated: false, completion: nil)
    }
    @objc func buttonTapped() {
        if !isFavourite {
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconON"), for: .normal)
            self.isFavourite = true
            self.rating = 1
        }else {
            isFavourite = false
            self.btnFavourite.setImage(UIImage.init(named: "favouriteIconOFF"), for: .normal)
            self.rating = 0
        }
    }
    @objc func onCustomTap(sender: UITapGestureRecognizer) {
        
        if btnFavourite.alpha > 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.btnFavourite.alpha = 0;
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.btnFavourite.alpha = 1;
            })
        }
    }
}

extension WWMVedioPlayerVC: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let _touchView = touch.view {
            
            let screenRect:CGRect = UIScreen.main.bounds
            let screenWidth :CGFloat = screenRect.size.width;
            let screenHeight:CGFloat  = screenRect.size.height;
            
            if _touchView.bounds.height == screenHeight && _touchView.bounds.width == screenWidth{
                return true
            }
            
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
