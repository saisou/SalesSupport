//
//  StoreListTableViewCell.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/9.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
public enum StoreListCellLayoutType: Int {
    case normal
    case detail
    case edit
}
class StoreListTableViewCell: UITableViewCell {
    
    var layoutType = StoreListCellLayoutType.normal
    
    // common
    var iconView = UIImageView()
    var titleLabel = UILabel()
    var addressLabel = UILabel()
    var telLabel = UILabel()
    var checkmarkButton = UIButton()
    var crossButton = UIButton()
    var addressIcon = UIImageView()
    var telIcon = UIImageView()
    var opportunityBut = UIButton()
    var noOpportunityBut = UIButton()
    var feeLabel = UILabel()
    var fee3PercentBut = OptionButton()
    var fee5PercentBut = OptionButton()
    var fee7PercentBut = OptionButton()
    var feeUnknownBut = OptionButton()
    var yomiLabel = UILabel()
    var yomiNBut = OptionButton()
    var yomiDBut = OptionButton()
    var yomiCBut = OptionButton()
    var yomiBBut = OptionButton()
    var yomiABut = OptionButton()
    var yomiSBut = OptionButton()
    
    var checkHandler :((StoreModel)->())?
    var NGHandler :((StoreModel)->())?
    var opportunityHandler : ((StoreModel)->())?
    var notOpportunityHandler : ((StoreModel)->())?
    var editHandler : ((StoreModel)->())?
    
