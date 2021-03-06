//
//  ScanQRViewController.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/27/21.
//

import UIKit
import AVFoundation
import Foundation
import SwiftSoup


class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    var reqToken = "1"

    enum FlashPhotoMode {

            case on
            case off
        }
    
    var mode = FlashPhotoMode.off
    
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var lastDoseLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var nrPersonalLbl: UILabel!
    @IBOutlet weak var emriLbl: UILabel!
    @IBOutlet weak var vaksinuarLbl: UILabel!
    @IBOutlet weak var lbl: UILabel!

  
    @IBAction func flashBtn(_ sender: UIButton) {
        turnFlash()
    }
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var resultIcon: UIImageView!
    @IBOutlet weak var spinningIndicator: UIActivityIndicatorView!

    @IBOutlet weak var exitIcon: UIImageView!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

        override func viewDidLoad() {
            super.viewDidLoad()
            let tap = UITapGestureRecognizer(target: self, action: #selector(ScanQRViewController.tapFunction))
            exitIcon.isUserInteractionEnabled = true
            exitIcon.addGestureRecognizer(tap)
            DispatchQueue.main.async {
                self.infoStackView.isHidden = true
            }
            
            
            scanBtn.layer.cornerRadius = 7.0
                    
            scanBtn.layer.shadowColor = UIColor.black.cgColor
            scanBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
            scanBtn.layer.shadowRadius = 5
            scanBtn.layer.shadowOpacity = 0.3

            
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return failed() }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                failed()
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                failed()
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
            self.view.bringSubviewToFront(scanBtn)
            self.view.bringSubviewToFront(exitIcon)
            exitIcon.layer.cornerRadius = 8.0
            self.view.bringSubviewToFront(flashButton)
            self.flashButton.layer.cornerRadius = 9.0
        }
    
