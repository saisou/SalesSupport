//
//  StoreDetailViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/04/23.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StoreDetailViewController: UITableViewController {
    
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var addressImage: UIImageView!
    @IBOutlet weak var phoneImage: UIImageView!
    
    @IBOutlet weak var storeNameTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var industryDetailTF: UITextField!
    @IBOutlet weak var nearStationTF: UITextField!
    @IBOutlet weak var negotiationTimeTF: UITextField!
    
    @IBOutlet weak var storeNameLine: UIView!
    @IBOutlet weak var addressLine: UIView!
    
    @IBOutlet weak var openStatusLbl: UILabel!
    @IBOutlet weak var paymentLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var resultsLbl: UILabel!
    @IBOutlet weak var ngReasonLbl: UILabel!
    
    @IBOutlet weak var openStatusSld: UISlider!
    @IBOutlet weak var paymentSld: UISlider!
    @IBOutlet weak var mobileSld: UISlider!
    @IBOutlet weak var resultsSld: UISlider!
    @IBOutlet weak var ngReasonSld: UISlider!
    
    let dateformatterDT = DateFormatter()
    let dateformatterDTS = DateFormatter()
    
    @IBOutlet weak var discussTimeBtn: UIButton!
    @IBOutlet weak var nextDateBtn: UIButton!
    var firstTouchNextDateBtn = true

    @IBOutlet weak var discussTimeDP: UIDatePicker!
    @IBOutlet weak var nextDateDP: UIDatePicker!
    
    @IBOutlet weak var calledSBtn: UISwitch!
    
    var store: StoreModel?
    
    let sliderItems = [101: ["未選択","未開店","開店３ヶ月未満","開店３ヶ月以降"],
                       102: ["未選択","未導入","3.24%未満","楽天SP","Coiney/Square","その他3.24%サービス","3.25%以上","不明・ヒアリングできず"],
                       103: ["未選択","ios所持","Android所持(iosなし）","未所持","不明・ヒアリングでいず"],
                       104: ["未選択","S","A","B","C","D","N","Z"],
                       105: ["未選択","現在利用中のもので満足","別サービスを導入したばかり","現金主義（カード需要なし）","IOSの準備ができない","決裁権がなく判断できない","その他","ヒアンリングできず"]
    ]
    
    var isNewStoreModel = false
    var isNewVisitModel = false
    
    var hideDiscussDP = true
    var hideNextDP = true
    var hideNgReasonSld = true
    
    override func viewDidLoad() {
        dateformatterDT.dateFormat = "yyyy-MM-dd HH:mm"
        dateformatterDTS.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        storeNameTF.delegate = self
        addressTF.delegate = self
        phoneTF.delegate = self
        industryDetailTF.delegate = self
        nearStationTF.delegate = self
        
        self.phoneTF.addDoneButtonToKeyboard(width: self.view.frame.size.width, myAction: #selector(self.phoneTF!.resignFirstResponder))
        self.negotiationTimeTF.addDoneButtonToKeyboard(width: self.view.frame.size.width, myAction: #selector(self.negotiationTimeTF!.resignFirstResponder))

        self.createView()
        self.initStoreComponentValue()
        self.setNavigationBar()

        if self.isNewStoreModel {
            self.title = "新店登録"
            self.storeNameTF.isEnabled = true
            self.addressTF.isEnabled = true
            self.nearStationTF.isEnabled = true
            self.reverseGeocodeToStore()
        } else {
            self.storeNameLine.isHidden = true
            self.addressLine.isHidden = true
//            self.discussTimeDP.datePickerMode = .time
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }

    func setNavigationBar() {
        let ngBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        ngBtn.addTarget(self, action: #selector(tapNgButton), for: UIControlEvents.touchUpInside)
        ngBtn.setImage(UIImage.init(named: "NG_off"), for: UIControlState.normal)
        ngBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        ngBtn.titleLabel?.textColor = UIColor.blue;
        ngBtn.widthAnchor.constraint(equalToConstant: 33.0).isActive = true
        ngBtn.heightAnchor.constraint(equalToConstant: 33.0).isActive = true
        let rightBtnItem1 = UIBarButtonItem(customView: ngBtn)
        
        let checkBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 33, height: 33))
        checkBtn.addTarget(self, action: #selector(tapCheckButton), for: UIControlEvents.touchUpInside)
        checkBtn.setImage(UIImage.init(named: "check_off"), for: UIControlState.normal)
        checkBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        checkBtn.titleLabel?.textColor = UIColor.blue;
        checkBtn.widthAnchor.constraint(equalToConstant: 33.0).isActive = true
        checkBtn.heightAnchor.constraint(equalToConstant: 33.0).isActive = true
        let rightBtnItem2 = UIBarButtonItem(customView: checkBtn)
        if self.isNewVisitModel {
            self.navigationItem.rightBarButtonItems = [rightBtnItem2]
        } else {
            self.navigationItem.rightBarButtonItems = [rightBtnItem1, rightBtnItem2]
        }
        
        if self.isNewStoreModel || self.isNewVisitModel {
            let optionsBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 28))
            optionsBtn.setTitle("キャンセル", for: .normal)
            optionsBtn.setTitleColor(SSColor.SSGrayBlack, for: .normal)
            optionsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            optionsBtn.titleLabel?.textAlignment = .right
            optionsBtn.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
            optionsBtn.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
            let leftBtnItem = UIBarButtonItem(customView: optionsBtn)
            optionsBtn.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
            self.navigationItem.leftBarButtonItem = leftBtnItem
        }
        
    }
    
    @IBAction func touchSwitchBtn(_ sender: UISwitch) {
        if sender.isOn {
            self.store?.called = "1"
        } else {
            self.store?.called = "0"
        }
    }
    
    @objc func tapNgButton(){
        closeKeyBoard()
        
        let alertController = UIAlertController(title: "入力された内容で送信しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            if self.isNewStoreModel {
                self.store?.is_new = 1
                self.store?.addNewStore(editStatus: .notAccessed)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.store?.addNewStore(editStatus: .notAccessed)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        })
        let cancelAction = UIAlertAction(title: "いいえ", style: .default, handler: {
            action in
            return
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func tapCheckButton(){
        closeKeyBoard()
        
        let alertController = UIAlertController(title: "入力された内容で送信しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            if self.isNewStoreModel {
                self.store?.is_new = 1
                self.store?.addNewStore(editStatus: .edited)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.store?.addNewStore(editStatus: .edited)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: "いいえ", style: .default, handler: {
            action in
            return
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func tapCloseButton(){
        self.closeKeyBoard()
        self.dismiss(animated: true, completion: nil)
    }
    
    func closeKeyBoard() {
        self.storeNameTF.resignFirstResponder()
        self.addressTF.resignFirstResponder()
        self.phoneTF.resignFirstResponder()
        self.industryDetailTF.resignFirstResponder()
        self.nearStationTF.resignFirstResponder()
    }
    
    func createView() {
        guard let storeType = self.store?.industry else {
            return
        }
        
        // init date button
        let date = Date()
        self.discussTimeBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
        self.nextDateBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
        
        if storeType == "飲食" {
            self.storeImage.image = #imageLiteral(resourceName: "food_icon")
        } else if storeType == "美容" {
            self.storeImage.image = #imageLiteral(resourceName: "beauty_icon")
            self.addressImage.image = #imageLiteral(resourceName: "pin-yellow")
            self.phoneImage.image = #imageLiteral(resourceName: "tel-yellow")
        } else if storeType == "その他" {
            self.storeImage.image = #imageLiteral(resourceName: "other_icon")
            self.addressImage.image = #imageLiteral(resourceName: "pin-green")
            self.phoneImage.image = #imageLiteral(resourceName: "tel-green")
        } else if storeType == "物販" {
            self.storeImage.image = #imageLiteral(resourceName: "goods_on")
            self.addressImage.image = #imageLiteral(resourceName: "pin-blue")
            self.phoneImage.image = #imageLiteral(resourceName: "tel-blue")
        } else if storeType == "不明" {
            self.storeImage.image = #imageLiteral(resourceName: "unkn_on")
            self.addressImage.image = #imageLiteral(resourceName: "pin-purple")
            self.phoneImage.image = #imageLiteral(resourceName: "tel-purple")
        }
    }
    
    func initStoreComponentValue() {
        if self.store == nil {
            return
        }

        self.store?.feedJsonProperties()

        // switch button
        if self.store?.called != nil {
            let called = self.store!.called
            self.calledSBtn.setOn(called == "1", animated: true)
        } else {
            self.store?.called = "0"
            self.calledSBtn.setOn(false, animated: true)
        }
        
        // textFiled init
        if self.store?.store_name != nil {
            self.storeNameTF.text = self.store?.store_name
        }
        if self.store?.address != nil {
            self.addressTF.text = self.store?.address
        }
        if self.store?.phone_number != nil {
            self.phoneTF.text = self.store?.phone_number
        }
        if self.store?.industry_detail != nil {
            self.industryDetailTF.text = self.store?.industry_detail
        }
        if self.store?.nearest_station != nil {
            self.nearStationTF.text = self.store?.nearest_station
        }
        if self.store?.negotiation_time != nil {
            self.negotiationTimeTF.text = String(self.store!.negotiation_time!)
        }
        
        // slider init
        if self.store?.opened_status != nil {
            let text = self.store!.opened_status!
            self.openStatusLbl.text = text
            self.openStatusSld.setValue(Float(self.sliderItems[101]!.index(of: text)!), animated: true)
        }else{
            self.store?.opened_status = self.sliderItems[101]![0]
            self.openStatusLbl.text = self.sliderItems[101]![0]
            self.openStatusSld.setValue(0, animated: false)
        }
        
        if self.store?.payment_status != nil {
            let text = self.store!.payment_status!
            self.paymentLbl.text = text
            self.paymentSld.setValue(Float(self.sliderItems[102]!.index(of: text)!), animated: true)
        }else{
            self.store?.payment_status = self.sliderItems[102]![0]
            self.paymentLbl.text = self.sliderItems[102]![0]
            self.paymentSld.setValue(0, animated: false)
        }
        
        if self.store?.mobile_terminal != nil {
            let text = self.store!.mobile_terminal!
            self.mobileLbl.text = text
            self.mobileSld.setValue(Float(self.sliderItems[103]!.index(of: text)!), animated: true)
        }else{
            self.store?.mobile_terminal = self.sliderItems[103]![0]
            self.mobileLbl.text = self.sliderItems[103]![0]
            self.mobileSld.setValue(0, animated: false)
        }
        
        if self.store?.status != nil {
            let text = self.store!.status!
            self.resultsLbl.text = text
            self.resultsSld.setValue(Float(self.sliderItems[104]!.index(of: text)!), animated: true)
            
            var ngReason = "未選択"
            if self.store!.ng_reason != nil && !self.store!.ng_reason!.isEmpty {
                ngReason = self.store!.ng_reason!
            }
            self.ngReasonLbl.text = ngReason
            self.ngReasonSld.setValue(Float(self.sliderItems[105]!.index(of: ngReason)!), animated: true)
            
            if text == "N" {
                self.hideNgReasonSld = false
            } else {
                self.store?.ng_reason = nil
            }
        }else{
            self.store?.status = "未選択"
            self.resultsLbl.text = self.sliderItems[104]![0]
            self.resultsSld.setValue(0, animated: false)
            self.ngReasonLbl.text = self.sliderItems[105]![0]
            self.ngReasonSld.setValue(0,animated: false)
        }
        
        // date picker
        if self.store?.visited_at != nil && self.store!.visited_at!.compare("2000-01-01 00:00:00", options: .numeric) == .orderedDescending {
            let date = self.dateformatterDTS.date(from: self.store!.visited_at!)
            self.discussTimeBtn.setTitle(dateformatterDT.string(from: date!), for: .normal)
            self.discussTimeDP.setDate(date!, animated: true)
        } else {
            var date = Date()
            if !isNewStoreModel && self.store!.accessedTime != TreasureDataConstant.fakeDate {
                date = self.store!.accessedTime!
            }
            self.store?.visited_at = self.dateformatterDTS.string(from: date)
            self.discussTimeBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
            self.discussTimeDP.setDate(date, animated: true)
        }
        if self.store?.next_negotiation_date != nil &&
            self.store!.next_negotiation_date!.compare("2000-01-01 00:00", options: .numeric) == .orderedDescending {
            let date = self.dateformatterDT.date(from: self.store!.next_negotiation_date!)
            self.nextDateBtn.setTitle(dateformatterDT.string(from: date!), for: .normal)
            self.nextDateBtn.setTitleColor(UIColor.blue, for: .normal)
            self.nextDateDP.setDate(date!, animated: true)
        } else {
            let date = Date()
            self.store?.next_negotiation_date = nil
            self.nextDateBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
            self.nextDateDP.setDate(date, animated: true)
        }
    }
    
    @IBAction func textChange(_ sender: UITextField) {
        if sender.tag == 201 {
            self.store?.store_name = sender.text
        } else if sender.tag == 202 {
            self.store?.address = sender.text
        } else if sender.tag == 203 {
            self.store?.phone_number = sender.text
        } else if sender.tag == 204 {
            self.store?.industry_detail = sender.text
        } else if sender.tag == 205 {
            self.store?.nearest_station = sender.text
        } else if sender.tag == 206 {
            self.store?.negotiation_time = Int(sender.text!)
        }
    }
    
    @IBAction func dateButtonClick(_ sender: UIButton) {
        if sender.tag == 201 {
            if hideDiscussDP {
                self.discussTimeDP.isHidden = false
                hideDiscussDP = false
            } else {
                self.discussTimeDP.isHidden = true
                hideDiscussDP = true
            }
        } else if sender.tag == 202 {
            if firstTouchNextDateBtn {
                self.nextDateBtn.setTitleColor(UIColor.blue, for: .normal)
            }
            if hideNextDP {
                self.nextDateDP.isHidden = false
                hideNextDP = false
            } else {
                self.nextDateDP.isHidden = true
                hideNextDP = true
            }
        }
        self.tableView.beginUpdates()
        
        self.tableView.endUpdates()
    }
    
    @IBAction func datePickerChange(_ sender: UIDatePicker) {
        let date = sender.date
        
        if sender.tag == 201 {
            self.discussTimeBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
            self.store?.visited_at = dateformatterDTS.string(from: date)
        } else if sender.tag == 202 {
            self.nextDateBtn.setTitle(dateformatterDT.string(from: date), for: .normal)
            self.store?.next_negotiation_date = dateformatterDT.string(from: date)
        }
    }
    
    @IBAction func sliderTouchInside(_ sender: UISlider) {
        if self.hideNgReasonSld && self.resultsLbl.text == "N" {
            self.hideNgReasonSld = false
            self.store?.ng_reason = "現在利用中のもので満足"
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        } else if !self.hideNgReasonSld && self.resultsLbl.text != "N" {
            self.hideNgReasonSld = true
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.store?.ng_reason = nil
        }
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        let slider = sender
        var index = Int(slider.value+0.5)
        if index >= self.sliderItems[sender.tag]!.count {
            index = self.sliderItems[sender.tag]!.count - 1
        }
        
        let textValue = self.sliderItems[sender.tag]![index]
        
        if sender.tag == 101 {
            self.openStatusLbl.text = textValue
            self.store?.opened_status = textValue
        } else if sender.tag == 102 {
            self.paymentLbl.text = textValue
            self.store?.payment_status = textValue
        } else if sender.tag == 103 {
            self.store?.mobile_terminal = textValue
            self.mobileLbl.text = textValue
        } else if sender.tag == 104 {
            self.resultsLbl.text = textValue
            self.store?.status = textValue
        } else if sender.tag == 105 {
            self.ngReasonLbl.text = textValue
            self.store?.ng_reason = textValue
        }
        
        if((slider.value + 0.5) > Float(index) && (slider.value + 0.5) < Float(index)+0.1){
            light()
        }
    }
    
    private let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    func light() {
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
    }
    
    func reverseGeocodeToStore() {
        if self.store == nil || self.store!.latitude == nil || self.store!.longitude == nil {
            return
        }
        
        let geocoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: self.store!.latitude!, longitude: self.store!.longitude!)
        
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            if error != nil {
                print("error：\(error!.localizedDescription))")
            }
            
            if let p = placemarks?[0]{
                var address = ""
                if let administrativeArea = p.administrativeArea {
                    address.append("\(administrativeArea)")
                }
                if let subAdministrativeArea = p.subAdministrativeArea {
                    address.append("\(subAdministrativeArea)")
                }
                if let locality = p.locality {
                    address.append("\(locality)")
                }
                if let thoroughfare = p.thoroughfare {
                    address.append("\(thoroughfare)")
                }
                if let subThoroughfare = p.subThoroughfare {
                    address.append("\(subThoroughfare)")
                }
                if let postalCode = p.postalCode {
                    self.store?.postalCode = postalCode
                }
                self.store?.storeAddress = address
                self.store?.address = address
                self.addressTF.text = address
            } else {
                print("No placemarks!")
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if hideDiscussDP && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else if hideNextDP && indexPath.section == 1 && indexPath.row == 6 {
            return 0
        } else if hideNgReasonSld && indexPath.section == 1 && indexPath.row == 4 {
            return 0
        } else if indexPath.section == 0 && indexPath.row == 3 {
            return 0
        } else if indexPath.section == 0 && indexPath.row == 4 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
}

extension StoreDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
