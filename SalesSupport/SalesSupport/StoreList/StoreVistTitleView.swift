//
//  StoreVistTitleView.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/03/07.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import UIKit

class StoreVistTitleView: UIView {
    var closeHandler : ((String) -> Void)?
    
    var resendHandler : (() -> Void)?
    
    var showSetting : (() -> Void)?
    
    func createView(storeModel: StoreListViewModel!) {
        let image = #imageLiteral(resourceName: "icon_80")
        let imageView = UIImageView(image: image)
        let image1 = #imageLiteral(resourceName: "menu_history")
        let imageView1 = UIImageView(image: image1)
        let image2 = #imageLiteral(resourceName: "menu_unvisited")
        let imageView2 = UIImageView(image: image2)
        let image3 = #imageLiteral(resourceName: "menu_visited")
        let imageView3 = UIImageView(image: image3)
        let image4 = #imageLiteral(resourceName: "refresh_x1")
        let imageView4 = UIImageView(image: image4)
        let image5 = #imageLiteral(resourceName: "cog_x1")
        let imageView5 = UIImageView(image: image5)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapUserIconButton(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(imageView)
        
        imageView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(40)
        })
        
        self.addSubview(imageView1)
        imageView1.snp.makeConstraints({ (make) in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(25)
        })
        
        self.addSubview(imageView2)
        imageView2.snp.makeConstraints({ (make) in
            make.top.equalTo(imageView1.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(25)
        })
        
        self.addSubview(imageView3)
        imageView3.snp.makeConstraints({ (make) in
            make.top.equalTo(imageView2.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(25)
        })
        
        self.addSubview(imageView4)
        imageView4.snp.makeConstraints({ (make) in
            make.top.equalTo(imageView3.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(25)
        })
        
        self.addSubview(imageView5)
        imageView5.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(25)
            make.size.equalTo(40)
        })
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1;
        titleLabel.adjustsFontSizeToFitWidth = true;
        titleLabel.textAlignment = .left
        titleLabel.text = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        let titleLabel1 = UIButton()
        titleLabel1.setTitle("訪問履歴(" + String(storeModel.willEditStoreArray.count) + ")", for: .normal)
        titleLabel1.setTitleColor(SSColor.SSBlue, for: .normal)
        titleLabel1.contentHorizontalAlignment = .left
        titleLabel1.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel1.addTarget(self, action: #selector(tapWillButton), for: UIControlEvents.touchUpInside)
        let titleLabel2 = UIButton()
        titleLabel2.setTitle("未訪問(" + String(storeModel.notAccessedStoreArray.count) + ")", for: .normal)
        titleLabel2.setTitleColor(SSColor.SSBlue, for: .normal)
        titleLabel2.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel2.contentHorizontalAlignment = .left
        titleLabel2.addTarget(self, action: #selector(tapNoButton), for: UIControlEvents.touchUpInside)
        let titleLabel3 = UIButton()
        titleLabel3.setTitle("訪問ずみ(" + String(storeModel.editedStoreArray.count) + ")", for: .normal)
        titleLabel3.setTitleColor(SSColor.SSBlue, for: .normal)
        titleLabel3.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel3.contentHorizontalAlignment = .left
        titleLabel3.addTarget(self, action: #selector(tapCheckButton), for: UIControlEvents.touchUpInside)
        
        let titleLabel4 = UIButton()
        titleLabel4.setTitle("入力した情報を再送付", for: .normal)
        titleLabel4.setTitleColor(SSColor.SSBlue, for: .normal)
        titleLabel4.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel4.contentHorizontalAlignment = .left
        titleLabel4.addTarget(self, action: #selector(tapResendButton), for: UIControlEvents.touchUpInside)
        
        let titleLabel5 = UIButton()
        titleLabel5.setTitle("設定", for: .normal)
        titleLabel5.setTitleColor(SSColor.SSBlue, for: .normal)
        titleLabel5.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        titleLabel5.contentHorizontalAlignment = .left
        titleLabel5.addTarget(self, action: #selector(tapSetting), for: UIControlEvents.touchUpInside)
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.centerY.equalTo(imageView.snp.centerY)
            make.left.equalTo(imageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
        
        self.addSubview(titleLabel1)
        titleLabel1.snp.makeConstraints({ (make) in
            make.centerY.equalTo(imageView1.snp.centerY)
            make.left.equalTo(imageView1.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
        
        self.addSubview(titleLabel2)
        titleLabel2.snp.makeConstraints( { (make) in
            make.centerY.equalTo(imageView2.snp.centerY)
            make.left.equalTo(imageView2.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
        
        self.addSubview(titleLabel3)
        titleLabel3.snp.makeConstraints ({ (make) in
            make.centerY.equalTo(imageView3.snp.centerY)
            make.left.equalTo(imageView3.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
        
        self.addSubview(titleLabel4)
        titleLabel4.snp.makeConstraints ({ (make) in
            make.centerY.equalTo(imageView4.snp.centerY)
            make.left.equalTo(imageView4.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
        
        self.addSubview(titleLabel5)
        titleLabel5.snp.makeConstraints ({ (make) in
            make.centerY.equalTo(imageView5.snp.centerY)
            make.left.equalTo(imageView5.snp.right).offset(20)
            make.right.equalToSuperview().offset(20)
        })
    }
    
    @objc func tapCheckButton(){
        self.closeHandler?("check")
    }
    
    @objc func tapNoButton(){
        self.closeHandler?("no")
    }
    
    @objc func tapWillButton(){
        self.closeHandler?("will")
    }
    
    @objc func tapResendButton(){
        self.resendHandler?()
    }
    
    @objc func tapSetting(){
        self.showSetting?()
    }
    
    func setCloseHandle(handler:@escaping (String) -> Void) {
        self.closeHandler = handler
    }
    
    func setResendHandler(handler:@escaping () -> Void) {
        self.resendHandler = handler
    }
    
    func setShowSetting(handler:@escaping () -> Void) {
        self.showSetting = handler
    }

    @objc func tapUserIconButton(tapGestureRecognizer: UITapGestureRecognizer){
        
        NotificationCenter.default.post(name: NSNotification.Name(Notification.LogoutNotification), object: nil)
        self.tapWillButton()
    }
}
