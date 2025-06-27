//
//  ScreenRecorder.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 27/06/25.
//

import ReplayKit
import UIKit

class ScreenRecorder: UIViewController, RPScreenRecorderDelegate, RPPreviewViewControllerDelegate {
    private let recorder = RPScreenRecorder.shared()

    func startScreenRecording() {
        recorder.startRecording { error in
            if let error = error {
                print("Error starting recording: \(error)")
            } else {
                print("Screen recording started.")
            }
        }
    }
    
    /// Stop recording and show preview
       func stopRecordingAndShowPreview() {
           guard recorder.isRecording else {
               print("Not recording, so nothing to stop.")
               return
           }
           recorder.stopRecording { [weak self] previewVC, error in
               if let error = error {
                   print("Failed to stop recording: \(error)")
               } else if let previewVC = previewVC {
                   previewVC.previewControllerDelegate = self
                   // Present the preview controller
                   self?.present(previewVC, animated: true, completion: nil)
               }
           }
       }

       /// RPPreviewViewControllerDelegate
       func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
           // Dismiss the preview when done
           previewController.dismiss(animated: true, completion: nil)
       }
}
