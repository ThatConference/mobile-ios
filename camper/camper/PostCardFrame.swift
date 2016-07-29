import AVFoundation
import Foundation

class PostCardFrame {
    var Title:String?
    var FilenameLandscape:String?
    var FilenamePortrait:String?
    
    init(title:String, filenameLandscape:String, filenamePortrait:String) {
        self.Title = title
        self.FilenameLandscape = filenameLandscape
        self.FilenamePortrait = filenamePortrait
    }
}