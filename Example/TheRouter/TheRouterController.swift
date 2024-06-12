//
//  TheRouterViewController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/3/8.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TheRouter
import SnapKit

public typealias QrScanResultCallBack = (_ qrResult: String, _ isSucess: Bool) -> Void

class TheRouterController: UIViewController {

    // 扫码完成回调
   @objc public var qrResultCallBack: TheRouerParamsClosureWrapper?
    
    private lazy var resultLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 15)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(resultLabel)
    
        resultLabel.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(200)
            make.center.equalTo(self.view.center)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            
            guard let _resultCallBack = self.qrResultCallBack?.closure else { return }
            _resultCallBack(("扫码回调了", false))
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TheRouterController: TheRouterable {
    
    static var patternString: [String] {
        ["scheme://router/demo"]
    }
    
}
