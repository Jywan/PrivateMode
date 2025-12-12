//
//  PresenceDetector.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import AVFoundation
import Vision

final class PresenceDetector: NSObject {
    
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "presence.detector.queue")
    private let sessionQueue = DispatchQueue(label: "presence.session.queue")
    private var isConfigured = false
    
    var onUserPresent: (() -> Void)?
    var onUserAbsent: (() -> Void)?
    
    private var lastFaceDetectedAt: Date?
    
    func start() {
        checkPermission { granted in
            guard granted else { return }

            self.sessionQueue.async {
                if !self.isConfigured {
                    self.setupSession()
                    self.isConfigured = true
                }
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        session.stopRunning()
    }
    
    private func checkPermission(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { completion($0) }
        default:
            completion(false)
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .low

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
    }
    
    private func handleFaceDetected() {
        lastFaceDetectedAt = Date()
        DispatchQueue.main.async { self.onUserPresent?() }
    }
    
    private func handleNoFace() {
        guard
            let last = lastFaceDetectedAt,
            Date().timeIntervalSince(last) > 2.0
        else { return }
        
        DispatchQueue.main.async { self.onUserAbsent?() }
    }
    
}

// 얼굴 감지 연결
extension PresenceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let request = VNDetectFaceRectanglesRequest { [weak self] req, _ in
            guard let self = self else { return }
            
            if let results = req.results as? [VNFaceObservation], !results.isEmpty {
                self.handleFaceDetected()
            } else {
                self.handleNoFace()
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        
        try? handler.perform([request])
    }
}
