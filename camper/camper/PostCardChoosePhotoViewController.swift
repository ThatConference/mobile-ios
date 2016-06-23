import UIKit

class PostCardChoosePhotoViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var nextStepButton: UIButton!
    
    var frame: PostCardFrame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        imagePreview.image = UIImage(named: (frame?.Filename!.lowercaseString)!)
    }
    
    @IBAction func openCamera(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibrary(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {        self.dismissViewControllerAnimated(true, completion: nil);
        let savePhotoVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardSaveViewController") as! PostCardSaveViewController
        savePhotoVC.frameImageFile = imagePreview.image
        savePhotoVC.pictureImageFile = image
        self.navigationController!.pushViewController(savePhotoVC, animated: true)
    }
}