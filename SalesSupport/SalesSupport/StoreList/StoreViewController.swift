//
//  StoreViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/3/4.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import SVProgressHUD

private enum ListType: Int {
    case willEdit
    case edited
    case notAccessed
}

class StoreViewController: UIViewController,UIGestureRecognizerDelegate {

    let tableView = UITableView.init()
    let viewModel = StoreListViewModel.init()
    var storesForShow = [StoreModel]()
    
    let visitButton:TabButton = TabButton()
    let newStoreListButton:TabButton = TabButton()
    
    let newStoreBtnImg = "ons-tab_pin_off"
    let visitListBtnImg = "ons-tab_pen_on"
    
    let cbController = SSCheckBoxesController()
    let ngController = SSCheckBoxesController()
    let wlController = SSCheckBoxesController()
    var showCells = [StoreTableViewCell]()
    var isCheckBoxesModel = false
    
    var toggleTitleView : StoreVistTitleView?
    var blackTransparentView : UIView?
    
    var returnBar : UIView?
    
    private var listType = ListType.willEdit
    
    var deleteIndex : Int?
    
    var tempStore : StoreModel?
    var tempStoreForRollback : StoreModel?
    var sendVisitTimer : Timer?
    
    var footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
    var footerButton = UIButton()
    var needCleanSearchModels = true
    let loadingView = UIActivityIndicatorView()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var token : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector:#selector(logoutNotification(notification:)),
                                               name: NSNotification.Name(rawValue: Notification.LogoutNotification), object: nil)
        visitButton.setTitle("訪問履歴", for:.normal)
        visitButton.backgroundColor = UIColor.white
        visitButton.setTitleColor(UIColor.black, for: .normal)
        visitButton.titleLabel?.textAlignment = .center
        visitButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        visitButton.frame = CGRect.init(x: 0, y: 0, width: 177, height: 65)
        visitButton.setImage(UIImage.init(named: visitListBtnImg), for: UIControlState.normal)
        visitButton.imageView?.contentMode = .scaleAspectFit
        visitButton.centerVertically()
        
        newStoreListButton.setTitle("新店情報", for:.normal)
        newStoreListButton.backgroundColor = UIColor.white
        newStoreListButton.setTitleColor(UIColor.SSGray, for: .normal)
        newStoreListButton.titleLabel?.textAlignment = .center
        newStoreListButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        newStoreListButton.frame = CGRect.init(x: 0, y: 0, width: 177, height: 65)
        newStoreListButton.setImage(UIImage.init(named: newStoreBtnImg), for: UIControlState.normal)
        newStoreListButton.imageView?.contentMode = .scaleAspectFit
        newStoreListButton.centerVertically()
        newStoreListButton.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(newStoreListButton)
        self.view.addSubview(visitButton)
        //Token取得
        post(url: "http://ec2-52-197-219-9.ap-northeast-1.compute.amazonaws.com:8000/user/auth/", parameters: ["username": "user1", "password": "user1_password"])
        
        newStoreListButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(visitButton.snp.right)
            make.width.equalTo(visitButton)
            make.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
        visitButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(64)
            make.bottom.equalToSuperview()
        }
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.setValue("キャンセル", forKey: "cancelButtonText")
        self.searchController.searchBar.placeholder = "店鋪名を検索"
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.text = ""
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        tableView.tableHeaderView = self.searchController.searchBar
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StoreTableViewCell.self, forCellReuseIdentifier: "StoreTableViewCell")
        tableView.allowsMultipleSelectionDuringEditing = false
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(newStoreListButton.snp.top)
        }

        self.viewModel.loadWillEditStoreModel()
        self.viewModel.loadEditedStoreModel()
        self.tableView.reloadData()
        
        self.cbController.delegate = self
        self.ngController.delegate = self
        self.wlController.delegate = self
    
        for store in viewModel.editedStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.cbController.addButton(checkBox)
        }
        
        for store in viewModel.willEditStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.wlController.addButton(checkBox)
        }
        
        for store in viewModel.notAccessedStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.ngController.addButton(checkBox)
        }

        initTableviewFooter()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.refreshTableViewAndData()
        self.setupNavigationBar()
        self.needCleanSearchModels = true
        super.viewDidAppear(animated)
    }
    
    func initTableviewFooter() {
        self.footerView.backgroundColor = UIColor.white
        self.tableView.tableFooterView = self.footerView
        
        self.loadingView.hidesWhenStopped = true
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.loadingView.isHidden = true
        self.loadingView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0);
        self.footerView.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.center.equalToSuperview()
        }
        
        self.footerButton.contentHorizontalAlignment = .center
        self.footerButton.setTitle("サーバに問い合わせる", for: .normal)
        self.footerButton.setTitleColor(UIColor.SSBlue, for: .normal)
        self.footerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.footerButton.addTarget(self, action: #selector(searchStores), for: UIControlEvents.touchUpInside)
        self.footerView.addSubview(self.footerButton)
        self.footerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
            make.width.equalTo(300)
            make.height.equalTo(24)
        }
        
        self.footerView.isHidden = true
    }
    
    func setupNavigationBar(){
        self.navigationController?.navigationBar.isTranslucent = false

        if self.isCheckBoxesModel {
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
            self.navigationItem.rightBarButtonItems = [rightBtnItem1, rightBtnItem2]
            
            let optionsBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 28))
            let titleStr = String(self.wlController.selectedButtons()!.count)
            optionsBtn.setTitle(titleStr, for: .normal)
            optionsBtn.setTitleColor(SSColor.SSGrayBlack, for: .normal)
            optionsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 26)
            optionsBtn.titleLabel?.textAlignment = .right
            optionsBtn.setImage(UIImage.init(named: "arrow"), for: UIControlState.normal)
            optionsBtn.imageView?.contentMode = .scaleAspectFit
            optionsBtn.widthAnchor.constraint(equalToConstant: 54.0).isActive = true
            optionsBtn.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
            let leftBtnItem = UIBarButtonItem(customView: optionsBtn)
            optionsBtn.addTarget(self, action: #selector(releaseCheckBoxMode), for: UIControlEvents.touchUpInside)
            self.navigationItem.leftBarButtonItem = leftBtnItem
            
            self.title = ""
        } else {
            let optionsBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
            optionsBtn.setImage(UIImage.init(named: "options"), for: UIControlState.normal)
            optionsBtn.widthAnchor.constraint(equalToConstant: 38.0).isActive = true
            optionsBtn.heightAnchor.constraint(equalToConstant: 38.0).isActive = true
            optionsBtn.addTarget(self, action: #selector(showTitleView), for: UIControlEvents.touchUpInside)
            let leftBtnItem = UIBarButtonItem(customView: optionsBtn)
            self.navigationItem.leftBarButtonItem = leftBtnItem
            self.navigationItem.rightBarButtonItems = nil
            
            switch self.listType {
            case .willEdit:
                self.title = "訪問履歴(" + String(self.viewModel.willEditStoreArray.count) + ")"
                break
            case .edited:
                self.title = "訪問済み(" + String(self.viewModel.editedStoreArray.count) + ")"
                break
            case .notAccessed:
                self.title = "未訪問(" + String(self.viewModel.notAccessedStoreArray.count) + ")"
                break
            default: break
                
            }
            
            
        }
    }
    
    
    
    @objc func tapCloseButton() {
        self.searchController.isActive = false
        self.dismiss(animated: false, completion: nil)
    }

    @objc func tapCheckButton() {
        SVProgressHUD.setBackgroundColor(UIColor.SSlightGray)
        SVProgressHUD.show(withStatus: "送信中")
        
        DispatchQueue(label: "sendAccess").async {
            for btn in self.wlController.selectedButtons()! {
                if let sb = btn as? VisitCheckBox {
                    sb.store!.updateStoreEditStatus(editStatus: .edited)
                }
            }
            DispatchQueue.main.async {
                self.releaseCheckBoxMode()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func tapNgButton(){
        SVProgressHUD.setBackgroundColor(UIColor.SSlightGray)
        SVProgressHUD.show(withStatus: "送信中")
        DispatchQueue(label: "sendAccess").async {
            for btn in self.wlController.selectedButtons()! {
                if let sb = btn as? VisitCheckBox {
                    sb.store!.updateStoreEditStatus(editStatus: .notAccessed)
                }
            }
            DispatchQueue.main.async {
                self.releaseCheckBoxMode()
                SVProgressHUD.dismiss()
                // tableview reload
            }
        }
    }
    
    @objc func releaseCheckBoxMode() {
        self.isCheckBoxesModel = false
        self.footerView.isHidden = false
        for btn in self.cbController.buttonsArray {
            btn.isSelected = false
            btn.setImage(UIImage.init(named: "food_icon"), for: .normal)
        }
        for cell in self.showCells {
            cell.disableSwipeModel = false
        }
        self.refreshTableViewAndData()
        self.setupNavigationBar()
    }
    
    @objc func tapReturnBtn(){
        if self.tempStoreForRollback != nil {
            self.tempStoreForRollback!.backToStatus()
            self.tempStoreForRollback = nil
            self.tempStore = nil
            self.sendVisitTimer?.invalidate()
            self.sendVisitTimer = nil
            self.refreshTableViewAndData()
            self.setupNavigationBar()
            self.closeReturnBar()
        }
    }
    
    func showReturnBar(title: String) {
        if self.returnBar != nil {
            self.returnBar!.removeFromSuperview()
            self.returnBar = nil
        }
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        self.returnBar = UIView.init(frame: CGRect(x:0, y: 0, width:screenWidth, height:40))
        self.returnBar?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(returnBar!)
        self.returnBar!.snp.makeConstraints { (make) in
            make.bottom.equalTo(newStoreListButton.snp.top)
            make.height.equalTo(40)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let textlbl = UILabel()
        textlbl.text = title + "に移動しました"
        textlbl.textColor = UIColor.white
        textlbl.font = UIFont.systemFont(ofSize: 22)
        textlbl.textAlignment = .center
        self.returnBar!.addSubview(textlbl)
        textlbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.width.equalTo(230)
        }
        
        let returnBtn = UIButton()
        returnBtn.setTitle("元に戻す", for: .normal)
        returnBtn.setTitleColor(UIColor.white, for: .normal)
        returnBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        returnBtn.contentVerticalAlignment = .center
        returnBtn.addTarget(self, action: #selector(tapReturnBtn), for: UIControlEvents.touchUpInside)

        self.returnBar!.addSubview(returnBtn)
        returnBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(textlbl.snp.right).offset(20)
        }
    }
    
    func closeReturnBar() {
        if self.returnBar == nil {
            return
        }
        self.returnBar!.removeFromSuperview()
        self.returnBar = nil
    }
    
    @objc func showTitleView() {
        self.needCleanSearchModels = false
        self.searchController.isActive = false

        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let titleWidth = screenWidth - 75
        let screenHeight = screenSize.height
        
        let currentWindow = UIApplication.shared.keyWindow
        self.toggleTitleView = StoreVistTitleView.init(frame: CGRect(x:-titleWidth, y: 0, width:titleWidth, height:screenHeight))
        self.toggleTitleView!.backgroundColor = UIColor.white
        
        self.blackTransparentView = StoreVistTitleView.init(frame: CGRect(x:0, y: 0, width:screenWidth, height:screenHeight))
        self.blackTransparentView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.toggleTitleView?.setResendHandler(handler: {
            SVProgressHUD.setBackgroundColor(UIColor.SSlightGray)
            SVProgressHUD.show(withStatus: "送信中")

            DispatchQueue(label: "resend").async {
                for store in self.viewModel.editedStoreArray {
                    store.sendVisitInfo()
                }
                for store in self.viewModel.notAccessedStoreArray {
                    store.sendVisitInfo()
                }
                DispatchQueue.main.async {
                    self.closeTitleView()
                    SVProgressHUD.dismiss()
                }
            }
            
        })
        
        self.toggleTitleView?.setShowSetting(handler: {
            self.needCleanSearchModels = true
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let titleWidth = screenWidth - 75
            
            if self.toggleTitleView != nil {
                UIView.animate(withDuration: 0.3, animations: {
                    self.blackTransparentView?.removeFromSuperview()
                    self.blackTransparentView = nil
                    self.toggleTitleView!.createView(storeModel: self.viewModel)
                    var fabricTopFrame = self.toggleTitleView!.frame
                    fabricTopFrame.origin.x = -titleWidth
                    self.toggleTitleView!.frame = fabricTopFrame
                }) { (finished: Bool) in
                    self.toggleTitleView?.removeFromSuperview()
                    self.toggleTitleView = nil
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingView")
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            
        })
        
        self.toggleTitleView?.setCloseHandle(handler: { (text) in
            UIView.animate(withDuration: 0.3, animations: {
                self.blackTransparentView?.removeFromSuperview()
                self.blackTransparentView = nil
                self.toggleTitleView!.createView(storeModel: self.viewModel)
                var fabricTopFrame = self.toggleTitleView!.frame
                fabricTopFrame.origin.x = -titleWidth
                self.toggleTitleView!.frame = fabricTopFrame
            }) { (finished: Bool) in
                self.toggleTitleView?.removeFromSuperview()
                self.toggleTitleView = nil
            }
            
            if text == "will" {
                self.listType = ListType.willEdit
            } else if text == "no" {
                self.listType = ListType.notAccessed
            } else if text == "check" {
                self.listType = ListType.edited
            }
            
            self.needCleanSearchModels = true
            self.refreshTableViewAndData()
            self.setupNavigationBar()
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(StoreViewController.closeTitleView))
        tap.delegate = self
        self.blackTransparentView?.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.1, animations: {
            currentWindow?.addSubview(self.blackTransparentView!)
            currentWindow?.bringSubview(toFront: self.blackTransparentView!)
            currentWindow?.addSubview(self.toggleTitleView!)
            currentWindow?.bringSubview(toFront: self.toggleTitleView!)
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.3, animations: {
                self.toggleTitleView!.createView(storeModel: self.viewModel)
                var fabricTopFrame = self.toggleTitleView!.frame
                fabricTopFrame.origin.x = 0
                self.toggleTitleView!.frame = fabricTopFrame
            })
        }

    }
    
    @objc func closeTitleView() {
        self.needCleanSearchModels = true

        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let titleWidth = screenWidth - 75

        if self.toggleTitleView != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.blackTransparentView?.removeFromSuperview()
                self.blackTransparentView = nil
                self.toggleTitleView!.createView(storeModel: self.viewModel)
                var fabricTopFrame = self.toggleTitleView!.frame
                fabricTopFrame.origin.x = -titleWidth
                self.toggleTitleView!.frame = fabricTopFrame
            }) { (finished: Bool) in
                self.toggleTitleView?.removeFromSuperview()
                self.toggleTitleView = nil
            }
        }
    }
    
    func refreshTableViewAndData() {
        self.viewModel.reloadEditedStoreModel()
        self.viewModel.reloadWillEditStoreModel()
        self.viewModel.reloadNotAccessedStoreModel()
        self.cbController.buttonsArray = [UIButton]()
        self.wlController.buttonsArray = [UIButton]()
        self.ngController.buttonsArray = [UIButton]()
        for store in viewModel.editedStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.cbController.addButton(checkBox)
        }
        
        for store in viewModel.willEditStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.wlController.addButton(checkBox)
        }
        
        for store in viewModel.notAccessedStoreArray {
            let checkBox = VisitCheckBox()
            checkBox.store = store
            if store.industry == "飲食" {
                checkBox.setImage(#imageLiteral(resourceName: "food_on"), for: .normal)
            } else if store.industry == "美容" {
                checkBox.setImage(#imageLiteral(resourceName: "beauty_icon"), for: .normal)
            } else if store.industry == "その他" {
                checkBox.setImage(#imageLiteral(resourceName: "other_icon"), for: .normal)
            } else if store.industry == "物販" {
                checkBox.setImage(#imageLiteral(resourceName: "goods_on"), for: .normal)
            } else if store.industry == "不明" {
                checkBox.setImage(#imageLiteral(resourceName: "unkn_on"), for: .normal)
            }
            
            self.ngController.addButton(checkBox)
        }
        
        if self.listType == .willEdit {
            self.storesForShow = viewModel.willEditStoreArray
        } else if self.listType == .edited {
            self.storesForShow = viewModel.editedStoreArray
        } else if self.listType == .notAccessed {
            self.storesForShow = viewModel.notAccessedStoreArray
        }
        
        guard let seachText = self.searchController.searchBar.text else {
            self.addFilterAndReload(searchText: "")
            return
        }
        self.addFilterAndReload(searchText: seachText)
        
    }
    
    func sendVisitWithDelay(store: StoreModel) {
        if self.tempStore != nil {
            print("send store visit \(self.tempStore!.storeName!)")
            self.tempStore!.sendVisitInfo()
        }
        self.tempStore = store
        
        if self.sendVisitTimer != nil {
            self.sendVisitTimer?.invalidate()
            self.sendVisitTimer = nil
        }
        self.sendVisitTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: false, block: { (timer) in
            if self.tempStore != nil {
                print("send store visit \(self.tempStore!.storeName!)")
                self.tempStore!.sendVisitInfo()
                self.tempStore = nil
                self.tempStoreForRollback = nil
            }
            self.closeReturnBar()
        })
    }
    
    @objc func searchStores() {
        self.footerButton.isHidden = true
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        SSRequestManager.searchStores(self.searchController.searchBar.text!) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                print("Failed get store access info from server.")
                return
            }
            
            let json = JSON(data)
            NSLog("getJsonFileuser_id: \(json)")
            
            guard let jsons = json.dictionaryValue["results"]?.array else {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                return
            }
            if jsons.count == 0 {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedObectContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "ExsitsStore", in: managedObectContext)
            for sjs in jsons {
                let storeJson = StoreModel.deserialize(from: sjs.rawString())
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
                let str = String.init(format:"storeId == '%@'", storeJson!.store_id!)
                fetchRequest.predicate = NSPredicate.init(format: str)
                do {
                    let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                    if fetchedResults != nil && fetchedResults!.count > 0 {
                        continue
                    }
                } catch  {
                    fatalError("get store failed")
                }
                
                let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
                storeManagedObject.setValue(storeJson!.store_id, forKey: "storeId")
                storeManagedObject.setValue(storeJson!.store_name, forKey: "storeName")
                storeManagedObject.setValue(storeJson!.industry, forKey: "storeIndustry")
                storeManagedObject.setValue(storeJson!.address, forKey: "storeAddress")
                storeManagedObject.setValue(storeJson!.phone_number, forKey: "phone_number")
                storeManagedObject.setValue(storeJson!.industry, forKey: "industry")
                storeManagedObject.setValue(storeJson!.industry_detail, forKey: "industry_detail")
                storeManagedObject.setValue(storeJson!.payment_status, forKey: "payment_status")
                storeManagedObject.setValue(storeJson!.mobile_terminal, forKey: "mobile_terminal")
                storeManagedObject.setValue(storeJson!.nearest_station, forKey: "nearest_station")
                storeManagedObject.setValue(storeJson!.opened_status, forKey: "opened_status")
                storeManagedObject.setValue(storeJson!.userId, forKey: "userId")
                storeManagedObject.setValue(storeJson!.latitude, forKey: "latitude")
                storeManagedObject.setValue(storeJson!.longitude, forKey: "longitude")
                storeManagedObject.setValue("", forKey: "comment")
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date1 = TreasureDataConstant.fakeDate
                storeJson!.minDatetime = dateformatter.string(from: date1)
                storeManagedObject.setValue(date1, forKey: "accessedTime")
                storeManagedObject.setValue(storeJson!.minDatetime, forKey: "minDatetime")
                storeManagedObject.setValue(true, forKey: "accessFlag")
                
            }
            
            do {
                try managedObectContext.save()
                DispatchQueue.main.async {
                    self.refreshTableViewAndData()
                    self.setupNavigationBar()
                    self.loadingView.stopAnimating()
                    self.loadingView.isHidden = true
                    self.footerButton.isHidden = false
                }
            } catch  {
                fatalError("保存失敗")
            }
        }
    }
    
    @objc func finishLoading() {
        self.footerButton.isHidden = true
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        let urlStr = "http://ec2-52-197-219-9.ap-northeast-1.compute.amazonaws.com:8000/api/sales_support/stores/?store_name=" + self.searchController.searchBar.text!
        let strencode = urlStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: strencode)
        var request = URLRequest(url: url!)
        let token = "JWT " + self.token!
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                print("Failed get store access info from server. url:\(urlStr)")
                return
            }

            let json = JSON(data)
            NSLog("getJsonFileuser_id: \(json)")

            guard let jsons = json.dictionaryValue["results"]?.array else {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                return
            }
            if jsons.count == 0 {
                DispatchQueue.main.async {
                    self.noResultHandle()
                }
                return
            }

            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            let managedObectContext = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "ExsitsStore", in: managedObectContext)
            for sjs in jsons {
                let storeJson = StoreModel.deserialize(from: sjs.rawString())

                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
                let str = String.init(format:"storeId == '%@'", storeJson!.storeId!)
                fetchRequest.predicate = NSPredicate.init(format: str)
                do {
                    let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                    if fetchedResults != nil && fetchedResults!.count > 0 {
                        continue
                    }
                } catch  {
                    fatalError("get store failed")
                }

                let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
                storeManagedObject.setValue(storeJson!.storeId, forKey: "storeId")
                storeManagedObject.setValue(storeJson!.storeName, forKey: "storeName")
                storeManagedObject.setValue(storeJson!.industry, forKey: "storeIndustry")
                storeManagedObject.setValue(storeJson!.storeAddress, forKey: "storeAddress")
                storeManagedObject.setValue(storeJson!.userId, forKey: "userId")
                storeManagedObject.setValue(storeJson!.latitude, forKey: "latitude")
                storeManagedObject.setValue(storeJson!.longitude, forKey: "longitude")
                storeManagedObject.setValue("", forKey: "comment")
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date1 = TreasureDataConstant.fakeDate
                storeJson!.minDatetime = dateformatter.string(from: date1)
                storeManagedObject.setValue(date1, forKey: "accessedTime")
                storeManagedObject.setValue(storeJson!.minDatetime, forKey: "minDatetime")
                storeManagedObject.setValue(true, forKey: "accessFlag")

            }

            do {
                try managedObectContext.save()
                DispatchQueue.main.async {
                    self.refreshTableViewAndData()
                    self.setupNavigationBar()
                    self.loadingView.stopAnimating()
                    self.loadingView.isHidden = true
                    self.footerButton.isHidden = false
                }
            } catch  {
                fatalError("保存失敗")
            }

        }).resume()
    }
    
    func noResultHandle() {
        self.loadingView.stopAnimating()
        self.loadingView.isHidden = true
        
        if self.searchController.isActive {
            self.searchController.isActive = false
        }
        let alertController = UIAlertController(title: "店鋪情報が見つかりませんでした。\n新規情報登録に移動しますか？",
                                                message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default, handler: {
            action in
            self.tapCloseButton()
            
        })
        let cancelAction = UIAlertAction(title: "いいえ", style: .default, handler: {
            action in
            self.footerButton.isHidden = false
            return
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func post(url urlString: String, parameters: [String: Any]) {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let boundary = "---------------------------\(uniqueId)"
        
        // Headerの設定
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Bodyの設定
        var body = Data()
        var bodyText = String()
        
        for element in parameters {
            switch element.value {
            case let image as UIImage:
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\"; filename=\"\(element.key).jpg\"\r\n"
                bodyText += "Content-Type: image/jpeg\r\n\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(imageData!)
            case let int as Int:
                bodyText = String()
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(String(int).data(using: String.Encoding.utf8)!)
            case let string as String:
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(string.data(using: String.Encoding.utf8)!)
            default:
                break
            }
        }
        
        // Footerの設定
        var footerText = String()
        footerText += "\r\n"
        footerText += "\r\n--\(boundary)--\r\n"
        
        body.append(footerText.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response {
                print(response)
                
                do {
                    let json = JSON(data)
                    NSLog("getJsonFileuser_id: \(json)")
                    
                    let jsons = json.array
                    
                    self.token = json["token"].stringValue
                    
                    print(json["token"])
                    
                    
                } catch {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        
        task.resume()
    }
}
extension StoreViewController: UITableViewDelegate, UITableViewDataSource {
    //datasource
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storesForShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row + 1 == self.storesForShow.count {
            print("do something")
        }
        
        if indexPath.row == 0 {
            self.showCells.removeAll()
        }
        let cell:StoreTableViewCell = StoreTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "StoreTableViewCell")
        let store = self.storesForShow[indexPath.row]
        var checkBox :VisitCheckBox?
        switch self.listType {
        case .willEdit:
            do{
                cell.swipeDelegate = self
                for cb in self.wlController.buttonsArray {
                    if let cb = cb as? VisitCheckBox {
                        if cb.store?.storeId == self.storesForShow[indexPath.row].storeId {
                            checkBox = cb
                            break
                        }
                    }
                }
//                checkBox = self.wlController.buttonsArray[indexPath.row] as? VisitCheckBox
            }
        case .notAccessed:
            do{
                for cb in self.ngController.buttonsArray {
                    if let cb = cb as? VisitCheckBox {
                        if cb.store?.storeId == self.storesForShow[indexPath.row].storeId {
                            checkBox = cb
                            break
                        }
                    }
                }
//                checkBox = self.ngController.buttonsArray[indexPath.row] as? VisitCheckBox
                cell.disableSwipeModel = true
            }
        case .edited:
            do{
                for cb in self.cbController.buttonsArray {
                    if let cb = cb as? VisitCheckBox {
                        if cb.store?.storeId == self.storesForShow[indexPath.row].storeId {
                            checkBox = cb
                            break
                        }
                    }
                }
//                checkBox = self.cbController.buttonsArray[indexPath.row] as? VisitCheckBox
                cell.disableSwipeModel = true
            }
        }
        
        if self.isCheckBoxesModel {
            cell.disableSwipeModel = true
        }
        cell.titleLabel.text = store.storeName
        cell.addressLabel.text = store.storeAddress
        cell.createView(checkBox!)
        self.showCells.append(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.deleteIndex == indexPath.row {
            self.deleteIndex = nil
            return 0
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if !self.isCheckBoxesModel {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "StoreDetailView") as! StoreDetailViewController
            if self.listType == .willEdit {
                newViewController.store = self.storesForShow[indexPath.row]
            } else if self.listType == .edited {
                newViewController.store = self.storesForShow[indexPath.row]
            } else if self.listType == .notAccessed {
                newViewController.store = self.storesForShow[indexPath.row]
            }
            newViewController.store?.feedJsonProperties()
            newViewController.store?.feedCoreProperties()
            
            self.needCleanSearchModels = false
            self.searchController.isActive = false
            
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }
    }
}

extension StoreViewController: SSCheckBoxesControllerDelegate {
    func didSelectButton(selectedButton: UIButton?) {
        if self.wlController.selectedButtons()!.count > 0 && !isCheckBoxesModel {
            isCheckBoxesModel = true
            self.footerView.isHidden = true
            for btn in self.wlController.buttonsArray {
                btn.setImage(UIImage.init(named: "r_btn_off"), for: .normal)
                btn.setImage(UIImage.init(named: "r_btn_on"), for: .selected)
            }
            for cell in self.showCells {
                cell.disableSwipeModel = true
            }
        }
        self.setupNavigationBar()
    }
}

extension StoreViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView!, leftFastSwipeAt indexPath: IndexPath!) {
        if let delIndex = indexPath {
            self.storesForShow.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.endUpdates()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                let store = self.viewModel.willEditStoreArray[indexPath.row]
                self.tempStoreForRollback = store.copyForRollback()
                store.updateStoreEditStatusCoreDB(editStatus: .notAccessed)
                self.showReturnBar(title: "未訪問")
                self.sendVisitWithDelay(store: store)
                self.refreshTableViewAndData()
                self.setupNavigationBar()
            })
        }

    }
    
    func tableView(_ tableView: UITableView!, rightFastSwipeAt indexPath: IndexPath!) {
        if let delIndex = indexPath {
            self.storesForShow.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            self.tableView.endUpdates()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                let store = self.viewModel.willEditStoreArray[indexPath.row]
                self.tempStoreForRollback = store.copyForRollback()
                store.updateStoreEditStatusCoreDB(editStatus: .edited)
                self.showReturnBar(title: "訪問済み")
                self.sendVisitWithDelay(store: store)
                self.refreshTableViewAndData()
                self.setupNavigationBar()
            })
        }
    }
    
    func tableView(_ tableView: UITableView!, styleOfSwipeButtonForRowAt indexPath: IndexPath!) -> SwipeTableCellStyle {
        return SwipeTableCellStyle.both
    }
    
    func tableView(_ tableView: UITableView!, leftSwipeButtonsAt indexPath: IndexPath!) -> [SwipeButton]! {
        if self.listType == .willEdit && !self.isCheckBoxesModel {
            let btn = SwipeButton.createSwipeButton(with: #imageLiteral(resourceName: "visited_02"), backgroundColor: UIColor.SSBlue, touch: {
                let store = self.viewModel.willEditStoreArray[indexPath.row]
                self.tempStoreForRollback = store.copyForRollback()
                store.updateStoreEditStatusCoreDB(editStatus: .edited)
                self.showReturnBar(title: "訪問済み")
                self.sendVisitWithDelay(store: store)
                self.refreshTableViewAndData()
                self.setupNavigationBar()
            })
            
            var btns = [SwipeButton]()
            btns.append(btn!)
            return btns
        } else {
            return [SwipeButton]()
        }
    }
    
    func tableView(_ tableView: UITableView!, rightSwipeButtonsAt indexPath: IndexPath!) -> [SwipeButton]! {
        if self.listType == .willEdit && !self.isCheckBoxesModel {
            let btn = SwipeButton.createSwipeButton(with: #imageLiteral(resourceName: "unvisited_02"), backgroundColor: UIColor.red, touch: {
                let store = self.viewModel.willEditStoreArray[indexPath.row]
                self.tempStoreForRollback = store.copyForRollback()
                store.updateStoreEditStatusCoreDB(editStatus: .notAccessed)
                self.showReturnBar(title: "未訪問")
                self.sendVisitWithDelay(store: store)
                self.refreshTableViewAndData()
                self.setupNavigationBar()
            })
            
            var btns = [SwipeButton]()
            btns.append(btn!)
            return btns
        } else {
            return [SwipeButton]()
        }
    }
}

