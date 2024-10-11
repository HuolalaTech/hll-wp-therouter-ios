//
//  LARouterController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 11/10/2021.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter
import SnapKit

class LARouterPresentController: UIViewController, TheRouterable {
    
    
    @objc public var name: String?
    
    @objc public var value: String?
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var resultLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 15)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    
    @objc
    func backButtonClick() {
        self.dismiss(animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        self.view.addSubview(backBtn)
    
        backBtn.snp.makeConstraints { make in
            make.left.equalTo(self.view.snp.left).offset(40)
            make.top.equalTo(self.view.snp.top).offset(100)
            make.width.height.equalTo(48)
        }
        
        self.view.addSubview(resultLabel)
    
        resultLabel.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(200)
            make.center.equalTo(self.view.center)
        }
        
        print("\(self.name) -- \(self.value)")
    }

    public static var patternString: [String] {
        ["scheme://router/class_prex_test"]
    }

    
    static func registerAction(info: [String : Any]) -> Any {
        debugPrint(info)
        
        let vc =  LARouterPresentController()
        vc.resultLabel.text = info.debugDescription
        return vc
    }
}
