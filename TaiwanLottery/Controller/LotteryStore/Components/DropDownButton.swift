//
//  DropDownButton.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/20.
//

import UIKit

protocol DropDownProtocol: AnyObject {
    func dropDownPressed(_ distance: LotteryDistances)
}

class DropDownBtn: UIButton, DropDownProtocol {
    
    var dropView = DropDownView()
    var height = NSLayoutConstraint()
    var isOpen = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkOrangeColor
        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            isOpen = true
            NSLayoutConstraint.deactivate([self.height])
                self.height.constant = self.dropView.tvDropdown.contentSize.height
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5, options: .curveEaseInOut,
                           animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)
        } else {
            isOpen = false
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5, options: .curveEaseInOut,
                           animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func dropDownPressed(_ distance: LotteryDistances) {
        self.setTitle(LStringFormat("Text:Intkm", distance.rawValue), for: .normal)
        // ideal enum selected (傳enum)
        NotificationCenter.default.post(name: .notifyChangeDistance, object: distance)
        self.dismissDropDown()
    }

    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    // allcase enumtype
    var dropDownOptions = [LotteryDistances]()
    var tvDropdown = UITableView()
    weak var delegate: DropDownProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tvDropdown.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        tvDropdown.delegate = self
        tvDropdown.dataSource = self
        tvDropdown.translatesAutoresizingMaskIntoConstraints = false
        tvDropdown.register(DropDownTableViewCell.self, forCellReuseIdentifier: DropDownTableViewCell.reuseIdentifier)
        self.addSubview(tvDropdown)
        tvDropdown.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tvDropdown.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tvDropdown.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tvDropdown.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DropDownTableViewCell.reuseIdentifier,
            for: indexPath) as? DropDownTableViewCell else { return UITableViewCell()  }
        // 公里 多國語系
        cell.configureUI(title: LStringFormat("Text:Intkm", dropDownOptions[indexPath.row].rawValue))
        cell.layer.cornerRadius = 5
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownPressed( dropDownOptions[indexPath.row])
        self.tvDropdown.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        30
    }
}
