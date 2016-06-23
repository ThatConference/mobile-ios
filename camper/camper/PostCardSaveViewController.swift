import ImageScrollView
import UIKit

class PostCardSaveViewController : UIViewController {
    @IBOutlet var pictureImage: ImageScrollView!
    @IBOutlet var frameImage: UIImageView!
    @IBOutlet var frameImageHeight: NSLayoutConstraint!
    
    var pictureImageFile: UIImage?
    var frameImageFile: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        pictureImage.displayImage(pictureImageFile!)
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
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.mainScreen().scale)
        window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: true)
        let windowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Now position the image x/y away from the top-left corner to get the portion we want
        UIGraphicsBeginImageContext(frameImage.frame.size)
        let globalPoint = frameImage.superview?.convertPoint(frameImage.frame.origin, toView: nil)
        windowImage.drawAtPoint(CGPoint(x: -globalPoint!.x, y: -globalPoint!.y))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        //Save Image
        let imageData = UIImagePNGRepresentation(image)
        let compressedPNGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedPNGImage!, nil, nil, nil)
        
        frameImage.layer.borderColor = UIColor.redColor().CGColor
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
}