@objc
func tapFunction(sender:UITapGestureRecognizer) {
    dismiss(animated: true)
}
    
    func turnFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        if device.hasTorch	 {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                                } else {
                                    do {
                                        try device.setTorchModeOn(level: 1.0)
                                    } catch {
                                        print(error)
                                    }
                                }
                device.unlockForConfiguration()
            } catch  {
                print(error)
            }
        }
    }
    
    func openSettings(alert: UIAlertAction!) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.dismiss(animated: true)
        }
    }
        func failed() {
            captureSession = nil
            DispatchQueue.main.async {
                self.resultIcon.isHidden = true
                self.vaksinuarLbl.isHidden = true
                self.scanBtn.isHidden = true
                self.spinningIndicator.isHidden = true
                
                let ac = UIAlertController(title: "Nuk mund te skanoni", message: "Per te skanuar duhet qasje ne kamere", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Mbyll", style: .default, handler: {action in
                    self.dismiss(animated: true)
                }))
                ac.addAction(UIAlertAction(title: "Hap Settings", style: .default, handler: self.openSettings))
                self.present(ac, animated: true)
            }
            
           
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()
            let systemSoundID: SystemSoundID = 1407
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(1394))
                AudioServicesPlaySystemSound(systemSoundID)
                found(code: stringValue)
            }
           // dismiss(animated: true)
        }
    
    
    func getToken(url: URL) -> String{
        do{
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)

            // print(document)

            let reqTokenItem = try document.select("[name=__RequestVerificationToken]").first()!
            let result = try reqTokenItem.val()
            return result
        }catch{
            return "Error"
        }
        
    }
    
    func found(code: String) {
        
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                                } else {
                                }
                device.unlockForConfiguration()
            } catch  {
                print(error)
            }
        }
        DispatchQueue.main.async {
            self.flashButton.isHidden = true
            self.scanBtn.isHidden = true
        }
        if !(code.hasPrefix("https://ekosova.rks-gov.net") || code.hasPrefix("http://ekosova.rks-gov.net") || code.hasPrefix("ekosova.rks-gov.net")) {
            DispatchQueue.main.async {
                self.vaksinuarLbl.text = "QR Code i gabuar"
                let image = UIImage(systemName: "xmark.circle.fill")
                self.resultIcon?.image = image
                self.resultIcon.tintColor = UIColor.red
                self.infoStackView.isHidden = true
                self.spinningIndicator.isHidden = true
            }
            captureSession.stopRunning()
            self.previewLayer?.removeFromSuperlayer()
            return
            
        }
        guard let url = URLComponents(string: code) else { return }
        guard let reference = url.queryItems?.first(where: { $0.name == "code" })?.value else { return}
                // 36 karaktere 
        
            DispatchQueue.main.async {
                self.vaksinuarLbl.text = "Duke kerkuar"
                let image = UIImage(systemName: "magnifyingglass")
                self.resultIcon?.image = image
                self.resultIcon.tintColor = UIColor.blue
                self.infoStackView.isHidden = true
                
            }
            self.captureSession?.stopRunning()
            self.previewLayer?.removeFromSuperlayer()
            let rurl = URL(string: "https://ekosova.rks-gov.net/VaccinationPassport/" + reference)
                    // Create URL Request
            var request = URLRequest(url: rurl!)
                    // Specify HTTP Method to use
            request.httpMethod = "GET"
        
        // let surl = URL(string: code)!

        // let reqToken = getToken(url: surl)
        let reqToken = "CfDJ8DxWiKK55mtEsZ8q1sj1IJctkibo9afRlY4FcSR_M6PSGWgn7gyUWpwougW0A-fqADpKWEDLwJrC68s4X304Ws9raWu6yXa-H1eCzNfUg5fxiFnrgrgWjd6Apbs3wcv3dYDJKHCdHTe7tt7ByDbxE1o"
        let cookie = ".AspNetCore.Antiforgery.sfP6sknPLHg=CfDJ8DxWiKK55mtEsZ8q1sj1IJcesNP3iqbmBSCQDPcrN3cu_vhsYOHCMJEBF6jqnT1jJjmWZjUozo1qXuS27o82rHJjishAig53h8PwM6q1CEzCPx43uCyRjjV52Lmi_n7VkL04frQH28tL9JNVts4IcH4; lang=sq-al"
        
        request.addValue(reqToken, forHTTPHeaderField: "RequestVerificationToken")
        request.addValue(cookie, forHTTPHeaderField: "Cookie")
   
            let task = URLSession.shared.dataTask(with: request) { [self](data, response, error) in
                      guard let response = response else {
                        print("Cannot found the response")
                        return
                      }
                      let myResponse = response as! HTTPURLResponse
                if myResponse.statusCode == 200 {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: [])
                        print("cool") //Response result
                        // guard let jsonArray = jsonResponse as? [[String: Any]] else { return }
                        
                        let object = jsonResponse as? [String: Any]
                        let data = object?["data"] as? [[String: Any]]
                        guard let jsonArray = data?[0]["immunization"] as? [[String: Any]] else { return }
                        
                            
                        
                        let nrPersonal = jsonArray[0]["patientPersonalNo"] as! String
                        let name = jsonArray[0]["name"] as! String
                        let surname = jsonArray[0]["surname"] as! String
                        let dob: String = jsonArray[0]["birthdate"] as! String
                        let year = dob[..<dob.firstIndex(of: "-")!]
                        let lastVaccination = jsonArray[jsonArray.count - 1]["date"] as! String
                        let lastVac = lastVaccination[..<lastVaccination.firstIndex(of: "T")!]
                                   
                   
                        DispatchQueue.main.async {
                            if jsonArray.count > 1 {
                                vaksinuarLbl.text = "Vaksinuar me " + String(jsonArray.count) + " doza"
                            }else{
                                vaksinuarLbl.text = "Vaksinuar me 1 doz??"
                            }
                            nrPersonalLbl.text = nrPersonal
                            emriLbl.text = name + " " + surname
                            yearLbl.text = String(year)
                            lastDoseLbl.text = String(lastVac)
                            let image = UIImage(systemName: "person.crop.circle.fill.badge.checkmark")
                            resultIcon?.image = image
                            resultIcon.tintColor = UIColor.green
                            
                            infoStackView.isHidden = false
                            spinningIndicator.isHidden = true
                            
                        }
                        
                        
                         } catch let parsingError {
                            print("Error", parsingError)
                       }
                }else if myResponse.statusCode == 204{
                    DispatchQueue.main.async {
                        vaksinuarLbl.text = "Kartela nuk eshte valide"
                        
                        let image = UIImage(systemName: "person.crop.circle.fill.badge.questionmark")
                        resultIcon?.image = image
                        resultIcon.tintColor = UIColor.red
                        infoStackView.isHidden = true
                        spinningIndicator.isHidden = true
                    }
                }else{
                    print(myResponse.statusCode)
                }
                
                    }
                task.resume()
            
        
        }
        

        override var prefersStatusBarHidden: Bool {
            return true
        }

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
    }
        // Do any additional setup after loading the view.


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


