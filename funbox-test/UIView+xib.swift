//
//  UIView+xib.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 04.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

extension UIView {
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
}
