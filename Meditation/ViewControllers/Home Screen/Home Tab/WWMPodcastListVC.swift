//
//  WWMPodcastListVC.swift
//  Meditation
//
//  Created by Prema Negi on 15/07/19.
//  Copyright © 2019 Cedita. All rights reserved.
//

import UIKit

class WWMPodcastListVC: WWMBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        self.setUpNavigationBarForDashboard(title: "Podcast")
    }
}

extension WWMPodcastListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "WWMHomePodcastTVC") as! WWMHomePodcastTVC
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLearnFlightModeVC") as! WWMLearnFlightModeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

