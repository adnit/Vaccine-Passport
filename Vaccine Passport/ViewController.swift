//
//  ViewController.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/27/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var loadBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let passportExists =  UserDefaults.standard.object(forKey: "nrpersonal") != nil
        if passportExists {
            DispatchQueue.main.async {
                self.loadBtn.setTitle("My passport", for: .normal)
            }
        }else{
            DispatchQueue.main.async {
                self.loadBtn.setTitle("Load passport", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        checkBtn.layer.cornerRadius = 20.0
        loadBtn.layer.cornerRadius = 20.0
        
        checkBtn.layer.shadowColor = UIColor.black.cgColor
        checkBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        checkBtn.layer.shadowRadius = 5
        checkBtn.layer.shadowOpacity = 0.3
        loadBtn.layer.shadowColor = UIColor.black.cgColor
        loadBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        loadBtn.layer.shadowRadius = 5
        loadBtn.layer.shadowOpacity = 0.3
    }


}

