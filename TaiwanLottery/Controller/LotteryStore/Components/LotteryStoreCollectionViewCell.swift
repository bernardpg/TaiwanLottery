//
//  LotteryStoreCollectionViewCell.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/18.
//

import UIKit

protocol LotteryStorecvCellDelegate: AnyObject {
    // get index 傳cell 可能會造成reuse問題
    func passLocaitonInfo(location: Location)
}

class LotteryStoreCollectionViewCell: UICollectionViewCell {
    var location = Location(lat: 0, lon: 0)
    weak var delegate: LotteryStorecvCellDelegate?
    var logitude: Double?
    var latitude: Double?
    @IBOutlet weak var lotteryName: UILabel!
    @IBOutlet weak var lotteryDistance: UILabel!
    @IBOutlet weak var lotteryAddress: UILabel!
    @IBOutlet weak var lotteryNavigatonBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        if #available(iOS 15, *) {
            // not work
            self.lotteryNavigatonBtn.configuration?.imagePlacement = .top
            lotteryNavigatonBtn.configuration?.titleAlignment = .automatic
        } else {
            lotteryNavigatonBtn.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -(lotteryNavigatonBtn.imageView?.frame.size.width ?? 0),
                bottom: -(lotteryNavigatonBtn.imageView?.frame.size.height ?? 0),
                right: 0)
            lotteryNavigatonBtn.imageEdgeInsets = UIEdgeInsets(
                top: -(lotteryNavigatonBtn.titleLabel?.intrinsicContentSize.height ?? 0),
                left: 0,
                bottom: 0,
                right: -(lotteryNavigatonBtn.titleLabel?.intrinsicContentSize.width ?? 0))
        }
        lotteryNavigatonBtn.layer.cornerRadius = 5
        self.lotteryName.textColor = UIColor.init(rgb: 0xE6813C)
        self.lotteryDistance.textColor = UIColor.init(rgb: 0xE6813C)
        self.lotteryNavigatonBtn.backgroundColor = UIColor.init(rgb: 0xF9B202)
    }
    @IBAction func lotteryNavigationBtnPress(_ sender: Any) {
        location.lon = logitude ?? 0
        location.lat = latitude ?? 0
        delegate?.passLocaitonInfo(location: location)
    }
    func configure(lotteryName: String, lotteryAddress: String, lotteryDistance: Double, lon: Double, lat: Double) {
        self.lotteryName.text = lotteryName
        self.lotteryAddress.text = lotteryAddress
        self.lotteryDistance.text = "\(lotteryDistance) 公里"
        self.lotteryNavigatonBtn.setTitle("導航", for: .normal)
        self.logitude = lon
        self.latitude = lat
    }
}

// 滑動issue // test 允許位置預設動作(預設位置) UIalertController// 預設定位畫面
// Life cycle // coding Style
// ui 跑版 顏色 //  E6813C  F9B202
//  字串 define  ＵＲＬ static // tldefine

// 殘餘cod // unselected  selected and title
// 傳 log lat

// Codind Style function m_
// LotteryViewController
