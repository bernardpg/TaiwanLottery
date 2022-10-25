//
//  LotteryStoresTableViewCell.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/18.
//

import UIKit

class LotteryStoresTableViewCell: UITableViewCell {
    static let reuseIdentifier = "\(LotteryStoresTableViewCell.self)"
    private let lotteryStoreName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let lotteryStoreAddress: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let lotteryStoreDistance: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var m_lotteryNavigationBtn: UIButton = {
        let btn = UIButton()
        return btn
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Action
    // MARK: - UISetting
    func setUpUI() {
        contentView.addSubview(lotteryStoreName)
        contentView.addSubview(lotteryStoreAddress)
        contentView.addSubview(lotteryStoreDistance)
        contentView.addSubview(m_lotteryNavigationBtn)
        lotteryStoreName.translatesAutoresizingMaskIntoConstraints = false
        lotteryStoreAddress.translatesAutoresizingMaskIntoConstraints = false
        lotteryStoreDistance.translatesAutoresizingMaskIntoConstraints = false
        m_lotteryNavigationBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lotteryStoreName.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            lotteryStoreName.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            lotteryStoreAddress.leadingAnchor.constraint(equalTo: lotteryStoreName.leadingAnchor),
            lotteryStoreAddress.topAnchor.constraint(equalTo: lotteryStoreName.bottomAnchor, constant: 10)
            // mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    // MARK: - configure function
    func configureUI() {
    }

}
