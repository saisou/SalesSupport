//
//  MapViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/07.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreData
import MapKit
class MapViewController: UIViewController,CLLocationManagerDelegate {
    
    var firstTimeUpdatedLocation = true
    let viewModel = MapViewModel()
    var mapView = MKMapView()
    let logView = UITextView()

    let locationManager = CLLocationManager()
    let aimView = UIImageView()
    
// MARK: buttons property
    let refreshButton = UIButton()
    let cleanButton = UIButton()
    
    let visitButton:TabButton = TabButton()
    let sendButton:UIButton = UIButton()
    let newStoreListButton:TabButton = TabButton()
    let userInfoButton = RoundButton()
    let userLocationButton = RoundButton()
    
    let foodListButton = RoundButton()
    let beautyListButton = RoundButton()
    let otherListButton = RoundButton()
    let unknownButton = RoundButton()
    let salesButton = RoundButton()
    let typeRadioBtController = SSRadioButtonsController()
    
// MARK: image names
    //375x667
    let userIconImage = "icon_106"
    let centerPinImage = "center_pin"
    let foodOnImage = "food_on"
    let foodOffImage = "food_off"
    let beautyOnImage = "beauty_on"
    let beautyOffImage = "beauty_off"
    let otherOnImage = "other_on"
    let otherOffImage = "other_off"
    let decisionBtnOn = "decision-btn_on"
    let decisionBtnOff = "decision-btn_off"
    let newStoreBtnImg = "ons-tab_pin_on"
    let visitListBtnImg = "ons-tab_pen_off"

// MARK:  public function
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        viewModel.loadViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func debugUI() {
        self.view.addSubview(logView)
        logView.snp.makeConstraints { (make) in
            make.size.equalTo(0)
            make.left.equalToSuperview()
        }
        
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.setTitleColor(UIColor.blue, for: .normal)
        refreshButton.addTarget(self, action: #selector(loadLogModels), for: .touchUpInside)
        
        self.view.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, self.view.frame.size.height*7/8, self.view.frame.size.width/2))
        }
        refreshButton.isHidden = true
        
        cleanButton.setTitle("clean", for: .normal)
        cleanButton.setTitleColor(UIColor.blue, for: .normal)
        cleanButton.addTarget(self, action: #selector(cleanLogModels), for: .touchUpInside)
        
        self.view.addSubview(cleanButton)
        cleanButton.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(self.view.frame.size.height*2/8, 0, self.view.frame.size.height*5/8, self.view.frame.size.width/2))
        }
        cleanButton.isHidden = true
    }

    func createUI(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        self.view.addSubview(mapView);
        
        visitButton.setTitle("訪問履歴", for:.normal)
        visitButton.backgroundColor = UIColor.white
        visitButton.setTitleColor(UIColor.SSGray, for: .normal)
        visitButton.titleLabel?.textAlignment = .center
        visitButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        visitButton.frame = CGRect.init(x: 0, y: 0, width: 177, height: 65)
        visitButton.setImage(UIImage.init(named: visitListBtnImg), for: UIControlState.normal)
        visitButton.imageView?.contentMode = .scaleAspectFit
        visitButton.centerVertically()
        visitButton.addTarget(self, action: #selector(tapVisitButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(visitButton)
        
        newStoreListButton.setTitle("新店情報", for:.normal)
        newStoreListButton.backgroundColor = UIColor.white
        newStoreListButton.setTitleColor(UIColor.black, for: .normal)
        newStoreListButton.titleLabel?.textAlignment = .center
        newStoreListButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        newStoreListButton.frame = CGRect.init(x: 0, y: 0, width: 177, height: 65)
        newStoreListButton.setImage(UIImage.init(named: newStoreBtnImg), for: UIControlState.normal)
        newStoreListButton.imageView?.contentMode = .scaleAspectFit
        newStoreListButton.centerVertically()

        self.view.addSubview(newStoreListButton)
        
        sendButton.setImage(UIImage.init(named: decisionBtnOff), for: .disabled)
        sendButton.setImage(UIImage.init(named: decisionBtnOn), for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendButton.layer.cornerRadius = 18
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(tapSendButton), for: UIControlEvents.touchUpInside)
        sendButton.isEnabled = false
        self.view.addSubview(sendButton)
        
        userLocationButton.setImage(UIImage.init(named: "position"), for: UIControlState.normal)
        userLocationButton.backgroundColor = UIColor.clear
        userLocationButton.titleLabel?.textAlignment = NSTextAlignment.center
        userLocationButton.addTarget(self, action: #selector(tapUserLocationButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(userLocationButton)
        
        userInfoButton.setImage(UIImage.init(named: userIconImage), for: UIControlState.normal)
        userInfoButton.addTarget(self, action: #selector(tapUserIconButton), for: UIControlEvents.touchUpInside)
        userInfoButton.backgroundColor = UIColor.clear
        self.view.addSubview(userInfoButton)
        
        unknownButton.setImage(#imageLiteral(resourceName: "unkn_off"), for: UIControlState.normal)
        unknownButton.setImage(#imageLiteral(resourceName: "unkn_on"), for: UIControlState.selected)
        unknownButton.tag = 104
        self.view.addSubview(unknownButton)
        let unknownLabel = UILabel()
        unknownLabel.textAlignment = NSTextAlignment.center
        unknownLabel.text = "不明"
        unknownLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        unknownLabel.textColor = SSColor.SSGrayBlack
        self.view.addSubview(unknownLabel)
        
        salesButton.setImage(#imageLiteral(resourceName: "goods_off"), for: UIControlState.normal)
        salesButton.setImage(#imageLiteral(resourceName: "goods_on"), for: UIControlState.selected)
        salesButton.tag = 105
        self.view.addSubview(salesButton)
        let salesLabel = UILabel()
        salesLabel.textAlignment = NSTextAlignment.center
        salesLabel.text = "物販"
        salesLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        salesLabel.textColor = SSColor.SSGrayBlack
        self.view.addSubview(salesLabel)
        
        foodListButton.setImage(UIImage.init(named: foodOffImage), for: UIControlState.normal)
        foodListButton.setImage(UIImage.init(named: foodOnImage), for: UIControlState.selected)
        foodListButton.tag = 101
        self.view.addSubview(foodListButton)
        let foodLabel = UILabel()
        foodLabel.textAlignment = NSTextAlignment.center
        foodLabel.text = "飲食"
        foodLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        foodLabel.textColor = SSColor.SSGrayBlack
        self.view.addSubview(foodLabel)
        
        beautyListButton.setImage(UIImage.init(named: beautyOffImage), for: UIControlState.normal)
        beautyListButton.setImage(UIImage.init(named: beautyOnImage), for: UIControlState.selected)
        beautyListButton.tag = 102
        self.view.addSubview(beautyListButton)
        let beautyLabel = UILabel()
        beautyLabel.textAlignment = NSTextAlignment.center
        beautyLabel.text = "美容"
        beautyLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        beautyLabel.textColor = SSColor.SSGrayBlack
        self.view.addSubview(beautyLabel)
        
        otherListButton.setImage(UIImage.init(named: otherOffImage), for: UIControlState.normal)
        otherListButton.setImage(UIImage.init(named: otherOnImage), for: UIControlState.selected)
        otherListButton.tag = 103
        self.view.addSubview(otherListButton)
        let otherLabel = UILabel()
        otherLabel.textAlignment = NSTextAlignment.right
        otherLabel.text = "その他"
        otherLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        otherLabel.textColor = SSColor.SSGrayBlack
        self.view.addSubview(otherLabel)
        
        beautyListButton.backgroundColor = UIColor.clear
        foodListButton.backgroundColor = UIColor.clear
        otherListButton.backgroundColor = UIColor.clear
        // Init RadioBtController
        typeRadioBtController.delegate = self
        typeRadioBtController.addButton(beautyListButton)
        typeRadioBtController.addButton(foodListButton)
        typeRadioBtController.addButton(otherListButton)
        typeRadioBtController.addButton(unknownButton)
        typeRadioBtController.addButton(salesButton)
        
        mapView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(visitButton.snp.top)
        })
        visitButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(newStoreListButton.snp.left)
            make.size.equalTo(newStoreListButton)
            make.bottom.equalToSuperview()
        }
        
        newStoreListButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(visitButton.snp.right)
            make.size.equalTo(visitButton)
            make.bottom.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(sendButton.snp.width).dividedBy(6)
            make.bottom.equalTo(visitButton.snp.top).offset(-16)
        }
        
        userLocationButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(newStoreListButton.snp.top).offset(-88)
            make.size.equalTo(44)
        }
        userInfoButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(16)
            make.top.equalToSuperview().offset(48)
            make.size.equalTo(56)
        }
        
        unknownButton.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(unknownLabel.snp.top).offset(-2)
            make.size.equalTo(56)
        }
        unknownLabel.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-26)
            make.bottom.equalTo(salesButton.snp.top).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(44)
        }
        salesButton.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(salesLabel.snp.top).offset(-2)
            make.size.equalTo(56)
        }
        salesLabel.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-26)
            make.bottom.equalTo(foodListButton.snp.top).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(44)
        }
        
        foodListButton.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(foodLabel.snp.top).offset(-2)
            make.size.equalTo(56)
        }
        foodLabel.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-26)
            make.bottom.equalTo(beautyListButton.snp.top).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(44)
        }
        beautyListButton.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(beautyLabel.snp.top).offset(-2)
            make.size.equalTo(56)
        }
        beautyLabel.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-26)
            make.bottom.equalTo(otherListButton.snp.top).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(44)
        }
        otherListButton.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(otherLabel.snp.top).offset(-2)
            make.size.equalTo(56)
        }
        otherLabel.snp.makeConstraints { (make) in
            //            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-26)
            make.bottom.equalTo(userLocationButton.snp.bottom).offset(20)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        aimView.image = UIImage.init(named: centerPinImage)
//        aimView.isHidden = true
        mapView.addSubview(aimView)
        aimView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-26)
            make.width.equalTo(self.view.frame.size.width * 0.1)
            make.height.equalTo(56)
        }
    }
    
    func loadPin(){
        for store in viewModel.storeArray {
             addAnnotaionToMapView(store: store)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.firstTimeUpdatedLocation {
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = mapView.userLocation.coordinate
            mapRegion.span.latitudeDelta = 0.01
            mapRegion.span.longitudeDelta = 0.01
            
            mapView.setRegion(mapRegion, animated: true)
            self.firstTimeUpdatedLocation = false
        }
    }
    
    @objc func oldtapSendButton(){
        let coordinate = self.mapView.convert( self.mapView.center, toCoordinateFrom: self.mapView)
        let vc = AddNewStoreViewController.init()
        
        switch self.typeRadioBtController.selectedButton()!.tag {
        case 101:
            vc.businessType = "飲食"
            break
        case 102:
            vc.businessType = "美容"
            break
        case 103:
            vc.businessType = "その他"
            break
        default: break
            
        }
        
        vc.coordinate = coordinate
        vc.setComplete { (store :StoreModel) in
            self.addAnnotaionToMapView(store: store)
            self.viewModel.reloadViewModel()
        }
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true) {
            
        }
    }
    
    @objc func tapSendButton(){
        let coordinate = self.mapView.convert( self.mapView.center, toCoordinateFrom: self.mapView)
        
        var store = StoreModel()
        store.latitude = coordinate.latitude
        store.longitude = coordinate.longitude
        switch self.typeRadioBtController.selectedButton()!.tag {
        case 101:
            store.industry = "飲食"
            break
        case 102:
            store.industry = "美容"
            break
        case 103:
            store.industry = "その他"
            break
        case 104:
            store.industry = "不明"
            break
        case 105:
            store.industry = "物販"
            break
        default: break
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "StoreDetailView") as! StoreDetailViewController
        newViewController.store = store
        newViewController.isNewStoreModel = true
        let nav = UINavigationController.init(rootViewController: newViewController)
        self.present(nav, animated: true) {
        }
    }
    
    @objc func tapUserIconButton(){
        let alertController = UIAlertController(title: "ログアウトしますか？",
                                                message: "ログアウトするとこれまで入力したデータは全て削除されます。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ログアウト", style: .default, handler: {
            action in
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

    @objc func longPress(sender : UILongPressGestureRecognizer){
        if sender.state != UIGestureRecognizerState.began {
            return;
        }
        let longPressPoint = sender.location(in: mapView)
        let coordinate = mapView.convert( longPressPoint, toCoordinateFrom: mapView)
        let vc = AddNewStoreViewController.init()
        vc.coordinate = coordinate
        vc.setComplete { (store :StoreModel) in
            self.addAnnotaionToMapView(store: store)
            self.viewModel.reloadViewModel()
        }
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true) {
            
        }
    }
    
    @objc func tapStoreListButton(){
        
        let vc = StoreViewController.init()
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: false) {

        }
    }
    @objc func tapVisitButton(){
        
        let vc = StoreViewController.init()
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: false) {
            
        }
    }
        
    @objc func tapUserLocationButton(){
        mapView.centerCoordinate = mapView.userLocation.coordinate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MapViewController: SSRadioButtonControllerDelegate {
    func didSelectButton(selectedButton: UIButton?) {
        sendButton.isEnabled = true
    }
}

extension MapViewController:MKMapViewDelegate {
    
    func mapView(_ mapView:MKMapView, viewFor annotation:MKAnnotation) -> MKAnnotationView?{
        
        if annotation.isKind(of:MKUserLocation.self) {
            return nil
        }
        let identifier = "MKPinAnnotationView"

        var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier:identifier) as? MKPinAnnotationView
        if  ((annotationView) == nil){
            annotationView =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.isDraggable = true
        }
        annotationView?.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(sender:))))
        if (annotation as! SSPointAnnotation).accessed == true {
            annotationView?.pinTintColor = UIColor.init(red:  42.0 / 255.0, green:  153.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        }else{
            annotationView?.pinTintColor = UIColor.red
        }
        annotationView!.annotation = annotation
        
        annotationView?.canShowCallout = true
        annotationView?.layer.shadowColor = UIColor.black.cgColor
        
        return annotationView

    }
    
    func mapView(_ mapView:MKMapView, didFailToLocateUserWithError error:Error){
        
        print(error.localizedDescription)
        
    }
    
    func addAnnotaionToMapView(store:StoreModel){

        let coorinate2D = CLLocationCoordinate2DMake(store.latitude!, store.longitude!)
        let pointAnnotation = SSPointAnnotation()
        pointAnnotation.coordinate = coorinate2D
        pointAnnotation.title = store.storeName;
        pointAnnotation.subtitle = store.storeAddress;
        pointAnnotation.accessed = store.accessed
        mapView.addAnnotation(pointAnnotation)
        
    }
    
    @objc func loadLogModels() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        do {
            let count = try managedObectContext.count(for: fetchRequest)
            let limited = 30
            if count <= limited {
                fetchRequest.fetchOffset = 0
                fetchRequest.fetchLimit = count
            } else {
                fetchRequest.fetchOffset = count - limited
                fetchRequest.fetchLimit = limited
            }
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            logView.text = ""
            if let results = fetchedResults {
                for logData in results {
                    logView.text.append("latitude : \(String(describing: logData.value(forKey: "latitude") as? Double)) \n")
                    logView.text.append("longitude : \(String(describing: logData.value(forKey: "longitude") as? Double)) \n")
                    logView.text.append("motion : \(String(describing: logData.value(forKey: "motion") as? String)) \n")
                    logView.text.append("time : \(String(describing: logData.value(forKey: "time") as? Date)) \n\n")
                }
            }
            
        } catch  {
            fatalError("失败")
        }
    }
    
    @objc func cleanLogModels() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObectContext.execute(deleteRequest)
            logView.text = ""
        } catch  {
            fatalError("失败")
        }
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
