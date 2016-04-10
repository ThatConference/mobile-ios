import UIKit

class CircleLabel: UIView {
    var label: UILabel!
    
    private var showCircle: Bool = false
    private var circleLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: frame)
        label.textAlignment = NSTextAlignment.Center
        circleLayer = CAShapeLayer()
            
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func toggleCircle() {
        showCircle = !showCircle
        
        let path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        circleLayer.fillColor = UIColor.init(red: 217/255, green: 213/255, blue: 202/255, alpha: 1.0).CGColor
        
        circleLayer.path = path.CGPath
        
        if showCircle {
            self.layer.insertSublayer(circleLayer, atIndex: 0)
        } else {
            self.layer.sublayers?.removeAtIndex((self.layer.sublayers?.indexOf(circleLayer))!)
        }      
        
    }
}
