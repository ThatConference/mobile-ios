import ImageScrollView
import Photos
import UIKit
import Fabric
import Crashlytics

class PostCardSaveViewController : UIViewController {
    @IBOutlet var ImagePreview: UIImageView!
    @IBOutlet var savePostCardButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!
    var createdImage: UIImage?
    var photoAlbum: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    let ALBUM_NAME: String = "That Conference"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRectMake(0, 0, 80, 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        self.view.addSubview(self.activityIndicator)
        
        ImagePreview.image = createdImage
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .Authorized:
            break
        case .Denied, .Restricted :
            self.alertToEncouragePhotosAccessInitially()
            break
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                switch status {
                case .Authorized:
                    break
                case .Denied, .Restricted:
                    self.alertToEncouragePhotosAccessInitially()
                    break
                case .NotDetermined:
                    self.savePostCardButton.enabled = false
                    break
                }
            }
        }
    }
    
    func alertToEncouragePhotosAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Photo Album access required to save Post Card",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alert) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Allow Photos", style: .Cancel, handler: { (alert) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func sharePostCardPressed(sender: AnyObject) {
        startIndicator()
        shareImage(createdImage!)
        Answers.logCustomEventWithName("Photo Shared", customAttributes: [:])
    }
    
    @IBAction func savePostCardPressed(sender: AnyObject) {
        startIndicator()
        setAlbum()
        saveImage(createdImage!)
        Answers.logCustomEventWithName("Photo Saved", customAttributes: [:])
    }
    
    func getActualImageSize(image: UIImage, ImageView: UIImageView) -> CGSize {
        let tempWidth = image.size.width / ImageView.frame.size.width
        let tempHeight = image.size.height / ImageView.frame.size.height
        
        var toReturn = CGSize()
        if (image.size.height < image.size.width) {
            toReturn.width = ImageView.frame.size.width
            toReturn.height = image.size.height * tempHeight
        } else {
            toReturn.width = image.size.width * tempWidth
            toReturn.height = ImageView.frame.size.height
        }
        return toReturn
    }
    
    func padImage(originalImage: UIImage) -> UIImage {
        let width:CGFloat = originalImage.size.width * 1.5
        let height:CGFloat = originalImage.size.height * 1.5
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        // Now we can draw anything we want into this new context.
        let origin:CGPoint = CGPointMake((width - originalImage.size.width) / 2.0, (height - originalImage.size.height) / 2.0)
        originalImage.drawAtPoint(origin);

        // Clean up and get the new image.
        UIGraphicsPopContext();
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        return newImage
    }
    
    func setAlbum() {
        // Find Album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", ALBUM_NAME)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            photoAlbum = collection.firstObject as! PHAssetCollection
        } else {
            // Album Not Found - Create
            PHPhotoLibrary.sharedPhotoLibrary().performChanges(
                {
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.ALBUM_NAME)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: {
                    success, error in
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.photoAlbum = collectionFetchResult.firstObject as! PHAssetCollection
                    } else {
                        let ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                        self.stopIndicator()
                    }
            })
        }
    }
    
    func saveImage(image: UIImage){
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.photoAlbum)
            albumChangeRequest!.addAssets([assetPlaceholder!])
            }, completionHandler: { success, error in
                if error == nil {
                    let ac = UIAlertController(title: "Created", message: "Your new That Postcard has been created.", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                } else {
                    let ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
                self.stopIndicator()
        })
    }
    
    func shareImage(image: UIImage) {
        let messageStr:String  = "#ThatPostcard"
        let shareItems:Array = [image, messageStr]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePrint,UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
        self.stopIndicator()
    }
    
    func startIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
        })
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}