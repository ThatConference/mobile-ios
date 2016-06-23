import UIKit

class PostCardChooseFrameViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var frameCollectionView: UICollectionView!
    
    var frames:[PostCardFrame] = []
    
    let identifier = "FrameCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        populateData()
        
        frameCollectionView.dataSource = self
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier,forIndexPath:indexPath) as! FrameCell
        
        let frame = frames[indexPath.row]
        
        let title = frame.Title!
        let filename = frame.Filename!
        
        cell.imageView.image = UIImage(named: filename.lowercaseString)
        cell.caption.text = title.capitalizedString
        cell.backgroundColor = UIColor.lightGrayColor()
        
        return cell
    }
    
    func collectionView(collection: UICollectionView, selectedItemIndex: NSIndexPath)
    {
        self.performSegueWithIdentifier("selectFrame", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // retrieve selected cell &amp; fruit
        if let indexPath = getIndexPathForSelectedCell() {
            
            let frame = self.frames[indexPath.row]
            
            let postCardChoosePhotoViewController = segue.destinationViewController as! PostCardChoosePhotoViewController
            postCardChoosePhotoViewController.frame = frame
        }
    }
    
    func getIndexPathForSelectedCell() -> NSIndexPath? {
        var indexPath:NSIndexPath?
        
        if frameCollectionView.indexPathsForSelectedItems()!.count > 0 {
            indexPath = frameCollectionView.indexPathsForSelectedItems()![0]
        }
        return indexPath
    }

    func populateData() {
        let frame1 = PostCardFrame(title: "Test Frame", filename: "test-frame")
        frames.append(frame1)
    }
}