import AVFoundation
import Foundation

class PostCardFrame {
    var Title:String?
    var Filename:String?
    var Orientation:AVCaptureVideoOrientation?
    
    init(title:String, filename:String, orientation:AVCaptureVideoOrientation) {
        self.Title = title
        self.Filename = filename
        self.Orientation = orientation
    }
}