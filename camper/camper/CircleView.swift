import UIKit

class CircleView: UIView {

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.init(red: 131/255, green: 109/255, blue: 40/255, alpha: 1.0).setFill()
        path.fill()
    }
}
