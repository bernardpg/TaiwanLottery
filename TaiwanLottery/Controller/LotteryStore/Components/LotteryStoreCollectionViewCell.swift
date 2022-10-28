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
    private var m_location = Location(lat: 0, lon: 0)
    weak var delegate: LotteryStorecvCellDelegate?
    private var m_logitude: Double?
    private var m_latitude: Double?
    @IBOutlet weak var lbLotteryName: UILabel!
    @IBOutlet weak var lbLotteryDistance: UILabel!
    @IBOutlet weak var lbLotteryAddress: UILabel!
    @IBOutlet weak var btnLotteryNavigaton: UIButton!
    // MARK: init
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        if #available(iOS 15, *) {
            // not work
            self.btnLotteryNavigaton.configuration?.imagePlacement = .top
            btnLotteryNavigaton.configuration?.titleAlignment = .automatic
        } else {
            btnLotteryNavigaton.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -(btnLotteryNavigaton.imageView?.frame.size.width ?? 0),
                bottom: -(btnLotteryNavigaton.imageView?.frame.size.height ?? 0),
                right: 0)
            btnLotteryNavigaton.imageEdgeInsets = UIEdgeInsets(
                top: -(btnLotteryNavigaton.titleLabel?.intrinsicContentSize.height ?? 0),
                left: 0,
                bottom: 0,
                right: -(btnLotteryNavigaton.titleLabel?.intrinsicContentSize.width ?? 0))
        }
        btnLotteryNavigaton.layer.cornerRadius = 5
        btnLotteryNavigaton.setImage(UIImage.iconDirection, for: .normal)
        self.lbLotteryName.textColor = UIColor.darkOrangeColor
        self.lbLotteryDistance.textColor = UIColor.darkOrangeColor
        self.btnLotteryNavigaton.backgroundColor = UIColor.lightOrangeColor
    }
    
    @IBAction func lotteryNavigationBtnPress(_ sender: Any) {
        m_location.lon = m_logitude ?? 0
        m_location.lat = m_latitude ?? 0
        delegate?.passLocaitonInfo(location: m_location)
    }
    
    func configure(lotteryName: String, lotteryAddress: String, lotteryDistance: Double, lon: Double, lat: Double) {
        self.lbLotteryName.text = lotteryName
        self.lbLotteryAddress.text = lotteryAddress
        self.lbLotteryDistance.text = "\(lotteryDistance) 公里"
        self.btnLotteryNavigaton.setTitle("導航", for: .normal)
        self.m_logitude = lon
        self.m_latitude = lat
    }
}
