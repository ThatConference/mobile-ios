import UIKit

class CircleView: UIView {

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.init(red: 26/255, green: 71/255, blue: 108/255, alpha: 1.0).setFill()
        path.fill()
        
        let label = UILabel()
        label.text = "Family!"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Neutraface Text", size: 12.0)
        label.sizeToFit()
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
        
        self.addConstraint(xConstraint)
        self.addConstraint(yConstraint)
    }
    
}