    private var feeButtonArray = [OptionButton]()
    private var rubbishButtonArray = [OptionButton]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        iconView.image = UIImage.init(named: "food_icon")
        self.contentView.addSubview(iconView);
        titleLabel.textColor = UIColor.init(red:  42.0 / 255.0, green:  153.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleLabel)
        checkmarkButton.setImage(UIImage.init(named: "check_off"), for: UIControlState.normal)
        checkmarkButton.setImage(UIImage.init(named: "check_on"), for: UIControlState.selected)
        checkmarkButton.addTarget(self, action: #selector(tapCheckmarkBttuon), for: UIControlEvents.touchUpInside)
        self.contentView.addSubview(checkmarkButton)
        crossButton.setImage(UIImage.init(named: "NG_off"), for: UIControlState.normal)
        crossButton.setImage(UIImage.init(named: "NG_on"), for: UIControlState.selected)
        crossButton.addTarget(self, action: #selector(tapCrossButton), for: UIControlEvents.touchUpInside)

        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byCharWrapping
        addressLabel.textColor = UIColor.gray
        addressLabel.font = UIFont.boldSystemFont(ofSize: 14)
        addressIcon.image = UIImage.init(named: "pin_glay")
        telLabel.font = UIFont.boldSystemFont(ofSize: 14)
        telLabel.textColor = UIColor.gray
        telLabel.text = "03-234-4567"
        telIcon.image = UIImage.init(named: "pin_glay")
        opportunityBut.backgroundColor = UIColor.SSBlue
        opportunityBut.layer.cornerRadius = 8
        opportunityBut.clipsToBounds = true
        opportunityBut.addTarget(self, action: #selector(tapOpportunityButton), for: UIControlEvents.touchUpInside)
        opportunityBut.setTitle("商談した", for: UIControlState.normal)
        opportunityBut.setTitleColor(UIColor.white, for: UIControlState.normal)
        noOpportunityBut.backgroundColor = UIColor.white
        noOpportunityBut.layer.cornerRadius = 8
        noOpportunityBut.layer.borderWidth = 1
        noOpportunityBut.layer.borderColor = UIColor.SSBlue.cgColor
        noOpportunityBut.clipsToBounds = true
        noOpportunityBut.addTarget(self, action: #selector(tapNotOpportunityButton), for: UIControlEvents.touchUpInside)
        noOpportunityBut.setTitle("商談していない", for: UIControlState.normal)
        noOpportunityBut.setTitleColor(UIColor.SSBlue, for: UIControlState.normal)
        setupOptionButtonArray()
        feeLabel.text = "手数料"
        feeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        feeLabel.textColor = UIColor.gray
        fee3PercentBut.setTitle("3%", for: UIControlState.normal)
        fee5PercentBut.setTitle("5%", for: UIControlState.normal)
        fee7PercentBut.setTitle("7%", for: UIControlState.normal)
        feeUnknownBut.setTitle("?%", for: UIControlState.normal)
        yomiLabel.text = "ヨミ"
        yomiLabel.font = UIFont.boldSystemFont(ofSize: 14)
        yomiLabel.textColor = UIColor.gray
        yomiNBut.setTitle("N", for: UIControlState.normal)
        yomiDBut.setTitle("D", for: UIControlState.normal)
        yomiCBut.setTitle("C", for: UIControlState.normal)
        yomiBBut.setTitle("B", for: UIControlState.normal)
        yomiABut.setTitle("A", for: UIControlState.normal)
        yomiSBut.setTitle("S", for: UIControlState.normal)
        
        self.contentView.addSubview(crossButton)
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(addressIcon)
        self.contentView.addSubview(telLabel)
        self.contentView.addSubview(telIcon)
        self.contentView.addSubview(opportunityBut)
        self.contentView.addSubview(noOpportunityBut)
        self.contentView.addSubview(feeLabel)
        self.contentView.addSubview(fee3PercentBut)
        self.contentView.addSubview(fee5PercentBut)
        self.contentView.addSubview(fee7PercentBut)
        self.contentView.addSubview(feeUnknownBut)
        self.contentView.addSubview(yomiLabel)
        self.contentView.addSubview(yomiNBut)
        self.contentView.addSubview(yomiDBut)
        self.contentView.addSubview(yomiCBut)
        self.contentView.addSubview(yomiBBut)
        self.contentView.addSubview(yomiABut)
        self.contentView.addSubview(yomiSBut)
        
    }
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func layoutSubviews() {
        
    }
    
    func setLayoutType (type : StoreListCellLayoutType){
        layoutType = type
        iconView.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.left.equalToSuperview().offset(22)
            
            make.top.equalToSuperview().offset(22)
        }
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(iconView.snp.right).offset(16)
            make.right.equalTo(checkmarkButton.snp.left).offset(-8)
            //            make.top.equalToSuperview().offset(22)
            make.centerY.equalTo(iconView)
        })
        checkmarkButton.snp.makeConstraints({ (make) in
            make.right.equalTo(crossButton.snp.left).offset(-22)
            make.size.equalTo(32)
            make.centerY.equalTo(titleLabel)
        })
        crossButton.snp.makeConstraints({ (make) in
            make.right.equalToSuperview().offset(-22)
            make.size.equalTo(32)
            make.centerY.equalTo(titleLabel)
        })
        
        switch layoutType {
        case StoreListCellLayoutType.normal:
            do {
                
            }
        case StoreListCellLayoutType.detail:
            do {
                addressIcon.snp.makeConstraints({ (make) in
                    make.top.equalTo(iconView.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                    make.height.equalTo(22)
                    make.width.equalTo(24 / 3 * 2)
                })
                addressLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(addressIcon.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-22)
                    make.top.equalTo(addressIcon)
                    make.height.greaterThanOrEqualTo(16)
                    
                }
                telIcon.snp.makeConstraints({ (make) in
                    make.top.equalTo(addressLabel.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                    make.height.equalTo(22)
                    make.width.equalTo(24 / 3 * 2)
                })
                telLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(telIcon.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-22)
                    make.centerY.equalTo(telIcon)
                    
                }
                
                opportunityBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(telIcon.snp.bottom).offset(16)
                    make.left.equalToSuperview().offset(22)
                    make.right.equalTo(noOpportunityBut.snp.left).offset(-22)
                    make.height.equalTo(44)
                    make.width.equalTo(noOpportunityBut)
                })
                noOpportunityBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(opportunityBut)
                    make.right.equalToSuperview().offset(-22)
                    make.height.equalTo(44)
                })
            
            }
        case StoreListCellLayoutType.edit:
            do{
                addressIcon.snp.makeConstraints({ (make) in
                    make.top.equalTo(iconView.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                    make.height.equalTo(22)
                    make.width.equalTo(24 / 3 * 2)
                })
                addressLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(addressIcon.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-22)
                    make.top.equalTo(addressIcon)
                    make.height.greaterThanOrEqualTo(16)
                    
                }
                telIcon.snp.makeConstraints({ (make) in
                    make.top.equalTo(addressLabel.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                    make.height.equalTo(22)
                    make.width.equalTo(24 / 3 * 2)
                })
                telLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(telIcon.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-22)
                    make.centerY.equalTo(telIcon)
                    
                }
                feeLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo(telIcon.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                })
                fee3PercentBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(feeLabel.snp.bottom).offset(12)
                    make.left.equalTo(iconView)
                    make.size.equalTo(32)
                })
                fee5PercentBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(feeLabel.snp.bottom).offset(12)
                    make.left.equalTo(fee3PercentBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                fee7PercentBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(feeLabel.snp.bottom).offset(12)
                    make.left.equalTo(fee5PercentBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                feeUnknownBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(feeLabel.snp.bottom).offset(12)
                    make.left.equalTo(fee7PercentBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                yomiLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo(fee3PercentBut.snp.bottom).offset(22)
                    make.left.equalTo(iconView)
                })
                yomiNBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                    make.left.equalTo(iconView)
                    make.size.equalTo(32)
                })
                yomiDBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                    make.left.equalTo(yomiNBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                yomiCBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                    make.left.equalTo(yomiDBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                yomiBBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                   make.left.equalTo(yomiCBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                yomiABut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                    make.left.equalTo(yomiBBut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
                yomiSBut.snp.makeConstraints({ (make) in
                    make.top.equalTo(yomiLabel.snp.bottom).offset(12)
                    make.left.equalTo(yomiABut.snp.right).offset(16)
                    make.size.equalTo(32)
                })
            
            }
            
        }
    }
    func setStoreListHandler(checkHandler : @escaping (StoreModel)->() ,NGHandler : @escaping (StoreModel)->() ,opportunityHandler : @escaping (StoreModel)->(),notOpportunityHandler : @escaping (StoreModel)->() ,editHandler : @escaping (StoreModel)->()) {
//        completehandle = handle
        self.checkHandler = checkHandler
        self.NGHandler = NGHandler
        self.opportunityHandler = opportunityHandler
        self.editHandler = editHandler
        self.notOpportunityHandler = notOpportunityHandler
    }
    
    func setupOptionButtonArray(){
        feeButtonArray = [fee3PercentBut,fee5PercentBut,fee7PercentBut,feeUnknownBut]
        rubbishButtonArray = [yomiNBut,yomiDBut,yomiCBut,yomiBBut,yomiABut,yomiSBut]
        for feeButton in feeButtonArray {
            feeButton.addTarget(self, action: #selector(tapFeeButton(feeButton:)), for: UIControlEvents.touchUpInside)
        }
        for rubbishButton in rubbishButtonArray {
            rubbishButton.addTarget(self, action: #selector(tapRubbishButton(rubbishButtton:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    func handlerIfNeeded(){
        var feeBtnIsSelected = false
        for feeButton in feeButtonArray {
            if feeButton.isSelected == true{
                feeBtnIsSelected = true
            }
        }
        var rubbishBtnIsSelected = false
        for rubbishButton in rubbishButtonArray {
            if rubbishButton.isSelected == true{
                rubbishBtnIsSelected = true
           }
        }
        if feeBtnIsSelected && rubbishBtnIsSelected{
            editHandler?(StoreModel())
        }
    }
    
    @objc func tapCheckmarkBttuon(){
        checkHandler?(StoreModel())
    }
    @objc func tapCrossButton(){
        NGHandler?(StoreModel())
    }
    @objc func tapOpportunityButton(){
        opportunityHandler?(StoreModel())
    }
    @objc func tapNotOpportunityButton(){
        notOpportunityHandler?(StoreModel())
    }
    @objc func tapFeeButton(feeButton : UIButton){
        for _feeButton in feeButtonArray {
            if _feeButton == feeButton{
                _feeButton.isSelected = true
            }else{
                _feeButton.isSelected = false
            }
        }
        handlerIfNeeded()
    }
    @objc func tapRubbishButton(rubbishButtton : UIButton){
        for _rebbishButton in rubbishButtonArray {
            if _rebbishButton == rubbishButtton{
                _rebbishButton.isSelected = true
            }else{
                _rebbishButton.isSelected = false
            }
        }
        handlerIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
