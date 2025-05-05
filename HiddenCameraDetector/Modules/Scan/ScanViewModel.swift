import AVFoundation
import UIKit
import CoreImage

final class ScanViewModel: NSObject {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "VideoQueue")
    private let ciContext = CIContext()
    
    var overlayColor: UIColor = .red
    
    var onFrameProcessed: ((UIImage) -> Void)?
    var onCameraReady: (() -> Void)?
    
    var onCameraPermissionDenied: (() -> Void)?
    
    private var isCameraReady = false
    
    // MARK: - Публичный метод для старта проверки камеры
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setupCamera()
        case .notDetermined:
            requestCameraAccess()
        case .denied, .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.onCameraPermissionDenied?()
            }
        @unknown default:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.onCameraPermissionDenied?()
            }
        }
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCamera()
                } else {
                    self?.onCameraPermissionDenied?()
                }
            }
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            print("No access to camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
                videoOutput.alwaysDiscardsLateVideoFrames = true
            }
            
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error in camera: \(error)")
        }
    }
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func process(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        
        guard
            let edgesImage = applyEdgesFilter(to: ciImage),
            let coloredImage = applyColorFilter(to: edgesImage),
            let cgImage = ciContext.createCGImage(coloredImage, from: coloredImage.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func applyEdgesFilter(to image: CIImage) -> CIImage? {
        guard let edgesFilter = CIFilter(name: "CIEdges") else { return nil }
        edgesFilter.setValue(image, forKey: kCIInputImageKey)
        edgesFilter.setValue(100.0, forKey: kCIInputIntensityKey)
        return edgesFilter.outputImage
    }
    
    private func applyColorFilter(to image: CIImage) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(colorInput(for: overlayColor), forKey: "inputColor1")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        return colorFilter.outputImage
    }
    
    private func colorInput(for color: UIColor) -> CIColor {
        switch color {
        case .red:
            return CIColor(red: 1, green: 0, blue: 0)
        case .blue:
            return CIColor(red: 0, green: 0, blue: 1)
        case .green:
            return CIColor(red: 0, green: 1, blue: 0)
        default:
            return CIColor(red: 1, green: 0, blue: 0)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ScanViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let processedImage = process(pixelBuffer: pixelBuffer)
        else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.isCameraReady {
                self.isCameraReady = true
                self.onCameraReady?()
            }
            self.onFrameProcessed?(processedImage)
        }
    }
}
