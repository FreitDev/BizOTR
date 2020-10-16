//
//  SettingsViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var signoutBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signoutBtnTapped(_ sender: Any) {
        self.logoutUser()
    }
    
    // log out
    func logoutUser() {
        // call from any screen
        
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        //UserDefaults.resetStandardUserDefaults()
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLogin")
        
        // After user has successfully logged out
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "HomeAuthVC")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
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
