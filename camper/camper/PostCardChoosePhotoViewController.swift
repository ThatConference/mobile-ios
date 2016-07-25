import AVFoundation
import Photos
import UIKit

class PostCardChoosePhotoViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var frameView: UIImageView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var takePhoto: UIButton!
    
    var frame: PostCardFrame?
    var frameImage: UIImage?
    var frameOrientation: AVCaptureVideoOrientation?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoAlbum: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var useRearCamera = true
    var videoDeviceInput: AVCaptureDeviceInput?
    
    let ALBUM_NAME: String = "That Conference"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        frameImage = UIImage(named: (frame?.Filename!.lowercaseString)!)!
        frameView.image = frameImage
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewView.layer.addSublayer(previewLayer!)
        
        setCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.captureSession?.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set Camera Preview Bounds
        let rect = AVMakeRectWithAspectRatioInsideRect(frameImage!.size, frameView.bounds)
        previewLayer!.frame = rect
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
        
        frameOrientation = frame?.Orientation
        
        if error == nil && captureSession!.canAddInput(videoDeviceInput) {
            captureSession!.addInput(videoDeviceInput)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = frameOrientation!
                previewView.layer.addSublayer(previewLayer!)
                
                if (frameOrientation == AVCaptureVideoOrientation.LandscapeRight) {
                    self.baseView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                }
            }
        }
    }
    
    @IBAction func reverseCamera(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            
            switch currentPosition{
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
            case AVCaptureDevicePosition.Back:
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
                    if (self.frameOrientation == AVCaptureVideoOrientation.LandscapeRight) {
                        image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                    }
                    
                    let size = CGSize(width: self.frameImage!.size.width, height: self.frameImage!.size.height)
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    image.drawInRect(areaSize)
                    
                    self.frameImage!.drawInRect(areaSize, blendMode: CGBlendMode.Normal, alpha: 1.0)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let postCardVC = self.storyboard?.instantiateViewControllerWithIdentifier("PostCardSaveViewController") as! PostCardSaveViewController
                    postCardVC.createdImage = newImage
                    self.navigationController!.pushViewController(postCardVC, animated: true)
                }
            })
        }
    }
}