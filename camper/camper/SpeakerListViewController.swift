//
//  SpeakerListViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/14/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class SpeakerListViewController: BaseViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var speakerArray: [Speaker] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(SpeakerListViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        self.tableView.addSubview(self.refreshControl)
        
        loadData()
        
        self.revealViewControllerFunc(barButton: menuButton)
    }
    
    // MARK: Functions
    
    func refresh(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadData() {
        let speakerAPI = SpeakerAPI()
        
        self.activityIndicator.startAnimating()
        
        if (self.refreshControl != nil) {
            self.refreshControl.endRefreshing()
        }
        
        if let speakers = PersistenceManager.loadSpeakers(Path.Speakers) {
            self.speakerArray = speakers
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        } else {
            speakerAPI.getSpeakers { (result) in
                switch (result) {
                case .success(let result):
                    self.speakerArray = result
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                    break
                case .failure(let error):
                    print(error)
                    self.speakerArray = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                    break
                }
            }
        }
    }
}


extension SpeakerListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as? SpeakerTableViewCell {
            
            let speaker = speakerArray[indexPath.row]
            cell.setUpCell(speaker: speaker)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! SpeakerTableViewCell
        let speaker =  cell.speaker
        let speakerDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerProfileViewController") as! SpeakerProfileViewController
        speakerDetailVC.speaker = speaker
        self.navigationController!.pushViewController(speakerDetailVC, animated: true)
    }
}
