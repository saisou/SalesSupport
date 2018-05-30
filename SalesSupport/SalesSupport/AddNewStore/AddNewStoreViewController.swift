//
//  AddNewStoreViewController.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/7.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreLocation
class AddNewStoreViewController: UIViewController {
    // MARK: - Properties
    let viewModel = AddNewStoreViewModel()
    
    let tableView:UITableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
    
    var businessType: String?
    var completehandle :((StoreModel)->())?
    var coordinate :CLLocationCoordinate2D?
    
    var commentCell: BaseInfoEditTableViewCell?
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新店情報登録"
        //        self.navigationController?.navigationBar.barTintColor = UIColor.init(red:  42.0 / 255.0, green:  153.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.gray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BaseInfoEditTableViewCell.self, forCellReuseIdentifier: "BaseInfoEditTableViewCell")
        tableView.separatorColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        
        self.view!.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            //make.edges.equalTo(UIEdgeInsetsMake(0, 0, -(self.view!.frame.size.height / 11), 0))
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(self.view!.frame.size.height / 11))
            make.top.equalToSuperview()
        }
        
        creatFooter()
        setupNavigationBar()
        viewModel.loadViewModel()
        viewModel.store.industry = businessType
        viewModel.store.latitude = coordinate?.latitude
        viewModel.store.longitude = coordinate?.longitude
        reverseGeocode(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
        tableView.reloadData()
        tableView.setContentOffset(CGPoint(x:0, y:-30), animated: true)
    }
    
    func creatFooter() {
        
        let bottomArea = UIView()
        bottomArea.backgroundColor = UIColor.init(red:  80.0 / 255.0, green:  171.0 / 255.0, blue: 223.0 / 255.0, alpha: 1)
        self.view!.addSubview(bottomArea)
        bottomArea.snp_makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.tableView.snp_bottom)
        }
        let sendButton:UIButton = UIButton()
        sendButton.setTitle("送　信", for:.normal)
        sendButton.addTarget(self, action:#selector(tapAddNewStoreButton), for:.touchUpInside)
        bottomArea.addSubview(sendButton)
        sendButton.snp_makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(bottomArea.snp_centerX)
        }
        
        let backBtn = UIButton()
        backBtn.setTitle("キャンセル", for:.normal)
        backBtn.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
        bottomArea.addSubview(backBtn)
        backBtn.snp_makeConstraints { (make) in
            make.right.equalTo(bottomArea.snp_centerX)
            make.bottom.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }
    }
    
    func setupNavigationBar(){
        let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backBtn.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
        backBtn.setImage(UIImage.init(named: "closeIco"), for: UIControlState.normal)
        backBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        backBtn.titleLabel?.textColor = UIColor.blue;
        let rightBtnItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = rightBtnItem
    }
    
    func reverseGeocode(latitude: CLLocationDegrees ,longitude: CLLocationDegrees){
        let geocoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            //setupCurrentLocationInfo
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
                    self.viewModel.store.postalCode = postalCode
                    self.viewModel.storeInfoArray[2].data = postalCode
                }
                self.viewModel.store.storeAddress = address
                self.viewModel.storeInfoArray[1].data = address
                self.tableView.reloadData()
            } else {
                print("No placemarks!")
            }
        })
    }
    func setComplete(handle : @escaping (StoreModel)->()) {
        completehandle = handle
    }
    
    @objc func tapCloseButton(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func tapAddNewStoreButton(){
        self.view.endEditing(true)
        if self.viewModel.store.storeName == nil || self.viewModel.store.storeName!.isEmpty {
            self.viewModel.store.storeName = "店鋪名不明"
        }
        
        let alertController = UIAlertController(title: "入力された内容で送信しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            self.addNewStore()
        })
        let cancelAction = UIAlertAction(title: "いいえ", style: .default, handler: {
            action in
            return
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func addNewStore() {
        viewModel.saveNewStore()
        //        (completehandle?(viewModel.store))!
        self.dismiss(animated: true, completion: nil)
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
    
}

extension AddNewStoreViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.storeInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BaseInfoEditTableViewCell = BaseInfoEditTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "BaseInfoEditTableViewCell")
        let storeInfo = viewModel.storeInfoArray[indexPath.row]
        cell.createUI(storeInfo.dataId!, storeInfo.title!, self.businessType!)
        cell.tableView = self.tableView
        if storeInfo.data != nil{
            cell.valueTextField?.text = storeInfo.data!
        }
        
        if 6 == storeInfo.dataId!.intValue || 2 == storeInfo.dataId!.intValue {
            cell.isHidden = true
        } else if 7 == storeInfo.dataId!.intValue {
            cell.isHidden = true
            self.commentCell = cell
        }
        
        cell.setRadioBtnHandle { (text) in
            storeInfo.data = text
            switch storeInfo.dataId!.intValue {
            case 4:
                self.viewModel.store.charge = text
                break
            case 5:
                self.viewModel.store.yomi = text
                if text == "N" {
                    self.commentCell?.isHidden = false
                    self.viewModel.store.comment = self.commentCell!.valueTextView?.text
                } else {
                    self.commentCell?.isHidden = true
                    self.viewModel.store.comment = ""
                }
                break
            default: break
                
            }
            
        }
        
        cell.setDidEndEditing { (text) in
            storeInfo.data = text
            switch storeInfo.dataId!.intValue {
            case 0:
                self.viewModel.store.storeName = text
                break
            case 1:
                self.viewModel.store.storeAddress = text
                break
            case 2:
                self.viewModel.store.postalCode = text
                break
            case 3:
                self.viewModel.store.phone = text
                break
            case 7:
                self.viewModel.store.comment = text
                break
            default: break
                
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let storeInfo = viewModel.storeInfoArray[indexPath.row]
        var height = self.view.frame.size.height / 14
        switch storeInfo.dataId!.intValue {
        case 0:
            height = 1.2 * height
            break
        case 4, 5:
            height = 2.2 * height
            break
        case 1, 3:
            height = 0.8 * height
            break
        case 2, 6:
            height = 0.0
            break
        case 7:
            height = 5 * height
            break
        default:
            break
        }
        return CGFloat(height)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
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
