//
//  LoginViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/07.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let usernameTextField = LoginFormTextField.init()
    
    let loginBtnName = "login-btn_on"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let image = UIImage(named: "login_icon_2")
        let imageView = UIImageView(image: image!)
        self.view.addSubview(imageView)
        
        let loginLabel = UILabel()
        loginLabel.textAlignment = NSTextAlignment.center
        loginLabel.text = "ログイン"
        loginLabel.font = UIFont.boldSystemFont(ofSize: 30.0)
        loginLabel.textColor = UIColor.black
        self.view.addSubview(loginLabel)
        
        // Do any additional setup after loading the view.
        usernameTextField.font = UIFont.systemFont(ofSize: 24)
        usernameTextField.placeholder = "Email"
        var leftView = UIImageView.init(image: UIImage.init(named: "email"))
        leftView.frame = CGRect.init(x: 0, y: 0, width: 22, height: 15)
        usernameTextField.leftView = leftView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        usernameTextField.autocorrectionType = UITextAutocorrectionType.no
        self.view.addSubview(usernameTextField)
        usernameTextField.returnKeyType = .done
        usernameTextField.delegate = self
        
        let loginButton = RoundButton()
        loginButton.setImage(UIImage.init(named: loginBtnName), for: .normal)
        loginButton.addTarget(self, action: #selector(tapLoginButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginButton)
        
        loginLabel.snp_makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.height.equalTo(35)
            make.width.equalTo(200)
        }
        
        imageView.snp_makeConstraints { (make) in
            make.bottom.equalTo(loginLabel.snp_top).offset(-self.view.frame.height / 19)
            make.centerX.equalTo(self.view.snp_centerX)
            make.size.equalTo(self.view.frame.height / 7)
        }
        
        usernameTextField.snp_makeConstraints { (make) in
            make.top.equalTo(loginLabel.snp_bottom).offset(self.view.frame.height / 16);
            make.left.equalTo(self.view).offset(32);
            make.right.equalTo(self.view.snp_right).offset(-32);
            make.height.equalTo(40);
        }
        
        loginButton.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(loginButton.snp_width).dividedBy(5.2)
            make.top.equalTo(usernameTextField.snp_bottom).offset(self.view.frame.height / 16)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let userName = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier) else {
            return
        }
        self.usernameTextField.text = userName
    }
    
    @objc func tapLoginButton(){
        guard let userName = self.usernameTextField.text else {
            let alertController = UIAlertController(title: "メールを記入してください",
                                                    message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if userName.isEmpty {
            let alertController = UIAlertController(title: "メールを記入してください",
                                                    message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        if !SSValidator.isValidEmail(userName) {
            let alertController = UIAlertController(title: "メールフォーマットが正しくではありません",
                                                    message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        SSRequestManager.getLoginAuthToken(userName, {
            NotificationCenter.default.post(name: NSNotification.Name(Notification.CompleteLoginNotification), object: self)
        }) {error in
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: error,
                                                        message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                    action in
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            })
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    // 画面を自動で回転させるか
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
