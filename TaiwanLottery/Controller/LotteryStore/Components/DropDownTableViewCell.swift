//
//  DropDownTableViewCell.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/20.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {
    static let reuseIdentifier = "\(DropDownTableViewCell.self)"
    private lazy var titleLabel: UILabel = {
        let label =  UILabel()
        label.font = UIFont(name: "PingFang TC", size: 12)
        label.numberOfLines = 0
        label.textColor = UIColor.init(rgb: 0xE6813C)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    func configureUI(title: String) {
        titleLabel.text = title
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        // Initialization code
    }
    required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}
