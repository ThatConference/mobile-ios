import UIKit

class BaseViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView(frame: self.view.bounds)
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityIndicator.center =  self.view.center
        self.activityIndicator.backgroundColor = UIColor(white: 1, alpha: 0.8)
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        //That Post Card
//        let cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        cameraBtn.setImage(UIImage(named: "camera"), forState: UIControlState.Normal)
//        cameraBtn.addTarget(self, action: #selector(self.moveToCamera), forControlEvents:  UIControlEvents.TouchUpInside)
//        let item = UIBarButtonItem(customView: cameraBtn)
//        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func moveToCamera() {
        self.moveToPostCard()
    }
    
    private func moveToPostCard() {
        let postCardVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardChooseFrameViewController") as! PostCardChooseFrameViewController
        self.navigationController!.pushViewController(postCardVC, animated: true)
    }
}