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
        
        currentOrientation = AVCaptureVideoOrientation.portrait
        
        updateFrameInfo()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        
        self.imageView.isHidden = true
        //setCameraWitHFilter()
        setCamera()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostCardChoosePhotoViewController.handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        upSwipe.direction = .up
        downSwipe.direction = .down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostCardChoosePhotoViewController.DidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.captureSession?.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCamera()
    }
    
    func finalSetUp() {
        //Set Camera Preview Bounds
        let rect = AVMakeRect(aspectRatio: frameImage!.size, insideRect: frameView.bounds)
        cameraView.bounds = frameView.bounds
        previewLayer!.frame = rect
        //imageView.frame = rect
        
        //Frame Message
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "tutorialWasShown") {
            let alertController = UIAlertController(title: nil, message: "Swipe To Change Frame Style", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            let delay = 4.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alertController.dismiss(animated: true, completion: nil);
            })
            
            // Update defaults
            defaults.set(true, forKey: "tutorialWasShown")
            UserDefaults.standard.synchronize()
        }
    }
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            finalSetUp()
            break
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for Photo Taking",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: false, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Please allow camera access for Photo Taking",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    DispatchQueue.main.async {
                        self.checkCamera() } }
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            moveToNext()
        }
        
        if (sender.direction == .right) {
            moveToPrevious()
        }
        
        if (sender.direction == .up) {
            moveToNext()
        }
        
        if (sender.direction == .down) {
            moveToPrevious()
        }
    }
    
    fileprivate func moveToNext() {
        frameIndex += 1
        
        if (frameIndex >= frames.count) {
            frameIndex = 0
        }
        
        updateFrameInfo()
    }
    
    fileprivate func moveToPrevious() {
        frameIndex -= 1
        
        if (frameIndex < 0) {
            frameIndex = frames.count - 1
        }
        
        updateFrameInfo()
    }
    
    @objc func DidRotate() {
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.landscapeLeft:
            currentOrientation = AVCaptureVideoOrientation.landscapeLeft
            break;
        case UIDeviceOrientation.landscapeRight:
            currentOrientation = AVCaptureVideoOrientation.landscapeRight
            break;
        default:
            currentOrientation = AVCaptureVideoOrientation.portrait
            break;
        }
        
        DispatchQueue.main.async(execute: {
            self.updateFrameInfo()
            self.setScreenRotation()
        })
    }
    
    func updateFrameInfo() {
        populateFrames()
        frame = frames[frameIndex]
        
        if ((currentOrientation == AVCaptureVideoOrientation.landscapeLeft)
            || (currentOrientation == AVCaptureVideoOrientation.landscapeRight) ) {
            frameImage = UIImage(named: (frame!.FilenameLandscape!.lowercased()))!
        } else {
            frameImage = UIImage(named: (frame!.FilenamePortrait!.lowercased()))!
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
        
        let frame5 = PostCardFrame(title: "Branch",
                                   filenameLandscape: "branch-landscape",
                                   filenamePortrait: "branch-portrait")
        frames.append(frame5)
        
        let frame6 = PostCardFrame(title: "Drone",
                                   filenameLandscape: "drone-landscape",
                                   filenamePortrait: "drone-portrait")
        frames.append(frame6)
        
        let frame7 = PostCardFrame(title: "Rabbit",
                                   filenameLandscape: "rabbit-landscape",
                                   filenamePortrait: "rabbit-portrait")
        frames.append(frame7)
        
        let frame8 = PostCardFrame(title: "Stream",
                                   filenameLandscape: "stream-landscape",
                                   filenamePortrait: "stream-portrait")
        frames.append(frame8)
        
        let frame9 = PostCardFrame(title: "TC Bottom Dark",
                                   filenameLandscape: "tc-bottom-dark",
                                   filenamePortrait: "tc-bottom-dark-portrait")
        frames.append(frame9)
        
        let frame10 = PostCardFrame(title: "TC Bottom Light",
                                   filenameLandscape: "tc-bottom-light",
                                   filenamePortrait: "tc-bottom-light-portrait")
        frames.append(frame10)
        
        let frame11 = PostCardFrame(title: "TC Top Dark",
                                   filenameLandscape: "tc-top-dark",
                                   filenamePortrait: "tc-top-dark-portrait")
        frames.append(frame11)
        
        let frame12 = PostCardFrame(title: "TC Top Light",
                                   filenameLandscape: "tc-top-light",
                                   filenamePortrait: "tc-top-light-portrait")
        frames.append(frame12)
        
        let frame13 = PostCardFrame(title: "Bear with Trees",
                                   filenameLandscape: "bear-with-trees",
                                   filenamePortrait: "bear-with-trees-portrait")
        frames.append(frame13)
        
        let frame14 = PostCardFrame(title: "Bear Friend",
                                   filenameLandscape: "bear-landscape",
                                   filenamePortrait: "bear-portrait")
        frames.append(frame14)
        
        let frame15 = PostCardFrame(title: "Big Bear Friend",
                                    filenameLandscape: "big-bear-landscape",
                                    filenamePortrait: "big-bear-portrait")
        frames.append(frame15)

    }
    
    func setCamera() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        
        var error: NSError?
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            videoDeviceInput = nil
        }
        
        if error == nil && captureSession!.canAddInput(videoDeviceInput!) {
            captureSession!.addInput(videoDeviceInput!)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            
            if captureSession!.canAddOutput(stillImageOutput!) {
                captureSession!.addOutput(stillImageOutput!)
    
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer!.connection?.videoOrientation = currentOrientation!
                cameraView.layer.addSublayer(previewLayer!)
            }
        }
    }
    
    func setCameraWitHFilter() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: backCamera!)
            captureSession!.addInput(videoDeviceInput!)
        }
        catch {
            print("Cannot Access Camera")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = currentOrientation!
        cameraView.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        
        captureSession!.addOutput(videoOutput)
        captureSession!.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        let videoEffect = CIFilter(name: "CIPhotoEffectInstant")
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        videoEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        let filteredImage = UIImage(ciImage: videoEffect!.value(forKey: kCIOutputImageKey) as! CIImage!)
        
        DispatchQueue.main.async
        {
            self.imageView.image = filteredImage
        }
    }
    
    func setScreenRotation() {
        if (currentOrientation == AVCaptureVideoOrientation.landscapeLeft) {
            self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            self.cameraView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            changeCameraButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            takePictureButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            filterButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            
            if (selfieModeIsOn) {
                let frameTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.frameView.transform = frameTransform.scaledBy(x: -1, y: 1);
            } else {
                self.frameView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            }
        } else if (currentOrientation == AVCaptureVideoOrientation.landscapeRight) {
            self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            self.cameraView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            changeCameraButton.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            takePictureButton.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            filterButton.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            
            if (selfieModeIsOn) {
                let frameTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
                self.frameView.transform = frameTransform.scaledBy(x: -1, y: 1);
            } else {
                self.frameView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            }
        } else {
            self.previewLayer!.connection?.videoOrientation = currentOrientation!
            self.cameraView.transform = CGAffineTransform.identity
            self.imageView.transform = CGAffineTransform.identity
            self.frameView.transform = CGAffineTransform.identity
            changeCameraButton.transform = CGAffineTransform.identity
            takePictureButton.transform = CGAffineTransform.identity
            filterButton.transform = CGAffineTransform.identity
            
            if (selfieModeIsOn) {
                self.frameView.transform = CGAffineTransform(scaleX: -1, y: 1);
            }
        }
        
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
        cameraView.bounds = frameView.bounds
    }
    
    @IBAction func reverseCamera(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevice.Position = currentVideoDevice.position
            var preferredPosition: AVCaptureDevice.Position = AVCaptureDevice.Position.unspecified
            
            self.selfieModeIsOn = false
            
            switch currentPosition{
            case AVCaptureDevice.Position.front:
                preferredPosition = AVCaptureDevice.Position.back
            case AVCaptureDevice.Position.back:
                self.selfieModeIsOn = true
                preferredPosition = AVCaptureDevice.Position.front
            case AVCaptureDevice.Position.unspecified:
                preferredPosition = AVCaptureDevice.Position.back
            }
            
            let device:AVCaptureDevice = PostCardChoosePhotoViewController.deviceWithMediaType(AVMediaType.video as NSString, preferringPosition: preferredPosition)
            
            var videoDeviceInput: AVCaptureDeviceInput?
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            self.captureSession!.beginConfiguration()
            self.captureSession!.removeInput(self.videoDeviceInput!)
            
            if self.captureSession!.canAddInput(videoDeviceInput!){
                NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object:currentVideoDevice)
                self.captureSession!.addInput(videoDeviceInput!)
                self.videoDeviceInput = videoDeviceInput
                
            }else{
                self.captureSession!.addInput(self.videoDeviceInput!)
            }
            
            self.captureSession!.commitConfiguration()
            
            self.setScreenRotation()
        })
    }
    
    class func deviceWithMediaType(_ mediaType: NSString, preferringPosition position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType as String as String)) 
        var captureDevice = devices[0]
        
        for device in devices {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice;
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if let videoConnection = stillImageOutput!.connection(with: AVMediaType.video) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    
                    var image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    if (self.currentOrientation == AVCaptureVideoOrientation.landscapeRight) {
                        if (self.selfieModeIsOn) {
                            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.up)
                        } else {
                            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.down)
                        }
                    }
                    if (self.currentOrientation == AVCaptureVideoOrientation.landscapeLeft) {
                        if (self.selfieModeIsOn) {
                            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.down)
                        } else {
                            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.up)
                        }
                    }
                    
                    let size = CGSize(width: self.frameImage!.size.width, height: self.frameImage!.size.height)
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    image.draw(in: areaSize)
                    
                    self.frameImage!.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: 1.0)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    
                    Answers.logCustomEvent(withName: "Photo Taken", customAttributes: [:])
                    
                    let postCardVC = self.storyboard?.instantiateViewController(withIdentifier: "PostCardSaveViewController") as! PostCardSaveViewController
                    postCardVC.createdImage = newImage
                    self.present(postCardVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func filterPressed(_ sender: AnyObject) {
        filterIsOn = !filterIsOn
        self.imageView.isHidden = !filterIsOn
    }
}
