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

