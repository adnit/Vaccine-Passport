//
//  PassportViewController.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/29/21.
//

import UIKit
import AVFoundation
import Foundation


class PassportViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var emriMbiemriBtn: UIButton!
    @IBOutlet weak var titleLblBtn: UIButton!
    
    @IBOutlet weak var exitIcon: UIImageView!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var qrCodeImg: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var surnameLbl: UILabel!
    
    @IBAction func flashBtnTouched(_ sender: UIButton) {
        turnFlash()
    }
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var spinningIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doza1Btn: UIButton!
    @IBOutlet weak var doza2Btn: UIButton!
    
    @IBOutlet weak var firstDoseLbl: UILabel!
    @IBOutlet weak var secondDoseLbl: UILabel!

    @IBOutlet weak var flashBtn: UIButton!
    let userDefaults = UserDefaults.standard
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        let userExists =  UserDefaults.standard.object(forKey: "referenca") != nil
        
        if userExists{
            DispatchQueue.main.async {
                self.qrCodeImg.image = self.generateQRCode(from: UserDefaults.standard.object(forKey: "referenca") as! String)
            }
        }
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitIcon.isUserInteractionEnabled = true

        
        scanBtn.layer.cornerRadius = 7.0
        titleLblBtn.layer.cornerRadius = 10.0
        
        doza1Btn.layer.cornerRadius = 6.0
        doza2Btn.layer.cornerRadius = 5.0
        
        
        
        let userExists =  UserDefaults.standard.object(forKey: "nrpersonal") != nil
        
        if !userExists {
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
            doza1Btn.isEnabled = false
            doza2Btn.isEnabled = false
            emriMbiemriBtn.isEnabled = false
            self.view.bringSubviewToFront(scanBtn)
            self.view.bringSubviewToFront(exitIcon)
            exitIcon.layer.cornerRadius = 8.0
            let interaction = UIContextMenuInteraction(delegate: self)
            moreBtn.addInteraction(interaction)
            
            self.view.bringSubviewToFront(flashBtn)
            self.flashBtn.layer.cornerRadius = 9.0
            // Do any additional setup after loading the view.
            
            
        }else{
            let interaction = UIContextMenuInteraction(delegate: self)
            moreBtn.addInteraction(interaction)
            let myarray = UserDefaults.standard.object(forKey: "dose1") as? [String]
            DispatchQueue.main.async {
                self.flashBtn.isHidden = true
                self.nameLbl.text = (UserDefaults.standard.object(forKey: "name") as! String)
                self.surnameLbl.text = (UserDefaults.standard.object(forKey: "surname") as! String)
                self.firstDoseLbl.text = myarray?[2] as Any as? String
                self.scanBtn.isHidden = true
                self.spinningIndicator.isHidden = true
            }
            
            
            if UserDefaults.standard.object(forKey: "dose2") != nil {
                let myarray2 = UserDefaults.standard.object(forKey: "dose2") as? [String]
                DispatchQueue.main.async {
                    self.secondDoseLbl.text = myarray2?[2] as Any as? String
                }
            }else{
                DispatchQueue.main.async {
                    self.doza2Btn.isHidden = true
                    self.secondDoseLbl.isHidden = true
                }
            }
        }
        }
        
        
    func openSettings(alert: UIAlertAction!) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.dismiss(animated: true)
        }
    }
    func turnFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        if device.hasTorch     {
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
    
    func failed() {
        captureSession = nil
        DispatchQueue.main.async {
        
            self.hideError()
            
            let ac = UIAlertController(title: "Nuk mund te skanoni", message: "Per te skanuar duhet qasje ne kamere", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Mbyll", style: .default, handler: {action in
                self.dismiss(animated: true)
            }))
            ac.addAction(UIAlertAction(title: "Hap Settings", style: .default, handler: self.openSettings))
            self.present(ac, animated: true)
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
            found(code: stringValue, reload: false)
        }
       // dismiss(animated: true)
    }
    
    func found(code: String, reload: Bool) {
        
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
            self.flashBtn.isHidden = true
            // self.scanBtn.isHidden = true
        }
        if !(code.hasPrefix("https://ekosova.rks-gov.net") || code.hasPrefix("http://ekosova.rks-gov.net") || code.hasPrefix("ekosova.rks-gov.net")){
        let alert = UIAlertController(title: "QR Code i gabuar", message: "Ju lutem skanoni QR Code ne kartelen tuaj", preferredStyle: .alert)

        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in
            self.dismiss(animated: true)
            self.captureSession?.stopRunning()
            self.previewLayer?.removeFromSuperlayer()
        }))

        self.present(alert, animated: true)

        return
        
    }
    guard let url = URLComponents(string: code) else { return }
    guard let reference = url.queryItems?.first(where: { $0.name == "code" })?.value else { return}
            // 36 karaktere
        
        DispatchQueue.main.async {
            self.scanBtn.setTitle("Duke kerkuar", for: .normal)
            self.view.bringSubviewToFront(self.spinningIndicator)
        }
    
        let rurl = URL(string: "https://ekosova.rks-gov.net/VaccinationPassport/" + reference)
                // Create URL Request
        var request = URLRequest(url: rurl!)
                // Specify HTTP Method to use
        request.httpMethod = "GET"
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
                    
                    DispatchQueue.main.async {
                        qrCodeImg.image = generateQRCode(from: code)
                    }
                    
                    
                    let nrPersonal = jsonArray[0]["patientPersonalNo"] as! String
                    let name = jsonArray[0]["name"] as! String
                    let surname = jsonArray[0]["surname"] as! String
                    let dob: String = jsonArray[0]["birthdate"] as! String
                    let birthdate = dob[..<dob.firstIndex(of: "T")!]
                    
                    if jsonArray.count == 2 {
                        
                        let firstVac = jsonArray[jsonArray.count - 2]["date"] as! String
                        let vac1date = firstVac[..<firstVac.firstIndex(of: "T")!]
                        let secondVac = jsonArray[jsonArray.count - 1]["date"] as! String
                        let vac2date = secondVac[..<secondVac.firstIndex(of: "T")!]
                        
                        var firstDose = [String]()
                        
                        firstDose.append(jsonArray[0]["vaccineManufacturer"] as! String)
                        firstDose.append(jsonArray[0]["serialNo"] as! String)
                        firstDose.append(String(vac1date))
                        firstDose.append(jsonArray[0]["note"] as? String ?? "Nuk ka")
                        firstDose.append(jsonArray[0]["medicalStaff"] as! String)
                        firstDose.append(jsonArray[0]["assistantMedicalStaff"] as! String)
                        
                        
                        
                        var secondDose = [String]()
                        
                        secondDose.append(jsonArray[1]["vaccineManufacturer"] as! String)
                        secondDose.append(jsonArray[1]["serialNo"] as! String)
                        secondDose.append(String(vac2date))
                        secondDose.append(jsonArray[1]["note"] as? String ?? "Nuk ka")
                        secondDose.append(jsonArray[1]["medicalStaff"] as! String)
                        secondDose.append(jsonArray[1]["assistantMedicalStaff"] as! String)
                        UserDefaults.standard.set(firstDose, forKey: "dose1")
                        UserDefaults.standard.set(secondDose, forKey: "dose2")
                        
                        DispatchQueue.main.async {
                            firstDoseLbl.text = String(vac1date)
                            secondDoseLbl.text = String(vac2date)
                            doza2Btn.isHidden = false
                            secondDoseLbl.isHidden = false
                        }
                    }else if jsonArray.count == 1{
                        
                        let firstVac = jsonArray[jsonArray.count - 1]["date"] as! String
                        let vac1date = firstVac[..<firstVac.firstIndex(of: "T")!]
                        
                        var firstDose = [String]()
                        
                        firstDose.append(jsonArray[0]["vaccineManufacturer"] as! String)
                        firstDose.append(jsonArray[0]["serialNo"] as! String)
                        firstDose.append(String(vac1date))
                        firstDose.append(jsonArray[0]["note"] as? String ?? "Nuk ka")
                        
                        firstDose.append(jsonArray[0]["medicalStaff"] as! String)
                        firstDose.append(jsonArray[0]["assistantMedicalStaff"] as! String)
                        
                        UserDefaults.standard.set(firstDose, forKey: "dose1")
                        
                        DispatchQueue.main.async {
                            doza2Btn.isHidden = true
                            secondDoseLbl.isHidden = true
                            firstDoseLbl.text = String(vac1date)
                        }
                    }
                    
	
                    DispatchQueue.main.async {
                        doza1Btn.isEnabled = true
                        doza2Btn.isEnabled = true
                        exitIcon.isHidden = true
                        emriMbiemriBtn.isEnabled = true
                        self.scanBtn.isHidden = true
                        self.spinningIndicator.isHidden = true
                        
                        
                        if reload {
                            UserDefaults.standard.set(code, forKey: "referenca")
                            UserDefaults.standard.set(name, forKey: "name")
                            UserDefaults.standard.set(surname, forKey: "surname")
                            UserDefaults.standard.set(birthdate, forKey: "birthdate")
                            UserDefaults.standard.set(nrPersonal, forKey: "nrpersonal")
                        }else{
                            let optionMenu = UIAlertController(title: "Kartela valide", message: "\nEmri: \(name) \(surname)\nNr.personal: \(nrPersonal)", preferredStyle: .actionSheet)
                                                       
                                                   // 2
                                                let deleteAction = UIAlertAction(title: "Mos ruaj", style: .default , handler: {action in
                                                    self.captureSession?.stopRunning()
                                                    self.previewLayer?.removeFromSuperlayer()
                                                    dismiss(animated: true)
                                                })
                            let saveAction = UIAlertAction(title: "Ruaj", style: .default, handler: {action in
                                UserDefaults.standard.set(code, forKey: "referenca")
                                UserDefaults.standard.set(name, forKey: "name")
                                UserDefaults.standard.set(surname, forKey: "surname")
                                UserDefaults.standard.set(birthdate, forKey: "birthdate")
                                UserDefaults.standard.set(nrPersonal, forKey: "nrpersonal")
                                self.captureSession?.stopRunning()
                                self.previewLayer?.removeFromSuperlayer()
                                
                            })

                            optionMenu.addAction(deleteAction)
                            optionMenu.addAction(saveAction)

                            self.present(optionMenu, animated: true, completion: nil)
                        }
                        
                        
                        self.nameLbl.text = name
                        self.surnameLbl.text = surname

                    }

                    
                    
                     } catch let parsingError {
                    print("Error", parsingError)
                   }
            }else if myResponse.statusCode == 204{
              
            }
            
        }
            task.resume()
        
    }
    var doza = "0"
    
    @IBAction func firstDoseBtn(_ sender: UIButton) {
        doza = "1"
        UserDefaults.standard.set(doza, forKey: "doza")
    }
    
    @IBAction func secondDose(_ sender: UIButton) {
        doza = "2"
        UserDefaults.standard.set(doza, forKey: "doza")
    }


    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }


    func hideError(){
        DispatchQueue.main.async {
            self.moreBtn.isHidden = true
            self.qrCodeImg.isHidden = true
            self.nameLbl.isHidden = true
            self.spinningIndicator.isHidden = true
            self.doza1Btn.isHidden = true
            self.doza2Btn.isHidden = true
            self.surnameLbl.isHidden = true
            self.firstDoseLbl.isHidden = true
            self.secondDoseLbl.isHidden = true
            self.titleLblBtn.isHidden = true
            self.scanBtn.isHidden = true
        }
    }

    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PassportViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint)
      -> UIContextMenuConfiguration? {
    
    func makeDeleteInfo() -> UIAction {
      // 1
        let removeRatingAttributes = UIMenuElement.Attributes.destructive

      // 3
      let trashImage = UIImage(systemName: "trash")
      
      // 4
      return UIAction(
        title: "Fshij informatat",
        image: trashImage,
        identifier: nil,
        attributes: removeRatingAttributes,
        handler: deleteInfo)
    }
    
    func deleteInfo(from action: UIAction){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        dismiss(animated: true)
    }
          
          func openBrowser(from action: UIAction){
              let ref = UserDefaults.standard.object(forKey: "referenca") as! String
              guard let url = URL(string: ref) else {
                   return
              }

              if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
          }
    
          func openinBrowser() -> UIAction {
              let browser = UIImage(systemName: "safari")
              
              // 4
              return UIAction(
                title: "Hape pasaporten ne browser",
                image: browser,
                identifier: nil,
                handler: openBrowser)
          }
          
    func reloadMenu() -> UIAction {
      
   
      let reloadImg = UIImage(systemName: "arrow.clockwise")
      
      // 4
      return UIAction(
        title: "Perditesoj informatat",
        image: reloadImg,
        identifier: nil,
        handler: reloadInfo)
    }
    
    func reloadInfo(from action: UIAction){
        let referenca = UserDefaults.standard.object(forKey: "referenca")
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        found(code: referenca as! String, reload: true)
    }
    
    func screenShotMenu() -> UIAction {
    let shareImg = UIImage(systemName: "square.and.arrow.up")
      
      return UIAction(
        title: "Shperndaj pasaporten",
        image: shareImg,
        identifier: nil,
        handler: screenShot)
    }
    

    func screenShot(from action: UIAction) {
        //Set the default sharing message.
            let message = "Pasaporta ime e vaksinimit"
          
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
            self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            //Set the link, message, image to share.
            if let img = img {
                let objectsToShare = [img, message] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [ UIActivity.ActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
            }
    }
    
    
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: { _ in
        let delete = makeDeleteInfo()
        let share = screenShotMenu()
        let reload = reloadMenu()
        let openinBrowser = openinBrowser()
        let children = [delete, reload, openinBrowser, share]
        return UIMenu(title: "Pasaporta e vaksinimit", children: children)
    })
  }
    
}


