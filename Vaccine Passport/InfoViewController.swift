//
//  InfoViewController.swift
//  Vaccine Passport
//
//  Created by Adnit Kamberi on 8/29/21.
//

import UIKit

class InfoViewController: UIViewController {


    @IBOutlet weak var boxView: UIView!
    @IBOutlet var blurEffectView: UIView!
    
    @IBOutlet weak var dobLbl: UILabel!
    
    @IBOutlet weak var nrPersonalLbl: UILabel!
    
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
        
        nrPersonalLbl.text = (UserDefaults.standard.object(forKey: "nrpersonal") as! String)
        dobLbl.text = (UserDefaults.standard.object(forKey: "birthdate") as! String)
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            if blurEffectView == touch.view{
                dismiss(animated: true)
            }
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
extension InfoViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint)
      -> UIContextMenuConfiguration? {
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: { _ in
        let children: [UIMenuElement] = []
        return UIMenu(title: "", children: children)
    })
  }
}
extension InfoViewController: UIGestureRecognizerDelegate {

      func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                             shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
      }
    }
