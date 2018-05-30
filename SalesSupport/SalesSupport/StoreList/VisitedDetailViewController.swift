//
//  VisitedDetailViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/03/08.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class VisitedDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var yenIcon: UIImageView!
    @IBOutlet weak var telIcon: UIImageView!
    @IBOutlet weak var idIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    
    @IBOutlet weak var storeAddressLbl: UITextField!
    @IBOutlet weak var storeNameLbl: UITextField!
    @IBOutlet weak var telLbl: UITextField!
    
    @IBOutlet weak var ngTitleLbl: UILabel!
    
    @IBOutlet weak var threeBtn: UIButton!
    @IBOutlet weak var fiveBtn: UIButton!
    @IBOutlet weak var sevenBtn: UIButton!
    @IBOutlet weak var unknownBtn: UIButton!
    
    @IBOutlet weak var nBtn: UIButton!
    @IBOutlet weak var dBtn: UIButton!
    @IBOutlet weak var cBtn: UIButton!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var sBtn: UIButton!
    @IBOutlet weak var zBtn: UIButton!
    
    @IBOutlet weak var ngCommentBox: UITextView!
    
    @IBOutlet weak var storeStatusBtn: UIButton!

    @IBOutlet weak var industryDetailFd: UITextField!
    @IBOutlet weak var nearestStationFd: UITextField!
    
    
    var store: StoreModel?
    var rdb1Controller = SSRadioButtonsController()
    var rdb2Controller = SSRadioButtonsController()
    
    var isNewStoreModel = false
    var isNewVisitModel = false
    var isNextStoreModel = false
    
    var edgeMoveX = CGFloat(0.0)
    var stores: [StoreModel]?
    var index: Int?
    
    let pickerTitles = [401: "店舗開店状況",
                        402: "決済導入状況",
                        403: "モバイル端末状況",
                        404: "相談時間",
                        405: "次回相談日付",
                        21: "NG理由"]

    let pickerItems = [401: ["1_未開店",
                             "2_開店３ヶ月未満",
                             "3_開店３ヶ月以降"],
                       402: ["1_未導入",
                             "2_3.24%未満",
                             "3_楽天SP",
                             "4_Coiney/Square",
                             "5_その他3.24%サービス",
                             "6_3.25%以上",
                             "7_不明・ヒアリングできず"],
                       403: ["1_ios所持",
                             "2_Android所持(iosなし）",
                             "3_未所持",
                             "4_不明・ヒアリングでいず"],
                       21: ["1_現在利用中のもので満足",
                            "2_別サービスを導入したばかり",
                            "3_現金主義（カード需要なし）",
                            "4_IOSの準備ができない",
                            "5_決裁権がなく判断できない",
                            "6_その他",
                            "7_ヒアンリングできず"]]
    
    @objc func nextStore(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            if !self.hasNext() {
                return
            }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "VisitedDetailView") as! VisitedDetailViewController
            newViewController.store = self.stores![index!+1]
            newViewController.stores = self.stores
            newViewController.index = index! + 1
            newViewController.isNextStoreModel = true
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    @objc func previousStore(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func hasNext() -> Bool {
        if self.stores == nil {
            return false
        } else if self.stores!.count == (self.index! + 1) {
            return false
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createView()
        scrollView.delegate = self
        ngCommentBox.delegate = self
        rdb1Controller.delegate = self
        rdb2Controller.delegate = self
        storeAddressLbl.delegate = self
        storeNameLbl.delegate = self
        telLbl.delegate = self
        industryDetailFd.delegate = self
        nearestStationFd.delegate = self
        if self.isNewStoreModel {
            forNewStoreUpdate()
            reverseGeocodeToStore()
        } else {
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action:#selector(nextStore(_:)))
            rightSwipe.direction = UISwipeGestureRecognizerDirection.left
            let leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(previousStore(_:)))
            leftSwipe.direction = UISwipeGestureRecognizerDirection.right
            self.scrollView.addGestureRecognizer(rightSwipe)
            self.scrollView.addGestureRecognizer(leftSwipe)
            
        }
        self.setNavigationBar()
    }
    
    func forNewStoreUpdate() {
        self.isNewStoreModel = true
        self.title = "新店情報登録"
        
        self.storeNameLbl.placeholder = "店舗名を入力"
        self.storeAddressLbl.placeholder = "住所を入力"
        self.telLbl.placeholder = "電話番号を入力"
        self.storeNameLbl.isEnabled = true
        self.storeAddressLbl.isEnabled = true
        self.telLbl.isEnabled = true
        self.industryDetailFd.isEnabled = true
        self.nearestStationFd.isEnabled = true
        
        self.telLbl.addDoneButtonToKeyboard(width: self.view.frame.size.width, myAction: #selector(self.telLbl!.resignFirstResponder))
    }
    
    func createView() {
        self.storeNameLbl.text = store?.storeName
        self.storeAddressLbl.text = store?.storeAddress
        self.telLbl.text = store?.phone
        
        ngCommentBox!.layer.borderColor = SSColor.SSBlue.cgColor;
        ngCommentBox!.layer.borderWidth = 1.0;
        ngCommentBox!.layer.cornerRadius = 5.0;
        
        if store?.industry == "飲食" {
            threeBtn.setImage(#imageLiteral(resourceName: "3%-red_on"), for: .selected)
            fiveBtn.setImage(#imageLiteral(resourceName: "5%-red_on"), for: .selected)
            sevenBtn.setImage(#imageLiteral(resourceName: "7%-red_on"), for: .selected)
            unknownBtn.setImage(#imageLiteral(resourceName: "00%-red_on"), for: .selected)
            
            nBtn.setImage(#imageLiteral(resourceName: "N-red_on"), for: .selected)
            dBtn.setImage(#imageLiteral(resourceName: "D-red_on"), for: .selected)
            cBtn.setImage(#imageLiteral(resourceName: "C-red_on"), for: .selected)
            bBtn.setImage(#imageLiteral(resourceName: "B-red_on"), for: .selected)
            aBtn.setImage(#imageLiteral(resourceName: "A-red_on"), for: .selected)
            sBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
            zBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
        } else if store?.industry == "美容" {
            self.idIcon.image = #imageLiteral(resourceName: "beauty_icon")
            self.starIcon.image = #imageLiteral(resourceName: "star-yellow")
            self.yenIcon.image = #imageLiteral(resourceName: "en-yellow")
            self.addressIcon.image = #imageLiteral(resourceName: "pin-yellow")
            self.telIcon.image = #imageLiteral(resourceName: "tel-yellow")
            threeBtn.setImage(#imageLiteral(resourceName: "3%-yellow_on"), for: .selected)
            fiveBtn.setImage(#imageLiteral(resourceName: "5%-yellow_on"), for: .selected)
            sevenBtn.setImage(#imageLiteral(resourceName: "7%-yellow_on"), for: .selected)
            unknownBtn.setImage(#imageLiteral(resourceName: "00-yellow_on"), for: .selected)
            
            nBtn.setImage(#imageLiteral(resourceName: "N-yellow_on"), for: .selected)
            dBtn.setImage(#imageLiteral(resourceName: "D-yellow_on"), for: .selected)
            cBtn.setImage(#imageLiteral(resourceName: "C-yellow_on"), for: .selected)
            bBtn.setImage(#imageLiteral(resourceName: "B-yellow_on"), for: .selected)
            aBtn.setImage(#imageLiteral(resourceName: "A-yellow_on"), for: .selected)
            sBtn.setImage(#imageLiteral(resourceName: "S-yellow_on"), for: .selected)
            zBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
        } else if store?.industry == "その他" {
            self.idIcon.image = #imageLiteral(resourceName: "other_icon")
            self.starIcon.image = #imageLiteral(resourceName: "star-green")
            self.yenIcon.image = #imageLiteral(resourceName: "en-green")
            self.addressIcon.image = #imageLiteral(resourceName: "pin-green")
            self.telIcon.image = #imageLiteral(resourceName: "tel-green")
            threeBtn.setImage(#imageLiteral(resourceName: "3%-green_on"), for: .selected)
            fiveBtn.setImage(#imageLiteral(resourceName: "5%-green_on"), for: .selected)
            sevenBtn.setImage(#imageLiteral(resourceName: "7%-green_on"), for: .selected)
            unknownBtn.setImage(#imageLiteral(resourceName: "00%-green_on"), for: .selected)
            
            nBtn.setImage(#imageLiteral(resourceName: "N-green_on"), for: .selected)
            dBtn.setImage(#imageLiteral(resourceName: "D-green_on"), for: .selected)
            cBtn.setImage(#imageLiteral(resourceName: "C-green_on"), for: .selected)
            bBtn.setImage(#imageLiteral(resourceName: "B-green_on"), for: .selected)
            aBtn.setImage(#imageLiteral(resourceName: "A-green_on"), for: .selected)
            sBtn.setImage(#imageLiteral(resourceName: "S-green_on"), for: .selected)
            zBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
        } else if store?.industry == "不明" {
            threeBtn.setImage(#imageLiteral(resourceName: "3%-red_on"), for: .selected)
            fiveBtn.setImage(#imageLiteral(resourceName: "5%-red_on"), for: .selected)
            sevenBtn.setImage(#imageLiteral(resourceName: "7%-red_on"), for: .selected)
            unknownBtn.setImage(#imageLiteral(resourceName: "00%-red_on"), for: .selected)
            
            nBtn.setImage(#imageLiteral(resourceName: "N-red_on"), for: .selected)
            dBtn.setImage(#imageLiteral(resourceName: "D-red_on"), for: .selected)
            cBtn.setImage(#imageLiteral(resourceName: "C-red_on"), for: .selected)
            bBtn.setImage(#imageLiteral(resourceName: "B-red_on"), for: .selected)
            aBtn.setImage(#imageLiteral(resourceName: "A-red_on"), for: .selected)
            sBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
            zBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
        } else if store?.industry == "物販" {
            threeBtn.setImage(#imageLiteral(resourceName: "3%-red_on"), for: .selected)
            fiveBtn.setImage(#imageLiteral(resourceName: "5%-red_on"), for: .selected)
            sevenBtn.setImage(#imageLiteral(resourceName: "7%-red_on"), for: .selected)
            unknownBtn.setImage(#imageLiteral(resourceName: "00%-red_on"), for: .selected)
            
            nBtn.setImage(#imageLiteral(resourceName: "N-red_on"), for: .selected)
            dBtn.setImage(#imageLiteral(resourceName: "D-red_on"), for: .selected)
            cBtn.setImage(#imageLiteral(resourceName: "C-red_on"), for: .selected)
            bBtn.setImage(#imageLiteral(resourceName: "B-red_on"), for: .selected)
            aBtn.setImage(#imageLiteral(resourceName: "A-red_on"), for: .selected)
            sBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
            zBtn.setImage(#imageLiteral(resourceName: "S-red_on"), for: .selected)
        }
        
        
        rdb1Controller.addButton(threeBtn)
        rdb1Controller.addButton(fiveBtn)
        rdb1Controller.addButton(sevenBtn)
        rdb1Controller.addButton(unknownBtn)
        
        
        rdb2Controller.addButton(nBtn)
        rdb2Controller.addButton(dBtn)
        rdb2Controller.addButton(cBtn)
        rdb2Controller.addButton(bBtn)
        rdb2Controller.addButton(aBtn)
        rdb2Controller.addButton(sBtn)
        rdb2Controller.addButton(zBtn)
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
        
        if self.isNextStoreModel {
            let optionsBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
            let titleStr = "訪問履歴"
            optionsBtn.setTitle(titleStr, for: .normal)
            optionsBtn.setTitleColor(SSColor.SSBlue, for: .normal)
            optionsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            optionsBtn.titleLabel?.textAlignment = .left
            optionsBtn.setImage(UIImage.init(named: "arrow"), for: UIControlState.normal)
            optionsBtn.imageView?.contentMode = .scaleAspectFit
            optionsBtn.contentHorizontalAlignment = .left
            optionsBtn.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
            optionsBtn.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            let leftBtnItem = UIBarButtonItem(customView: optionsBtn)
            optionsBtn.addTarget(self, action: #selector(tapBackButton), for: UIControlEvents.touchUpInside)
            self.navigationItem.leftBarButtonItem = leftBtnItem
        }
    }
    
    @objc func tapCheckButton(){
        closeKeyBoard()
        
        let alertController = UIAlertController(title: "入力された内容で送信しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            if self.isNewStoreModel {
                self.store?.addNewStore(editStatus: .edited)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.store?.updateStoreEditStatus(editStatus: .edited)
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
    
    @objc func tapNgButton(){
        closeKeyBoard()
        
        let alertController = UIAlertController(title: "入力された内容で送信しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            if self.isNewStoreModel {
                self.store?.addNewStore(editStatus: .notAccessed)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.store?.updateStoreEditStatus(editStatus: .notAccessed)
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
    
    @objc func tapBackButton(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func tapCloseButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func closeKeyBoard() {
        self.ngCommentBox.resignFirstResponder()
        self.storeNameLbl.resignFirstResponder()
        self.storeAddressLbl.resignFirstResponder()
        self.telLbl.resignFirstResponder()
        self.industryDetailFd.resignFirstResponder()
        self.nearestStationFd.resignFirstResponder()
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
                self.storeAddressLbl.text = address
            } else {
                print("No placemarks!")
            }
        })
        
    }
    
    @IBAction func setDatePicker(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "commonDatePicker") as! CommonDatePickerViewController
        
        var yi: CGFloat = 0
        if !self.isNewStoreModel {
            yi = -60
        }
        
        var pickerMode = UIDatePickerMode.dateAndTime
        if sender.tag == 405 {
            pickerMode = UIDatePickerMode.date
        }
        
        newViewController.showPickerWithY(mainView: self, pickerMode: pickerMode, yIndex: yi, title: self.pickerTitles[sender.tag]!) { (date) in
            if sender.tag == 404 {
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
                let accessedTime = dateformatter.string(from: date)
                sender.setTitle(accessedTime, for: .normal)
                let dateformatter2 = DateFormatter()
                dateformatter2.dateFormat = "yyyy-MM-dd HH:mm"
                self.store?.visited_at = dateformatter2.string(from: date)
                self.store?.negotiation_time = Int(date.timeIntervalSince1970)
            } else if sender.tag == 405 {
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd"
                let nextDate = dateformatter.string(from: date)
                sender.setTitle(nextDate, for: .normal)
                self.store?.next_negotiation_date = nextDate
            }
        }
    }
    
    
    @IBAction func setViewByPicker(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "commonStringPicker") as! CommonStringPickerViewController
        
        var yi: CGFloat = 0
        if !self.isNewStoreModel {
            yi = -60
        }
        
        newViewController.showPickerWithY(mainView: self, yIndex: yi, title: self.pickerTitles[sender.tag]!,items: self.pickerItems[sender.tag]!) { (item) in
            if sender.tag == 21 {
                self.ngCommentBox.text = item
                self.store?.comment = item
            } else {
                sender.setTitle(item, for: .normal)
                if sender.tag == 401 {
                    self.store?.opened_status = item
                } else if sender.tag == 402 {
                    self.store?.payment_status = item
                } else if sender.tag == 403 {
                    self.store?.mobile_terminal = item
                }
            }
        }
        
    }
    
}

extension VisitedDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollView!.setContentOffset(CGPoint(x:0, y:scrollView!.frame.size.height/2), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.store?.comment = textView.text
        self.scrollView!.setContentOffset(CGPoint(x:0, y:-30), animated: true)
    }
}

extension VisitedDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.closeKeyBoard()
    }
}

extension VisitedDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 101:
            self.store?.storeName = textField.text
            break
        case 102:
            self.store?.storeAddress = textField.text
            break
        case 103:
            self.store?.phone = textField.text
            break
        case 104:
            self.store?.industry_detail = textField.text
            break
        case 105:
            self.store?.nearest_station = textField.text
            break
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension VisitedDetailViewController: SSRadioButtonControllerDelegate {
    func didSelectButton(selectedButton: UIButton?) {
        self.ngCommentBox.resignFirstResponder()
        guard let selectedButton = selectedButton else {
            return
        }
        switch selectedButton.tag {
        case 11:
            store?.charge = "3"
            break
        case 12:
            store?.charge = "5"
            break
        case 13:
            store?.charge = "7"
            break
        case 14:
            store?.charge = "0"
            break
        case 21:
            store?.yomi = "N"
            self.ngCommentBox.isHidden = false
            self.ngTitleLbl.isHidden = false
            break
        case 22:
            store?.yomi = "D"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        case 23:
            store?.yomi = "C"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        case 24:
            store?.yomi = "B"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        case 25:
            store?.yomi = "A"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        case 26:
            store?.yomi = "S"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        case 27:
            store?.yomi = "Z"
            self.ngCommentBox.isHidden = true
            self.ngTitleLbl.isHidden = true
            break
        default:
            break
        }
    }
}

