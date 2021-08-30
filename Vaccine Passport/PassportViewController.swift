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
    
    @IBOutlet weak var spinningIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doza1Btn: UIButton!
    @IBOutlet weak var doza2Btn: UIButton!
    
    @IBOutlet weak var firstDoseLbl: UILabel!
    @IBOutlet weak var secondDoseLbl: UILabel!

    let userDefaults = UserDefaults.standard
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLblBtn.layer.cornerRadius = 10.0
        
        doza1Btn.layer.cornerRadius = 6.0
        doza2Btn.layer.cornerRadius = 5.0
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
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
        
        // Do any additional setup after loading the view.
        
        
    }
    
    func failed() {
        
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
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
    
    func found(code: String) {
        // Create a URLRequest for an API endpoint
    
        
    if !code.hasPrefix("https://"){
        let alert = UIAlertController(title: "QR Code i gabuar", message: "Ju lutem skanoni QR Code ne kartelen tuaj", preferredStyle: .alert)

        self.scanBtn.isHidden = true
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
        let task = URLSession.shared.dataTask(with: request) { [self](data, response, error) in
                  guard let response = response else {
                    print("Cannot found the response")
                    return
                  }
                  let myResponse = response as! HTTPURLResponse
            if myResponse.statusCode == 200 {
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    print(jsonResponse) //Response result
                    guard let jsonArray = jsonResponse as? [[String: Any]] else { return }
                    
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
                    let lastVaccination = jsonArray[jsonArray.count - 1]["date"] as! String
                    let lastVac = lastVaccination[..<lastVaccination.firstIndex(of: "T")!]
	
                    DispatchQueue.main.async {
                        doza1Btn.isEnabled = true
                        doza2Btn.isEnabled = true
                        exitIcon.isHidden = true
                        emriMbiemriBtn.isEnabled = true
                        self.scanBtn.isHidden = true
                        self.spinningIndicator.isHidden = true
                        
                        let optionMenu = UIAlertController(title: "Kartela valide", message: "\nEmri: \(name) \(surname)\nNr.personal: \(nrPersonal)", preferredStyle: .actionSheet)
                                                   
                                               // 2
                                            let deleteAction = UIAlertAction(title: "Mos ruaj", style: .default , handler: {action in
                                                self.captureSession?.stopRunning()
                                                self.previewLayer?.removeFromSuperlayer()
                                            })
                        let saveAction = UIAlertAction(title: "Ruaj", style: .default, handler: {action in
                            UserDefaults.standard.set(name, forKey: "name")
                            UserDefaults.standard.set(surname, forKey: "surname")
                            UserDefaults.standard.set(birthdate, forKey: "birthdate")
                            UserDefaults.standard.set(nrPersonal, forKey: "nrpersonal")
                            self.captureSession?.stopRunning()
                            self.previewLayer?.removeFromSuperlayer()
                            
                        })

                                               optionMenu.addAction(deleteAction)
                                               optionMenu.addAction(saveAction)

                                               // 5
                                               self.present(optionMenu, animated: true, completion: nil)
                        self.nameLbl.text = name
                        self.surnameLbl.text = surname
                        
                        
                        
                        self.firstDoseLbl.text = String(lastVac)
                    }

                    
                    
                     } catch let parsingError {
                    print("Error", parsingError)
                   }
            }else if myResponse.statusCode == 204{
              
            }
            
        }
            task.resume()
        
    }
    
    var doza = 0
    
    @IBAction func firstDoseBtn(_ sender: UIButton) {
        doza = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vacInfoView = segue.destination as? VaccineInfoViewController {
            vacInfoView.doza = self.doza
        }
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
