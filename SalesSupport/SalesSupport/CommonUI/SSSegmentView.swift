//
//  SSSegmentView.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/13.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class SSSegmentView: UIView {
    
    var selectedIndex = 0
    var sliderHeight = 2
    var selectedHandler :((Int)->())?
    
    private var slider = UIView()
    private var titileButArray = [UIButton]()
    
    func setTitlesWithTitleArray(titleArray : [String]?){
        if let titleArray = titleArray{
            var i = 0;
            setSliderFrameWithTitleCount(count: titleArray.count)
            for title in titleArray {
                let titleBtn = UIButton()
                titleBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                titleBtn.setTitle(title, for: UIControlState.normal)
                titleBtn.setTitleColor(UIColor.gray, for: UIControlState.normal)
                titleBtn.setTitleColor(UIColor.SSBlue, for: UIControlState.selected)
                titleBtn.tag = i
                titleBtn.addTarget(self, action: #selector(tapTitle(button:)), for: UIControlEvents.touchUpInside)
                if i == selectedIndex { titleBtn.isSelected = true }
                self.addSubview(titleBtn)
                titleBtn.snp.makeConstraints({ (make) in
                    make.width.equalTo(self.frame.width / CGFloat(titleArray.count))
                    make.left.equalToSuperview().offset(CGFloat(i) * (self.frame.width / CGFloat(titleArray.count)))
                    make.top.equalToSuperview();
                    make.bottom.equalTo(self.slider.snp.top)
                })
                self.titileButArray.append(titleBtn)
                i = i + 1
            }
        }
    }
    
    func setTitlesWithTitleArray(titleArray : [String]?, selectedHandler : @escaping ((Int)->())){
        self.setTitlesWithTitleArray(titleArray: titleArray)
        self.selectedHandler = selectedHandler
    }
    func setSliderFrameWithTitleCount(count : Int){
        self.addSubview(slider)
        slider.backgroundColor = UIColor.SSBlue
        slider.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width / CGFloat(count))
            make.height.equalTo(sliderHeight)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(CGFloat(selectedIndex) * (self.frame.width / CGFloat(count)))
        }
    }
    
    func updateTitles(titleArray : [String]){
        if titleArray.count > titileButArray.count { return }
        var i = 0
        for title in titleArray {
            titileButArray[i].setTitle(title, for: UIControlState.normal)
            i = i + 1
        }
        
    }
    
    @objc func tapTitle(button:UIButton){
        selectedHandler?(button.tag)
        for titleBtn in titileButArray {
            if titleBtn.isEqual(button){
                titleBtn.isSelected = true
            }else{
                titleBtn.isSelected = false
            }
        }
        slider.snp.updateConstraints { (make) in
            make.left.equalTo(button.frame.origin.x)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
    }

}
