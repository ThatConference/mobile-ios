import UIKit

class CircleLabel: UIView {
    var label: UILabel!
    var timeSlot: Date!
    
    fileprivate var showCircle: Bool = false
    fileprivate var circleLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: frame)
        label.textAlignment = NSTextAlignment.center
        circleLayer = CAShapeLayer()
            
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func toggleCircle() {
        showCircle = !showCircle
        displayCircle()
    }
    
    func setCircle(_ display: Bool) {
        showCircle = display
        displayCircle()
    }
    
    fileprivate func displayCircle() {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        circleLayer.fillColor = UIColor.init(red: 217/255, green: 213/255, blue: 202/255, alpha: 1.0).cgColor
        
        circleLayer.path = path.cgPath
        
        if showCircle {
            self.layer.insertSublayer(circleLayer, at: 0)
        } else {
            self.layer.sublayers?.remove(at: (self.layer.sublayers?.index(of: circleLayer))!)
        }
    }
    
    func circleVisible() -> Bool {
        return showCircle
    }
}
