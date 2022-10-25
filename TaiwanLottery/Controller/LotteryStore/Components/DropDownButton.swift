//
//  DropDownButton.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/20.
//

import UIKit

protocol DropDownProtocol: AnyObject {
    func dropDownPressed( string: String )
}

class DropDownBtn: UIButton, DropDownProtocol {
    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        let myNumbers = string.filter { "0123456789".contains($0) }
        NotificationCenter.default.post(name: notificationChange, object: Double(myNumbers))
        self.dismissDropDown()
    }
    var dropView = DropDownView()
    let notificationChange = Notification.Name("changeDistance")
    var height = NSLayoutConstraint()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(rgb: 0xE6813C)
        dropView = DropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            isOpen = true
            NSLayoutConstraint.deactivate([self.height])
                self.height.constant = self.dropView.tableView.contentSize.height
            NSLayoutConstraint.activate([self.height])
            UIView.animate( withDuration: 0.5, delay: 0,
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    var dropDownOptions = [String]()
    var tableView = UITableView()
    weak var delegate: DropDownProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DropDownTableViewCell.self, forCellReuseIdentifier: DropDownTableViewCell.reuseIdentifier)
        self.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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
        cell.configureUI(title: dropDownOptions[indexPath.row] )
        cell.layer.cornerRadius = 5
        cell.backgroundColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        30
    }
}
