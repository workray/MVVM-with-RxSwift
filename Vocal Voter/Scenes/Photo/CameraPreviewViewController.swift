//
//  CameraPreviewViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/21/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewViewController: UIViewController {

//    var captureSession: AVCaptureSession!
//    var stillImageOutput: AVCapturePhotoOutput!
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .high
//
//        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
//            print("Unable to access back camera!")
//            return
//        }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: backCamera)
//            stillImageOutput = AVCapturePhotoOutput()
//
//            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
//                captureSession.addInput(input)
//                captureSession.addOutput(stillImageOutput)
//                setupLivePreview()
//            }
//        }
//        catch let error  {
//            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.captureSession.stopRunning()
//    }
//
//    func setupLivePreview() {
//
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//
//        videoPreviewLayer.videoGravity = .resizeAspect
//        videoPreviewLayer.connection?.videoOrientation = .portrait
//        view.layer.addSublayer(videoPreviewLayer)
//
//        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
//            self.captureSession.startRunning()
//            DispatchQueue.main.async {
//                self.videoPreviewLayer.frame = self.view.bounds
//            }
//        }
//    }
//
//    func takePhoto() {
//        if #available(iOS 11.0, *) {
//            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//            stillImageOutput.capturePhoto(with: settings, delegate: self)
//        } else {
//            // Fallback on earlier versions
//            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
//            stillImageOutput.capturePhoto(with: settings, delegate: self)
//        }
//    }
//
//    func didTakePhoto(_ image: UIImage) {
//
//    }
}

//extension CameraPreviewViewController: AVCapturePhotoCaptureDelegate {
//    @available(iOS 11.0, *)
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        
//        guard let imageData = photo.fileDataRepresentation()
//            else { return }
//        
//        if let image = UIImage(data: imageData) {
//            didTakePhoto(image)
//        }
//    }
//        
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//        if let error = error {
//            print(error.localizedDescription)
//        }
//        
//        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//            if let image = UIImage(data: dataImage) {
//                didTakePhoto(image)
//            }
//        }
//    }
//}
