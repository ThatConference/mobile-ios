import UIKit
import Fabric
import Crashlytics

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SponsorsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var SponsorLevel: UILabel!
    @IBOutlet var CurrentLevel: UIPageControl!
    @IBOutlet var SponsorTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var loadedSponsors: Dictionary<String, [Sponsor]>?
    var sponsorLevels: [String]?
    var itemIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        SponsorLevel.text = ""
        
        self.activityIndicator.startAnimating()
        self.loadSponsors()
        
        SponsorTable.dataSource = self
        SponsorTable.delegate = self
        self.revealViewControllerFunc(barButton: menuButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Answers.logContentView(withName: "Sponsors",
                                       contentType: "Page",
                                       contentId: "",
                                       customAttributes: [:])
    }
    
    // MARK: Data Source
    @IBAction func pageClick(_ sender: AnyObject) {
        if itemIndex < loadedSponsors?.count && sender.currentPage > itemIndex {
            itemIndex += 1
        } else if itemIndex > 0 {
            itemIndex -= 1
        }
        refreshTable()
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            moveToNext()
        } else if (sender.direction == .right) {
            moveToPrevious()
        }
    }
    
    internal func moveToNext() {
        self.moveToLevel(self.itemIndex + 1)
    }
    
    internal func moveToPrevious() {
        self.moveToLevel(self.itemIndex - 1)
    }
    
    func moveToLevel(_ requestedIndex: Int) {
        if (requestedIndex < 0) {
            return
        }
        
        if (requestedIndex >= self.sponsorLevels?.count) {
            return
        }
        
        itemIndex = requestedIndex
        CurrentLevel.currentPage = itemIndex
        refreshTable()
    }
    
    func loadSponsors() {
        self.fetchSponsors() {
            (sponsorsResult) -> Void in
            
            switch sponsorsResult {
            case .success(let sponsors):
                print("Sponsors Retrieved. \(sponsors.count)")

                self.loadedSponsors = Dictionary<String, [Sponsor]>()
                self.sponsorLevels = [String]()
                
                for sponsor in sponsors {
                    let currentLevel = sponsor.sponsorLevel!
                    if self.loadedSponsors![currentLevel] != nil {
                        self.loadedSponsors![currentLevel]?.append(sponsor)
                    } else {
                        var sponsorLevel = [Sponsor]()
                        sponsorLevel.append(sponsor)
                        self.loadedSponsors![currentLevel] = sponsorLevel
                        self.sponsorLevels!.append(currentLevel)
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.CurrentLevel.numberOfPages = (self.loadedSponsors?.count)!
                    self.activityIndicator.stopAnimating()
                })
                self.refreshTable()
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async(execute: {
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    func fetchSponsors(completion: @escaping (SponsorsResult) -> Void) {
        let url = ThatConferenceAPI.sponsorsURL()
        let request = URLRequest(url: url as URL)
        let task = ThatConferenceAPI.nsurlSession.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processSponsorsRequest(data: data, error: error as NSError?)
            completion(result)
        }) 
        task.resume()
    }
    
    func processSponsorsRequest(data: Data?, error: NSError?) -> SponsorsResult {
        guard let jsonData = data
            else {
                return .failure(error!)
        }
        
        return ThatConferenceAPI.sponsorsFromJSONData(jsonData)
    }
    
    // MARK : Table Methods
    func refreshTable() {
        DispatchQueue.main.async(execute: {
            if ((self.sponsorLevels != nil) && ((self.sponsorLevels?.count)! > 0)) {
                self.SponsorLevel.text = self.sponsorLevels![self.itemIndex]
                self.SponsorTable.reloadData()
            } else {
                self.simpleAlert(title: "No Sponsors", body: "Sponsors Will Be Announced Soon.")
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (loadedSponsors == nil) {
            return 0
        }
        
        let key = self.sponsorLevels![itemIndex]
        return loadedSponsors![key]!.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SponsorTableViewCell = self.SponsorTable.dequeueReusableCell(withIdentifier: "SponsorCell") as! SponsorTableViewCell
        let key = self.sponsorLevels![itemIndex]
        cell.loadItem(loadedSponsors![key]![(indexPath as NSIndexPath).row])
        return cell
    }
}
