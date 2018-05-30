        //
//  StoreListViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/08.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
public enum EditStatus: Int {
    case willEdit
    case edited
    case notAccessed
}
private enum ListType: Int {
    case willEdit
    case edited
    case notAccessed
}
class StoreListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    let segmentView = SSSegmentView()
    let tableView = UITableView.init()
    var isVisitList = false
    let viewModel = StoreListViewModel.init()
    var storeArray = [StoreModel]()
    var monthArray = [MonthSection]()
    
    let visitButton:TabButton = TabButton()
    let newStoreListButton:TabButton = TabButton()
    
    let newStoreBtnImg = "ons-tab_pin_off"
    let visitListBtnImg = "ons-tab_pen_on"
    
    private var listType = ListType.willEdit
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupNavigationBar()
        segmentView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
        segmentView.selectedIndex = 1;
        self.view.addSubview(segmentView)
        segmentView.setTitlesWithTitleArray(titleArray: ["未訪問(\(viewModel.notAccessedStoreArray.count))","未入力(\(viewModel.willEditStoreArray.count))","訪問済み(\(viewModel.editedStoreArray.count))"]) { (selectedIndex) in
            switch selectedIndex {
            case 0:
            
                do {
                    self.listType = .notAccessed
                }
                
            case 1:
                do{
                    self.listType = .willEdit
                }
                
            case 2:
                do{
                    self.listType = .edited
                }
            default:
                do {
                    self.listType = .willEdit
                }
            }
            self.setupMonthSection()
            self.tableView.reloadData()
        }
        visitButton.setTitle("訪問履歴", for:.normal)
        visitButton.backgroundColor = UIColor.white
        visitButton.setTitleColor(UIColor.black, for: .normal)
        visitButton.titleLabel?.textAlignment = .center
        visitButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        visitButton.frame = CGRect.init(x: 0, y: 0, width: 177, height: 65)
        visitButton.setImage(UIImage.init(named: visitListBtnImg), for: UIControlState.normal)
        visitButton.imageView?.contentMode = .scaleAspectFit
        visitButton.centerVertically()
        
