//
//  DropDownTableViewCell.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/20.
//

import UIKit

class TLDropDownTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "\(TLDropDownTableViewCell.self)"
    private lazy var m_lbTitle: UILabel = {
        let label =  UILabel()
        label.font = UIFont.pinFangTC
        label.numberOfLines = 0
        label.textColor = UIColor.darkOrangeColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    func configureUI(title: String) {
        m_lbTitle.text = title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(m_lbTitle)
        m_lbTitle.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        m_lbTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        m_lbTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        m_lbTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    // trace code 
    required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}
