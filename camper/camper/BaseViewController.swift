import UIKit

class BaseViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRectMake(0, 0, 80, 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        self.view.addSubview(self.activityIndicator)
        
        // That Post Card
        let cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        cameraBtn.setImage(UIImage(named: "camera"), forState: UIControlState.Normal)
        cameraBtn.addTarget(self, action: #selector(self.moveToCamera), forControlEvents:  UIControlEvents.TouchUpInside)
        let item = UIBarButtonItem(customView: cameraBtn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func moveToCamera() {
        self.moveToPostCard()
    }
    
    private func moveToPostCard() {
        let postCardVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardChooseFrameViewController") as! PostCardChooseFrameViewController
        self.navigationController!.pushViewController(postCardVC, animated: true)
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
}