//
//  TheRouterControllerE32.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/11/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TheRouter
import SnapKit

class TheRouterControllerE32: UIViewController {

    // 扫码完成回调
    public var qrResultCallBack: QrScanResultCallBack?
    
    public lazy var resultLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 15)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .purple
        self.view.addSubview(resultLabel)
    
        resultLabel.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(200)
            make.center.equalTo(self.view.center)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            
            guard let _resultCallBack = self.qrResultCallBack else { return }
            _resultCallBack("扫码回调了", false)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TheRouterControllerE32: TheRouterable {
    static var patternString: [String] {
        ["scheme://router/demoE32"]
    }
    
    static func registerAction(info: [String : Any]) -> Any {
        
        let vc =  TheRouterControllerE32()
        vc.qrResultCallBack = info["clouse"] as? QrScanResultCallBack
        vc.resultLabel.text = info.description
        return vc
    }
    
    static var priority: UInt {
        TheRouterDefaultPriority
    }
}
