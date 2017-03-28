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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        self.view.addSubview(self.activityIndicator)
        
        ImagePreview.image = createdImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            break
        case .denied, .restricted :
            self.alertToEncouragePhotosAccessInitially()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                switch status {
                case .authorized:
                    break
                case .denied, .restricted:
                    self.alertToEncouragePhotosAccessInitially()
                    break
                case .notDetermined:
                    self.savePostCardButton.isEnabled = false
                    break
                }
            }
        }
    }
    
    func alertToEncouragePhotosAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Photo Album access required to save Postcard",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Allow Photos", style: .cancel, handler: { (alert) -> Void in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sharePostCardPressed(_ sender: AnyObject) {
        startIndicator()
        shareImage(createdImage!)
        Answers.logCustomEvent(withName: "Photo Shared", customAttributes: [:])
    }
    
    @IBAction func savePostCardPressed(_ sender: AnyObject) {
        startIndicator()
        setAlbum()
        saveImage(createdImage!)
        Answers.logCustomEvent(withName: "Photo Saved", customAttributes: [:])
    }
    
    func getActualImageSize(_ image: UIImage, ImageView: UIImageView) -> CGSize {
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
    
    func padImage(_ originalImage: UIImage) -> UIImage {
        let width:CGFloat = originalImage.size.width * 1.5
        let height:CGFloat = originalImage.size.height * 1.5
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        // Now we can draw anything we want into this new context.
        let origin:CGPoint = CGPoint(x: (width - originalImage.size.width) / 2.0, y: (height - originalImage.size.height) / 2.0)
        originalImage.draw(at: origin);

        // Clean up and get the new image.
        UIGraphicsPopContext();
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
    
        return newImage
    }
    
    func setAlbum() {
        // Find Album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", ALBUM_NAME)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            photoAlbum = collection.firstObject
        } else {
            // Album Not Found - Create
            PHPhotoLibrary.shared().performChanges(
                {
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.ALBUM_NAME)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: {
                    success, error in
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.photoAlbum = collectionFetchResult.firstObject
                    } else {
                        let ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                        self.stopIndicator()
                    }
            })
        }
    }
    
    func saveImage(_ image: UIImage){
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let assetPlaceholder = assetRequest.placeholderForCreatedAsset {
                if self.photoAlbum != nil {
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.photoAlbum) {
                        albumChangeRequest.addAssets([assetPlaceholder] as NSArray)
                    }
                } else {
                    let ac = UIAlertController(title: "Save Error", message: "Could not save to your device. Please check your permissions.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }, completionHandler: { success, error in
            if error == nil {
                let ac = UIAlertController(title: "Got it!", message: "Your new That Postcard has been created.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
            self.stopIndicator()
        })
    }
    
    func shareImage(_ image: UIImage) {
        let messageStr:String  = " #ThatPostcard "
        let shareItems:Array = [image, messageStr] as [Any]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.message, UIActivityType.mail, UIActivityType.print,UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList]
        
        self.present(activityViewController, animated: true, completion: nil)
        self.stopIndicator()
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
}
