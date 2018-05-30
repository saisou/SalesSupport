//
//  StoreTableViewCell.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/3/4.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class StoreTableViewCell: SwipeTableCell {
    var iconButton : UIButton?
    var titleLabel = UILabel()
    var addressLabel = UILabel()
    var timeLabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createView(_ checkBox:VisitCheckBox) {
        iconButton = checkBox
        self.contentView.addSubview(iconButton!);
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleLabel)
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byCharWrapping
        addressLabel.textColor = UIColor.gray
        addressLabel.font = UIFont.boldSystemFont(ofSize: 14)
        timeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        timeLabel.textAlignment = .right
        timeLabel.textColor = UIColor.gray
        if let timeStr = checkBox.store!.minDatetime {
            var weekdayStr = ""
            let weekday = Calendar.current.component(.weekday, from: checkBox.store!.accessedTime!)
            switch weekday {
            case 1:
                weekdayStr = "(日)"
                break
            case 2:
                weekdayStr = "(月)"
                break
            case 3:
                weekdayStr = "(火)"
                break
            case 4:
                weekdayStr = "(水)"
                break
            case 5:
                weekdayStr = "(木)"
                break
            case 6:
                weekdayStr = "(金)"
                break
            case 7:
                weekdayStr = "(土)"
                break
            default:
                break
            }
            //mm-dd(曜)hh:mm
            var startOfSentence = timeStr.index(timeStr.endIndex, offsetBy: -14)
            var indexEndOfText = timeStr.index(timeStr.endIndex, offsetBy: -10)
            let timeStrDay = timeStr[startOfSentence...indexEndOfText]
            startOfSentence = timeStr.index(timeStr.endIndex, offsetBy: -8)
            indexEndOfText = timeStr.index(timeStr.endIndex, offsetBy: -4)
            let timeStrTime = timeStr[startOfSentence...indexEndOfText]
            timeLabel.text = timeStrDay + weekdayStr + timeStrTime
            // if accessdTime equal fakeDate,
            // it's a store info searched from server, no access time.
            if checkBox.store!.accessedTime == TreasureDataConstant.fakeDate {
                timeLabel.text = ""
            }
        }
        
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(timeLabel)
        
        iconButton!.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.left.equalToSuperview().offset(22)
            
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(iconButton!.snp.right).offset(16)
            make.right.equalTo(timeLabel.snp.left).offset(-8)
            make.top.equalToSuperview().offset(8)
        })
        timeLabel.snp.makeConstraints({ (make) in
            make.right.equalToSuperview().offset(-8)
            make.width.equalTo(120)
            make.centerY.equalTo(titleLabel)
        })
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconButton!.snp.right).offset(16)
            make.right.equalTo(timeLabel.snp.right)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }
}
