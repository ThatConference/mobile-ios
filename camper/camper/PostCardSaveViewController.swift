import ImageScrollView
import Photos
import UIKit

class PostCardSaveViewController : UIViewController {
    @IBOutlet var pictureImage: ImageScrollView!
    @IBOutlet var frameImage: UIImageView!
    @IBOutlet var frameImageHeight: NSLayoutConstraint!
    
    var pictureImageFile: UIImage?
    var frameImageFile: UIImage?
    var photoAlbum: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    let ALBUM_NAME: String = "That Conference"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        pictureImage.displayImage(padImage(pictureImageFile!))
        frameImage.image = frameImageFile
        frameImage.layer.borderColor = UIColor.redColor().CGColor
        frameImage.layer.borderWidth = 1
        frameImageHeight.constant = getActualImageSize(frameImageFile!, ImageView: frameImage).height
    }
    
    @IBAction func savePostCardPressed(sender: AnyObject) {
        frameImage.layer.borderColor = UIColor.clearColor().CGColor
        
        //Create Snapshot
        let window = UIApplication.sharedApplication().delegate!.window!!
        
        //Capture the Entire Window
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, view.opaque, 0.0)
        window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: true)
        let windowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Now position the image x/y away from the top-left corner to get the portion we want
        UIGraphicsBeginImageContext(frameImage.frame.size)
        let globalPoint = frameImage.superview?.convertPoint(frameImage.frame.origin, toView: nil)
        windowImage.drawAtPoint(CGPoint(x: -globalPoint!.x, y: -globalPoint!.y))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        //Save
        frameImage.layer.borderColor = UIColor.redColor().CGColor
        setAlbum()
        saveImage(image)
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
        let width:CGFloat = originalImage.size.width * 3.0
        let height:CGFloat = originalImage.size.height * 3.0
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
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action:UIAlertAction) in
                        self.shareImage(image)
                    }))
                    self.presentViewController(ac, animated: true, completion: nil)
                } else {
                    let ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
        })
    }
    
    func shareImage(image: UIImage) {
        let messageStr:String  = "#ThatPostcard"
        let shareItems:Array = [image, messageStr]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}