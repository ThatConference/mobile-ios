import UIKit

class SponsorsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var SponsorLevel: UILabel!
    @IBOutlet var CurrentLevel: UIPageControl!
    @IBOutlet var SponsorTable: UITableView!
    
    var loadedSponsors: Dictionary<String, [Sponsor]>?
    var sponsorLevels: [String]?
    var itemIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        SponsorLevel.text = ""
        
        self.activityIndicator.startAnimating()
        self.loadSponsors()
        
        SponsorTable.dataSource = self
        SponsorTable.delegate = self
    }
    
    // MARK: Data Source
    @IBAction func pageClick(sender: AnyObject) {
        if itemIndex < loadedSponsors?.count && sender.currentPage > itemIndex {
            itemIndex += 1
        } else if itemIndex > 0 {
            itemIndex -= 1
        }
        refreshTable()
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            moveToNext()
        } else if (sender.direction == .Right) {
            moveToPrevious()
        }
    }
    
    internal func moveToNext() {
        self.moveToLevel(self.itemIndex + 1)
    }
    
    internal func moveToPrevious() {
        self.moveToLevel(self.itemIndex - 1)
    }
    
    func moveToLevel(requestedIndex: Int) {
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
            case .Success(let sponsors):
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                })
                self.refreshTable()
            case .Failure(let error):
                print("Error: \(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    func fetchSponsors(completion completion: (SponsorsResult) -> Void) {
        let url = ThatConferenceAPI.sponsorsURL()
        let request = NSURLRequest(URL: url)
        let task = ThatConferenceAPI.nsurlSession.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processSponsorsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processSponsorsRequest(data data: NSData?, error: NSError?) -> SponsorsResult {
        guard let jsonData = data
            else {
                return .Failure(error!)
        }
        
        return ThatConferenceAPI.sponsorsFromJSONData(jsonData)
    }
    
    // MARK : Table Methods
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.SponsorLevel.text = self.sponsorLevels![self.itemIndex]
            self.SponsorTable.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (loadedSponsors == nil) {
            return 0
        }
        
        let key = self.sponsorLevels![itemIndex]
        return loadedSponsors![key]!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SponsorTableViewCell = self.SponsorTable.dequeueReusableCellWithIdentifier("SponsorCell") as! SponsorTableViewCell
        let key = self.sponsorLevels![itemIndex]
        cell.loadItem(loadedSponsors![key]![indexPath.row])
        return cell
    }
}