//        visitButton.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
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
        newStoreListButton.snp_makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(visitButton.snp_right)
            make.size.equalTo(visitButton)
            make.bottom.equalToSuperview()
        }
        visitButton.snp_makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(newStoreListButton.snp_left)
            make.size.equalTo(newStoreListButton)
            make.bottom.equalToSuperview()
        }
        
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StoreListTableViewCell.self, forCellReuseIdentifier: "StoreListTableViewCell")
        tableView.tableFooterView = UIView.init()
        self.view!.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(newStoreListButton.snp_top)
        }
        self.viewModel.loadWillEditStoreModel()
        self.viewModel.loadNotAccessedStoreModel()
        self.viewModel.loadEditedStoreModel()
        self.tableView.reloadData()
        setupMonthSection()
        updateSegmenTitles()
        // Do any additional setup after loading the view.
    }
    func setupNavigationBar(){
        let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backBtn.addTarget(self, action: #selector(tapCloseButton), for: UIControlEvents.touchUpInside)
        backBtn.setImage(UIImage.init(named: "closeIco"), for: UIControlState.normal)
        backBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        backBtn.titleLabel?.textColor = UIColor.blue;
        let rightBtnItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = rightBtnItem
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.SSBlue
        self.title = "訪問履歴"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    func updateSegmenTitles(){
        segmentView.updateTitles(titleArray: ["未訪問(\(viewModel.notAccessedStoreArray.count))","未入力(\(viewModel.willEditStoreArray.count))","訪問済み(\(viewModel.editedStoreArray.count))"])
    }
    
    func setupMonthSection(){
//        for store in viewModel.exsitsStoreArray {
//            if Calendar.current.isDate(<#T##date1: Date##Date#>, inSameDayAs: <#T##Date#>)
//
//        }
        monthArray = []
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy年MM月"
        var storeArray = [StoreModel]()
        switch listType {
        case .willEdit:
            do{
                storeArray = viewModel.willEditStoreArray
            }
        case .notAccessed:
            do{
                storeArray = viewModel.notAccessedStoreArray
            }
        case .edited:
            do{
                storeArray = viewModel.editedStoreArray
            }
        }
        storeArray = storeArray.sorted(by: { $0.accessedTime! > $1.accessedTime! })
        var lastYearMonth = String()
        var lastMonthSection = MonthSection()
        for store in storeArray {
            let yearMonth = dateformatter.string(from: (store.accessedTime)!)
            if yearMonth != lastYearMonth {
                let monthSection = MonthSection()
                monthSection.monthTitle = yearMonth
                lastMonthSection = monthSection
                monthArray.append(monthSection)
                lastYearMonth = yearMonth
            }
            lastMonthSection.monthDaySection.append(store)
        }

    }
    
    
    //datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthArray.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthArray[section].monthDaySection.count
//        switch listType {
//        case .willEdit:
//            do{
//                return monthArray[section].monthDaySection.count
//            }
//        case .notAccessed:
//            do{
//                return viewModel.notAccessedStoreArray.count
//            }
//        case .edited:
//            do{
//                return viewModel.editedStoreArray.count
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:StoreListTableViewCell = StoreListTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "StoreListTableViewCell")
        
//        if isVisitList {
//            let store = viewModel.exsitsStoreArray[indexPath.row]
//
//            cell.titleLabel.text = store.storeName
//            cell.addressLabel.text = store.storeAddress!
//            cell.layoutType = store.layoutType
//        }else{
//            let store = storeArray[indexPath.row]
//            cell.titleLabel.text = store.storeName
//            cell.addressLabel.text = store.storeAddress!
//            cell.setLayoutType(type: store.layoutType)
//        }
        let store = monthArray[indexPath.section].monthDaySection[indexPath.row]
//        switch listType {
//        case .willEdit:
//            do{
//                store = viewModel.willEditStoreArray[indexPath.row]
//            }
//        case .notAccessed:
//            do{
//                store = viewModel.notAccessedStoreArray[indexPath.row]
//            }
//        case .edited:
//            do{
//                store = viewModel.editedStoreArray[indexPath.row]
//            }
//        }
        cell.titleLabel.text = store.storeName
        cell.addressLabel.text = store.storeAddress!
        cell.checkmarkButton.isSelected = (listType == .edited) || (listType == .willEdit && store.layoutType != .normal)
        cell.crossButton.isSelected = listType == .notAccessed
        cell.setLayoutType(type: store.layoutType)
        cell.setStoreListHandler(checkHandler: { (storeModel) in
            store.layoutType = .detail
            self.tableView.reloadData()
        }, NGHandler: { (storeModel) in
            store.updateStoreEditStatus(editStatus: .notAccessed)
            self.viewModel.reloadNotAccessedStoreModel()
            self.viewModel.reloadWillEditStoreModel()
            self.viewModel.reloadEditedStoreModel()
            self.setupMonthSection()
            self.tableView.reloadData()
            self.updateSegmenTitles()
        }, opportunityHandler: { (storeModel) in
            store.layoutType = .edit
            self.tableView.reloadData()
        }, notOpportunityHandler : { (storeModel) in
            store.updateStoreEditStatus(editStatus: .edited)
            self.viewModel.reloadNotAccessedStoreModel()
            self.viewModel.reloadWillEditStoreModel()
            self.viewModel.reloadEditedStoreModel()
            self.setupMonthSection()
            self.tableView.reloadData()
            self.updateSegmenTitles()
        }, editHandler: { (storeModel) in
            store.updateStoreEditStatus(editStatus: .edited)
            self.viewModel.reloadEditedStoreModel()
            self.viewModel.reloadWillEditStoreModel()
            self.viewModel.reloadNotAccessedStoreModel()
            self.setupMonthSection()
            self.tableView.reloadData()
            self.updateSegmenTitles()
        })
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let store = isVisitList ? viewModel.exsitsStoreArray[indexPath.row] : storeArray[indexPath.row]
        let store = monthArray[indexPath.section].monthDaySection[indexPath.row]
//        switch listType {
//        case .willEdit:
//            do{
//                store = viewModel.willEditStoreArray[indexPath.row]
//            }
//        case .notAccessed:
//            do{
//                store = viewModel.notAccessedStoreArray[indexPath.row]
//            }
//        case .edited:
//            do{
//                store = viewModel.editedStoreArray[indexPath.row]
//            }
//        }
        switch store.layoutType {
            case StoreListCellLayoutType.normal:
            return 64
            case StoreListCellLayoutType.edit:
            return 340
            case StoreListCellLayoutType.detail:
            return 240
        }
        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.SSGray
        let headerLabel = UILabel.init()
        headerLabel.text = monthArray[section].monthTitle
        headerLabel.textColor = UIColor.black
        headerLabel.textAlignment = NSTextAlignment.center
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    @objc func tapCloseButton(){
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
