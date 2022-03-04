//
//  LoginViewController.swift
//  sample01
//
//  Created by makoto sakamaki on 2022/02/04.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var result:Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ログイン"
        password.isSecureTextEntry = true
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        loginButton.isEnabled = false
        errorLabel.textColor = .red
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeNotification(notification:)), name:UITextField.textDidChangeNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNext" {
            let next = segue.destination as? ViewController
            next?.loginCustomer = self.result
        }
    }
    
    @objc func login(_ sender: UIButton) {
        var isLock = true
        var isSuccess = true
        AF.request(Setting.BASE_URL+"/api/login",method: .post,parameters: ["mail":mail.text,"password":password.text]).responseData(completionHandler: {response in
            switch response.result {
                case .success(let data):
                    do {
                        self.result = try JSONDecoder().decode(Customer.self, from: data)
                        print(self.result)
                        isLock = false
                    } catch let error {
                        print(error.localizedDescription)
                        isSuccess = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    isSuccess = false
            }
        })
        while isLock && isSuccess &&
                RunLoop.current.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {}
        if isSuccess {
            performSegue(withIdentifier: "toNext", sender: nil)
        } else {
            errorLabel.text = "アドレスかパスワードが違います"
        }
    }
    @objc func didChangeNotification(notification: Notification) {
        if mail.text?.isEmpty == true && password.text?.isEmpty == true {
            errorLabel.text = "アドレスとパスワードを入力してください"
            loginButton.isEnabled = false
            return
        } else {
            loginButton.isEnabled = true
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