extension StoreViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cleanFilter()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    }
    
    func cleanFilter() {
        if self.listType == .willEdit {
            self.storesForShow = self.viewModel.willEditStoreArray
        } else if self.listType == .edited {
            self.storesForShow = self.viewModel.editedStoreArray
        } else if self.listType == .notAccessed {
            self.storesForShow = self.viewModel.notAccessedStoreArray
        }
    }
    
    func addFilterAndReload(searchText: String) {
        if searchText.isEmpty {
            cleanFilter()
            self.tableView.reloadData()
            return
        }
        if self.listType == .willEdit {
            self.storesForShow = self.viewModel.willEditStoreArray.filter({ (storeModel) -> Bool in
                if storeModel.storeName!.range(of:searchText) != nil {
                    return true
                } else {
                    return false
                }
                
            })
        } else if self.listType == .edited {
            self.storesForShow = self.viewModel.editedStoreArray.filter({ (storeModel) -> Bool in
                if storeModel.storeName!.range(of:searchText) != nil {
                    return true
                } else {
                    return false
                }
            })
        } else if self.listType == .notAccessed {
            self.storesForShow = self.viewModel.notAccessedStoreArray.filter({ (storeModel) -> Bool in
                if storeModel.storeName!.range(of:searchText) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.tableView.reloadData()
    }
    
    @objc func logoutNotification(notification : NSNotification ) {
        
        let alertController = UIAlertController(title: "ログアウトしますか？",
                                                message: "ログアウトするとこれまで入力したデータは全て削除されます。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ログアウト", style: .default, handler: {
            action in
            self.tapCloseButton()
            NotificationCenter.default.post(name: NSNotification.Name(Notification.CompleteLogoutNotification), object: self)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: {
            action in
            return
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}

extension StoreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.addFilterAndReload(searchText: searchController.searchBar.text!)
    }
}

extension StoreViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        if self.listType == .willEdit {
            self.footerView.isHidden = false
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        if self.listType == .willEdit {
            self.footerView.isHidden = true
            if self.needCleanSearchModels {
                self.viewModel.cleanSearchModels()
                self.refreshTableViewAndData()
                self.setupNavigationBar()
            }
        }
    }
}
