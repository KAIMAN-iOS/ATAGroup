//
//  File.swift
//  
//
//  Created by GG on 29/01/2021.
//

import UIKit
import Ampersand
import LabelExtension

class DisclaimerHeader: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!  {
        didSet {
            label.set(text: "group list disclaimer".bundleLocale(), for: .footnote, textColor: GroupListViewController.configuration.palette.mainTexts)
        }
    }
}
