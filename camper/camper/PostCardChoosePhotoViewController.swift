import AVFoundation
import Photos
import UIKit
import Fabric
import Crashlytics

class PostCardChoosePhotoViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var frameView: UIImageView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var controlView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var changeCameraButton: UIButton!
    @IBOutlet var takePictureButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var cameraView: UIView!
    
    var frame: PostCardFrame?
    var frames:[PostCardFrame] = []
    var frameIndex: Int = 0
    var frameImage: UIImage?
    var currentOrientation: AVCaptureVideoOrientation?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoAlbum: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var useRearCamera = true
    var videoDeviceInput: AVCaptureDeviceInput?
    var filterIsOn = false
    var selfieModeIsOn = false
    
    let ALBUM_NAME: String = "That Conference"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentOrientation = AVCaptureVideoOrientation.Portrait
        
        updateFrameInfo()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        self.imageView.hidden = true
        //setCameraWitHFilter()
        setCamera()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostCardChoosePhotoViewController.DidRotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.captureSession?.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCamera()
    }
    
    func finalSetUp() {
        //Set Camera Preview Bounds
        let rect = AVMakeRectWithAspectRatioInsideRect(frameImage!.size, frameView.bounds)
        cameraView.bounds = frameView.bounds
        previewLayer!.frame = rect
        //imageView.frame = rect
        
        //Frame Message
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey("tutorialWasShown") {
            let alertController = UIAlertController(title: nil, message: "Swipe To Change Frame Style", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            let delay = 4.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                alertController.dismissViewControllerAnimated(true, completion: nil);
            })
            
            // Update defaults
            defaults.setBool(true, forKey: "tutorialWasShown")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
        case .Authorized:
            finalSetUp()
            break
        case .Denied: alertToEncourageCameraAccessInitially()
        case .NotDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for Photo Taking",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alert) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .Cancel, handler: { (alert) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Please allow camera access for Photo Taking",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel) { alert in
            if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCamera() } }
            }
        })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            moveToNext()
        }
        
        if (sender.direction == .Right) {
            moveToPrevious()
        }
        
        if (sender.direction == .Up) {
            moveToNext()
        }
        
        if (sender.direction == .Down) {
            moveToPrevious()
        }
    }
    
    private func moveToNext() {
        frameIndex += 1
        
        if (frameIndex >= frames.count) {
            frameIndex = 0
        }
        
        updateFrameInfo()
    }
    
    private func moveToPrevious() {
        frameIndex -= 1
        
        if (frameIndex < 0) {
            frameIndex = frames.count - 1
        }
        
        updateFrameInfo()
    }
    
    func DidRotate() {
        switch UIDevice.currentDevice().orientation {
        case UIDeviceOrientation.LandscapeLeft:
            currentOrientation = AVCaptureVideoOrientation.LandscapeLeft
            break;
        case UIDeviceOrientation.LandscapeRight:
            currentOrientation = AVCaptureVideoOrientation.LandscapeRight
            break;
        default:
            currentOrientation = AVCaptureVideoOrientation.Portrait
            break;
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.updateFrameInfo()
            self.setScreenRotation()
        })
    }
    
    func updateFrameInfo() {
        populateFrames()
        frame = frames[frameIndex]
        
        if ((currentOrientation == AVCaptureVideoOrientation.LandscapeLeft)
            || (currentOrientation == AVCaptureVideoOrientation.LandscapeRight) ) {
            frameImage = UIImage(named: (frame!.FilenameLandscape!.lowercaseString))!
        } else {
            frameImage = UIImage(named: (frame!.FilenamePortrait!.lowercaseString))!
        }
        
        frameView.image = frameImage
    }
    
    func populateFrames() {
        let frame1 = PostCardFrame(title: "Camper",
                                   filenameLandscape: "camperland",
                                   filenamePortrait: "camperland-portrait")
        frames.append(frame1)
        
        let frame2 = PostCardFrame(title: "Kids",
                                   filenameLandscape: "kidsland",
                                   filenamePortrait: "kidsland-portrait")
        frames.append(frame2)
        
        let frame3 = PostCardFrame(title: "Vintage",
                                   filenameLandscape: "vintageland",
                                   filenamePortrait: "vintageland-portrait")
        frames.append(frame3)
        
        let frame4 = PostCardFrame(title: "Magic",
                                   filenameLandscape: "magicland",
                                   filenamePortrait: "magicland-portrait")
        frames.append(frame4)
        
        let frame9 = PostCardFrame(title: "Bear with Trees",
                                   filenameLandscape: "bear-with-trees",
                                   filenamePortrait: "bear-with-trees-portrait")
        frames.append(frame9)
        
        let frame10 = PostCardFrame(title: "Bear Friend",
                                   filenameLandscape: "bear",
                                   filenamePortrait: "bear-portrait")
        frames.append(frame10)
        
        let frame5 = PostCardFrame(title: "TC Bottom Dark",
                                   filenameLandscape: "tc-bottom-dark",
                                   filenamePortrait: "tc-bottom-dark-portrait")
        frames.append(frame5)
        
        let frame6 = PostCardFrame(title: "TC Bottom Light",
                                  filenameLandscape: "tc-bottom-light",
                                  filenamePortrait: "tc-bottom-light-portrait")
        frames.append(frame6)
        
        let frame7 = PostCardFrame(title: "TC Top Dark",
                                  filenameLandscape: "tc-top-dark",
                                  filenamePortrait: "tc-top-dark-portrait")
        frames.append(frame7)
        
        let frame8 = PostCardFrame(title: "TC Top Light",
                                  filenameLandscape: "tc-top-light",
                                  filenamePortrait: "tc-top-light-portrait")
        frames.append(frame8)
    }
    
    func setCamera() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var error: NSError?
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            videoDeviceInput = nil
        }
        
        if error == nil && captureSession!.canAddInput(videoDeviceInput) {
            captureSession!.addInput(videoDeviceInput)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
    
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = currentOrientation!
                cameraView.layer.addSublayer(previewLayer!)
            }
        }
    }
    
    func setCameraWitHFilter() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            captureSession!.addInput(videoDeviceInput)
        }
        catch {
            print("Cannot Access Camera")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer!.connection?.videoOrientation = currentOrientation!
        cameraView.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
        
        captureSession!.addOutput(videoOutput)
        captureSession!.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        let videoEffect = CIFilter(name: "CIPhotoEffectInstant")
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(CVPixelBuffer: pixelBuffer!)
        
        videoEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        let filteredImage = UIImage(CIImage: videoEffect!.valueForKey(kCIOutputImageKey) as! CIImage!)
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.imageView.image = filteredImage
        }
    }
    
    func setScreenRotation() {
        if (currentOrientation == AVCaptureVideoOrientation.LandscapeLeft) {
            self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            self.cameraView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            changeCameraButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            takePictureButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            filterButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            if (selfieModeIsOn) {
                let frameTransform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.frameView.transform = CGAffineTransformScale(frameTransform, -1, 1);
            } else {
                self.frameView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            }
        } else if (currentOrientation == AVCaptureVideoOrientation.LandscapeRight) {
            self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            self.cameraView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            changeCameraButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            takePictureButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            filterButton.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            
            if (selfieModeIsOn) {
                let frameTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.frameView.transform = CGAffineTransformScale(frameTransform, -1, 1);
            } else {
                self.frameView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            }
        } else {
            self.previewLayer!.connection?.videoOrientation = currentOrientation!
            self.cameraView.transform = CGAffineTransformIdentity
            self.imageView.transform = CGAffineTransformIdentity
            self.frameView.transform = CGAffineTransformIdentity
            changeCameraButton.transform = CGAffineTransformIdentity
            takePictureButton.transform = CGAffineTransformIdentity
            filterButton.transform = CGAffineTransformIdentity
            
            if (selfieModeIsOn) {
                self.frameView.transform = CGAffineTransformMakeScale(-1, 1);
            }
        }
        
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        cameraView.bounds = frameView.bounds
    }
    
    @IBAction func reverseCamera(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            
            self.selfieModeIsOn = false
            
            switch currentPosition{
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
            case AVCaptureDevicePosition.Back:
                self.selfieModeIsOn = true
                preferredPosition = AVCaptureDevicePosition.Front
            case AVCaptureDevicePosition.Unspecified:
                preferredPosition = AVCaptureDevicePosition.Back
            }
            
            let device:AVCaptureDevice = PostCardChoosePhotoViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
            
            var videoDeviceInput: AVCaptureDeviceInput?
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            self.captureSession!.beginConfiguration()
            self.captureSession!.removeInput(self.videoDeviceInput)
            
            if self.captureSession!.canAddInput(videoDeviceInput){
                NSNotificationCenter.defaultCenter().removeObserver(self, name:AVCaptureDeviceSubjectAreaDidChangeNotification, object:currentVideoDevice)
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            }else{
                self.captureSession!.addInput(self.videoDeviceInput)
            }
            
            self.captureSession!.commitConfiguration()
            
            self.setScreenRotation()
        })
    }
    
    class func deviceWithMediaType(mediaType: NSString, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType as String) as! [AVCaptureDevice]
        var captureDevice = devices[0]
        
        for device in devices {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice;
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    if (self.currentOrientation == AVCaptureVideoOrientation.LandscapeRight) {
                        if (self.selfieModeIsOn) {
                            image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                        } else {
                            image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Down)
                        }
                    }
                    if (self.currentOrientation == AVCaptureVideoOrientation.LandscapeLeft) {
                        if (self.selfieModeIsOn) {
                            image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Down)
                        } else {
                            image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                        }
                    }
                    
                    let size = CGSize(width: self.frameImage!.size.width, height: self.frameImage!.size.height)
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    image.drawInRect(areaSize)
                    
                    self.frameImage!.drawInRect(areaSize, blendMode: CGBlendMode.Normal, alpha: 1.0)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    Answers.logCustomEventWithName("Photo Taken", customAttributes: [:])
                    
                    let postCardVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardSaveViewController") as! PostCardSaveViewController
                    postCardVC.createdImage = newImage
                    self.presentViewController(postCardVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func filterPressed(sender: AnyObject) {
        filterIsOn = !filterIsOn
        self.imageView.hidden = !filterIsOn
    }
}