//
//  BaseInfoEditTableViewCell.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/7.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class BaseInfoEditTableViewCell: UITableViewCell, SSRadioButtonControllerDelegate {
    // MARK: - Properties
    weak var tableView: UITableView?
    var titleLabel:UILabel?
    var title: String?
    var valueTextField:UITextField?
    var textFiledEndHandler : ((String) -> Void)?
    let rbController = SSRadioButtonsController()
    var radioBtnEndHandler : ((String) -> Void)?
    var valueTextView:UITextView?
    let moneyRadioNames = ["3%","5%","7%","unknown"]
    let yomiRadioNames = ["n","d","c","b","a","s"]
    let yomiRadioTags = [210, 211, 212, 213, 214, 215]
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createUI(_ id: NSNumber, _ title: String, _ industry: String) {
        self.title = title
        rbController.delegate = self
        switch id.intValue {
        case 4,5:
            radioCell(title, industry)
            break
        case 7:
            textViewCell(title, industry)
            break
        default:
            textCell(title, industry)
            break
            
        }
    }
    
    func textViewCell(_ type: String, _ industry: String) {
        addLabel(type, industry)
        valueTextView = UITextView()
        valueTextView!.layer.borderColor = SSColor.SSBlue.cgColor;
        valueTextView!.layer.borderWidth = 1.0;
        valueTextView!.layer.cornerRadius = 5.0;
        valueTextView?.delegate = self
        self.contentView.addSubview(valueTextView!)
        valueTextView?.snp_makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel!.snp_bottom).offset(10)
            make.bottom.equalToSuperview().offset(-66)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        })
    }
    
    func textCell(_ type: String, _ industry: String) {
        addLabel(type, industry)

        valueTextField = UITextField(frame: CGRect(x:10, y:60, width:200, height:30))
        if type == "TEL" {
            valueTextField?.keyboardType = .decimalPad
            valueTextField?.addDoneButtonToKeyboard(width: self.contentView.frame.size.width, myAction: #selector(self.valueTextField!.resignFirstResponder))
        }
        
        var placeHolderStr: String?
        if type == "TEL" {
            placeHolderStr = "電話番号を入力"
        } else if type == "会社名称" {
            placeHolderStr = "店鋪名を入力"
            valueTextField?.font = UIFont.boldSystemFont(ofSize: 24.0)
        } else {
            placeHolderStr = "入力してください"
        }
        valueTextField?.placeholder = placeHolderStr!
        valueTextField?.borderStyle = UITextBorderStyle.none
        valueTextField?.returnKeyType = .done
        valueTextField?.delegate = self
        self.contentView.addSubview(valueTextField!)
        valueTextField?.snp_makeConstraints({ (make) in
            make.left.equalTo(titleLabel!.snp_right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        })
    }
    
    func radioCell(_ type: String, _ industry: String) {
        addLabel(type, industry)
        
        var buttionNumbers = 4
        if type == "ヨミ" {
            buttionNumbers = 6
        }
        var lastRb : UIButton?
        for i in 0...buttionNumbers-1 {
            let rb = UIButton()
            rbController.addButton(rb)

            rb.tag = 200 + i
            if type == "ヨミ" {
                rb.tag = yomiRadioTags[i]
                rb.setImage(UIImage.init(named: yomiRadioNames[i] + "_off"), for: UIControlState.normal)
                rb.setImage(UIImage.init(named: yomiRadioNames[i] + "_on"), for: UIControlState.selected)
            } else {
                rb.setImage(UIImage.init(named: moneyRadioNames[i] + "_off"), for: UIControlState.normal)
                rb.setImage(UIImage.init(named: moneyRadioNames[i] + "_on"), for: UIControlState.selected)
            }

            self.contentView.addSubview(rb)
            
            if type == "手数料" {
                rb.snp_makeConstraints({ (make) in
                    make.top.equalTo(titleLabel!.snp_bottom).offset(8)
                    let speratorSize = 16.0
                    make.height.equalTo(35)
                    if (lastRb == nil) {
                        make.left.equalToSuperview().offset(speratorSize)
                    } else {
                        make.width.equalTo(lastRb!)
                        make.left.equalTo(lastRb!.snp_right).offset(speratorSize)
                    }
                    if i == buttionNumbers-1 {
                        make.right.equalToSuperview().offset(-speratorSize)
                    }
                    lastRb = rb
                })
            } else {
                rb.snp_makeConstraints({ (make) in
                    let speratorSize = 14.0
                    make.top.equalTo(titleLabel!.snp_bottom).offset(8)
                    if (lastRb == nil) {
                        make.left.equalToSuperview().offset(speratorSize)
                        make.height.equalTo(rb.snp_width)
                    } else {
                        make.width.equalTo(lastRb!)
                        make.height.equalTo(rb.snp_width)
                        make.left.equalTo(lastRb!.snp_right).offset(speratorSize)
                    }
                    if i == buttionNumbers-1 {
                        make.right.equalToSuperview().offset(-speratorSize)
                    }
                    lastRb = rb
                })
            }
        }
    }
    
    func addLabel(_ type: String, _ industry: String) {
        titleLabel = UILabel()

        var imageName = "titleImage.png"
        var imageSize = 20
        if type == "会社名称" {
            titleLabel!.isHidden = true
            imageSize = 40
            if industry == "飲食" {
                imageName = "food_icon"
            } else if industry == "美容" {
                imageName = "beauty_icon"
            } else if industry == "その他"{
                imageName = "other_icon"
            }
        } else if type == "住所" {
            titleLabel!.isHidden = true
            imageName = "pin"
        } else if type == "郵便番号" {
            imageName = "pin"
        } else if type == "TEL" {
            titleLabel!.isHidden = true
            imageName = "tel"
        } else if type == "手数料" {
            imageName = "yen"
        } else if type == "ヨミ" {
            imageName = "star"
        } else {
            imageName = "pen_01"
        }
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.backgroundColor = UIColor.clear
        self.contentView.addSubview(imageView)
        
        titleLabel!.numberOfLines = 1;
        titleLabel!.adjustsFontSizeToFitWidth = true;
        self.contentView.addSubview(titleLabel!)
        titleLabel!.text = type
        
        imageView.snp_makeConstraints { (make) in
            make.width.equalTo(imageSize)
            make.height.equalTo(imageSize)
            make.left.equalToSuperview().offset(8)
            make.centerY.equalTo(titleLabel!.snp_centerY)
        }

        titleLabel?.snp_makeConstraints({ (make) in
            make.height.equalTo(30)
            if type == "会社名称" || type == "住所" || type == "TEL" {
                make.width.equalTo(1)
            } else {
                make.width.equalTo(69)
            }
            make.left.equalTo(imageView.snp_right).offset(4)
            if type == "手数料" || type == "ヨミ" || type == "NG理由" {
                make.top.equalToSuperview().offset(16)
            } else {
                make.centerY.equalToSuperview()
            }
        })
        
        if type == "NG理由" {
//            let sTitleLabel = UILabel()
//            sTitleLabel.numberOfLines = 1;
//            sTitleLabel.adjustsFontSizeToFitWidth = true;
//            self.contentView.addSubview(sTitleLabel)
//            sTitleLabel.text = "アンコール・ワット"
//            sTitleLabel.textColor = SSColor.SSGrayBlack
//            sTitleLabel.snp_makeConstraints({ (make) in
//                make.height.equalTo(self.titleLabel!.snp_height)
//                make.width.equalTo(self.titleLabel!.snp_width).multipliedBy(2.0)
//                make.top.equalTo(self.titleLabel!.snp_bottom).offset(4)
//                make.left.equalTo(imageView.snp_right).offset(4)
//            })
        }
    }
    
    func setRadioBtnHandle(handler:@escaping (String) -> Void){
        self.radioBtnEndHandler = handler
    }
    
    func didSelectButton(selectedButton: UIButton?) {
        guard let selectedButton = selectedButton else {
            return
        }
        switch selectedButton.tag {
        case 210:
            radioBtnEndHandler?("N")
            break
        case 211:
            radioBtnEndHandler?("D")
            break
        case 212:
            radioBtnEndHandler?("C")
            break
        case 213:
            radioBtnEndHandler?("B")
            break
        case 214:
            radioBtnEndHandler?("A")
            break
        case 215:
            radioBtnEndHandler?("S")
            break
        case 200:
            radioBtnEndHandler?("3")
            break
        case 201:
            radioBtnEndHandler?("5")
            break
        case 202:
            radioBtnEndHandler?("7")
            break
        case 203:
            radioBtnEndHandler?("0")
            break
        default:
            break
        }
    }
    
    func setDidEndEditing(handler:@escaping (String) -> Void){
        self.textFiledEndHandler = handler
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

extension BaseInfoEditTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textFiledEndHandler != nil  {textFiledEndHandler!(textField.text!)}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension BaseInfoEditTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.title! == "NG理由" {
            self.tableView!.setContentOffset(CGPoint(x:0, y:tableView!.frame.size.height/3), animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textFiledEndHandler != nil  {
            textFiledEndHandler!(textView.text!)
        }
        if self.title! == "NG理由" {
            self.tableView!.setContentOffset(CGPoint(x:0, y:-30), animated: true)
        }
    }
}
