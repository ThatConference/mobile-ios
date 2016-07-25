import AVFoundation
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
        let frame1 = PostCardFrame(title: "Camper", filename: "camperland", orientation: AVCaptureVideoOrientation.LandscapeRight)
        frames.append(frame1)
        
        let frame2 = PostCardFrame(title: "Kids", filename: "kidsland", orientation: AVCaptureVideoOrientation.LandscapeRight)
        frames.append(frame2)
        
        let frame3 = PostCardFrame(title: "Magic", filename: "magicland", orientation: AVCaptureVideoOrientation.LandscapeRight)
        frames.append(frame3)
        
        let frame4 = PostCardFrame(title: "Vintage", filename: "vintageland", orientation: AVCaptureVideoOrientation.LandscapeRight)
        frames.append(frame4)
        
        let frame5 = PostCardFrame(title: "Camper (Portrait)", filename: "camperland-portrait", orientation: AVCaptureVideoOrientation.Portrait)
        frames.append(frame5)
        
        let frame6 = PostCardFrame(title: "Magic (Portrait)", filename: "magicland-portrait", orientation: AVCaptureVideoOrientation.Portrait)
        frames.append(frame6)
        
        let frame7 = PostCardFrame(title: "Vintage (Portrait)", filename: "vintageland-portrait", orientation: AVCaptureVideoOrientation.Portrait)
        frames.append(frame7)
    }
}