import UIKit

class CircleView: UIView {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        UIColor.init(red: 26/255, green: 71/255, blue: 108/255, alpha: 1.0).setFill()
        path.fill()
        
        let label = UILabel()
        label.text = "Family!"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Neutraface Text", size: 12.0)
        label.sizeToFit()
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        self.addConstraint(xConstraint)
        self.addConstraint(yConstraint)
    }
    
}
