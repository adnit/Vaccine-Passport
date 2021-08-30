//
//  VaccineInfoViewController.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/29/21.
//

import UIKit

class VaccineInfoViewController: UIViewController {

    
    var doza: Int?
    @IBOutlet var blurEffectView: UIView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var manufacturerLbl: UILabel!
    @IBOutlet weak var serialNoLbl: UILabel!
    @IBOutlet weak var doctorLbl: UILabel!
    @IBOutlet weak var assistantLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        boxView.layer.cornerRadius = 11.0
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.99
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(boxView)
        
        if doza == 1 {
            titleLbl.text = "Doza 1"
            let myarray = UserDefaults.standard.object(forKey: "dose1") as? [String]
            // Optional(["Pfizer", "FG3716", "2021-08-24", "Nuk ka", "Isidora Dobratiqi", "Adem Mexhuani"])
            manufacturerLbl.text = myarray?[0] as Any as? String
            serialNoLbl.text = myarray?[1] as Any as? String
            doctorLbl.text = myarray?[4] as Any as? String
            assistantLbl.text = myarray?[5] as Any as? String
            noteLbl.text = myarray?[3] as Any as? String
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            if blurEffectView == touch.view{
                dismiss(animated: true)
            }
        }
        
        // Do any additional setup after loading the view.
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
