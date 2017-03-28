import UIKit

class BaseViewController: UIViewController, AuthorizationFormDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        self.view.addSubview(self.activityIndicator)
        
        // That Post Card
        let cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cameraBtn.setImage(UIImage(named: "camera"), for: UIControlState())
        cameraBtn.addTarget(self, action: #selector(self.moveToCamera), for:  UIControlEvents.touchUpInside)
        let item = UIBarButtonItem(customView: cameraBtn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? AuthorizationViewController {
            newVC.delegate = self
        }
    }
    
    func dismissViewController(_ controller: UIViewController) {
        controller.dismiss(animated: true) { () -> Void in
            self.navigateToSchedule()
        }
    }
    
    internal func navigateToSchedule() {
        setData(true)
        self.tabBarController?.selectedIndex = 1
    }
    
    internal func setData(_ isDirty: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dirtyDataFavorites = isDirty;
    }
    
    @objc fileprivate func moveToCamera() {
        self.moveToPostCard()
    }
    
    fileprivate func moveToPostCard() {
        let postCardVC = self.storyboard?.instantiateViewController(withIdentifier: "PostCardChoosePhotoViewController") as! PostCardChoosePhotoViewController
        self.present(postCardVC, animated: true, completion: nil)
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
    
    func simpleAlert(title: String, body: String) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }
}
