//
//  ViewController.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 25/06/25.
//

import UIKit
import Network
import AVFoundation

class ViewController: UIViewController {
    // MARK: - Properties
    var connection: NWConnection?
    var listener: NWListener?
    var textLog = TextLog()
    
    var dateFormatter: String {
        DateUtility.getFormattedDate()
    }
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var screenShotButton: UIButton!
    @IBOutlet weak var startScreenRecordButton: UIButton!
    @IBOutlet weak var stopScreenRecordButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addGestureRecognizers()
        addButton()
        inputTextField.delegate = self
        setAccessibilityIdentifiers()
        start(port: 12345)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            print("orientation is landscapeLeft")
        case .landscapeRight:
            print("orientation is landscapeRight")
        case .portraitUpsideDown:
            print("orientation is portraitUpsideDown")
        case .portrait:
            print("orientation is portrait")
        default:
            print("Unknown orientation")
        }
    }
    
    // MARK: - Add gestures
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didRecongnizeTapGesture(_:)))
        view.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didRecongnizePinchGesture(_:)))
        view.addGestureRecognizer(pinch)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didRecongnizeLongPressGesture(_:)))
        view.addGestureRecognizer(longPress)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didRecongnizePanGesture(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func didRecongnizeTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        textLog.write("Tap gresture with Date: ******* \(Date()) ******** at location: \(location)  \n")
    }
    
    @objc func didRecongnizePinchGesture(_ sender: UIPinchGestureRecognizer) {
        let location = sender.location(in: view)
        textLog.write("Pinch gresture with Date: ******* \(Date()) ******** at location: \(location)  \n")
    }
    
    @objc func didRecongnizeLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: view)
        textLog.write("LongPress gresture with Date: ******* \(Date()) ******** at location: \(location)  \n")
    }
    
    @objc func didRecongnizePanGesture(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        textLog.write("Pan gresture with Date: ******* \(Date()) ******** at location: \(location)  \n")
    }
    
    // MARK: Add Button
    
    private func addButton() {
        actionButton.layer.cornerRadius = 5
        screenShotButton.layer.cornerRadius = 5
        screenShotButton.layer.cornerRadius = 5
        startScreenRecordButton.layer.cornerRadius = 5
        stopScreenRecordButton.layer.cornerRadius = 5
        actionButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @IBAction func screenshotTapped(_ sender: Any) {
        saveScreenshot()
        sendEvent([
            "type": "Screenshot",
            "timestamp": dateFormatter,
            "payload": "\n Screenshot tapped \n"
        ])
    }
    
    @IBAction func sartScreenTapped(_ sender: Any) {
        let screenRecorder = ScreenRecorder()
        screenRecorder.startScreenRecording()
    }
    
    @IBAction func stopScreenTapped(_ sender: Any) {
        let screenRecorder = ScreenRecorder()
        screenRecorder.stopRecordingAndShowPreview()
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        sendEvent([
            "type": "Button",
            "timestamp": dateFormatter,
            "payload": "\n Action Button tapped \n"
        ])
        
        let logEntries = [
            LogEntry(type: "Button Tapped", timestamp: "\(Date())", message: "\(sender)")
        ]
        
        prepareJson(logEntries: logEntries)
    }
    
    private func prepareJson(logEntries: [LogEntry]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted /// For readable JSON
        
        do {
            let jsonData = try encoder.encode(logEntries)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Json String \(jsonString)")
                textLog.write("\(jsonString)  \n")
                readLogfile()
            }
        } catch {
            print("Failed to encode or save JSON: \(error)")
        }
    }
    
    private func setAccessibilityIdentifiers() {
        actionButton.accessibilityIdentifier = "identifier_action_button"
        inputTextField.accessibilityIdentifier = "identifier_input_textField"
    }
    
    // MARK: Screenshot
    func takeScreenshot() -> UIImage? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return nil }
        let renderer = UIGraphicsImageRenderer(size: window.bounds.size)
        return renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
    
    func saveScreenshot() {
        guard let screenshot = takeScreenshot(),
              let data = screenshot.pngData() else {
            print("Failed to capture screenshot.")
            return
        }
        let fm = FileManager.default
        let url = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("screenshot-\(Date()).png")
        do {
            try data.write(to: url, options: .completeFileProtection)
            print("Screenshot saved at: \(url)")
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }
    
    // MARK: Logfile
    func readLogfile() {
        let fm = FileManager.default
        let logURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
        
        do {
            let logContents = try String(contentsOf: logURL, encoding: .utf8)
            print("Log file contents:\n\(logContents)")
        } catch {
            print("Failed to read log file: \(error)")
        }
    }
    
    func start(port: UInt16) {
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port) ?? 0)
        } catch {
            print("Failed to start listener: \(error)")
            return
        }
        
        listener?.newConnectionHandler = { [weak self] conn in
            self?.connection = conn
            conn.start(queue: .main)
            print("Connection established!")
        }
        
        listener?.start(queue: .main)
        print("Server started on port \(port)")
    }
    
    // MARK: Send Event to Mac app
    func sendEvent(_ event: [String: Any]) {
        guard let connection else { return }
        if let data = try? JSONSerialization.data(withJSONObject: event) {
            connection.send(content: data, completion: .contentProcessed({ error in
                if let error = error {
                    print("Send error: \(error)")
                } else {
                    print("Event sent!")
                }
            }))
        }
    }
    
}
// MARK: TextField delegates
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        print("Textfield data entered char \(text)")
        textLog.write("Text field input with Date: ******* \(Date()) ******** Text: \(text) \n")
        sendEvent([
            "type": "TextField",
            "timestamp": dateFormatter,
            "payload": "\n User input @@@ \(text) \n"
        ])
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { return true }
        
        let stringText = string
        if !string.isEmpty { /// if a character is not deleted
            text += stringText
        } else if text.count > 0 { /// If a character is deleted
            text = String(text.dropLast())
        }
        return true
    }
}
