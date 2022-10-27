//
//  LotteryStoreTableViewController.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/18.
//

import UIKit
import MapKit

class LotteryStoresListViewController: UIViewController {
    // MARK: property
    private lazy var m_lotteryInfoCollectionView: UICollectionView = {
        let layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            return layout
        }()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(
            UINib(nibName: "LotteryStoreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "LotteryStoreCollectionViewCell")
        collection.backgroundColor = UIColor(red: 234, green: 234, blue: 234)
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    weak var lotteryListDatasource: LotteryListDatasource?
    weak var navigationLocaitonDelegate: PassoutNavigationDelegate?
// MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    // MARK: - UI setup (Helper)
    func setupUI() {
        view.addSubview(m_lotteryInfoCollectionView)
        m_lotteryInfoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate( [
            m_lotteryInfoCollectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            m_lotteryInfoCollectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            m_lotteryInfoCollectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            m_lotteryInfoCollectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor)])
    }
    // MARK: configure function from ParentView
    func configureFromParent() {
        DispatchQueue.main.async {
            self.m_lotteryInfoCollectionView.reloadData()
        }
    }
}
// MARK: - CollectionDelegate
extension LotteryStoresListViewController: UICollectionViewDelegate {
}

// MARK: - DataSource

extension LotteryStoresListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let lotteryListDatasource = lotteryListDatasource?.passDataFromParent() else {
            return 0 }
        return lotteryListDatasource.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "LotteryStoreCollectionViewCell",
                for: indexPath) as? LotteryStoreCollectionViewCell else { return UICollectionViewCell()  }
            guard let listLottery =  lotteryListDatasource?.passDataFromParent() else { return UICollectionViewCell() }
            cell.backgroundColor = .white
            cell.delegate = self
            cell.layer.cornerRadius = 5
            cell.configure(
            lotteryName: listLottery[indexPath.row].name,
            lotteryAddress: listLottery[indexPath.row].address,
            lotteryDistance: listLottery[indexPath.row].distance,
            lon: listLottery[indexPath.row].lon,
            lat: listLottery[indexPath.row].lat)
            return cell
    }
}

extension LotteryStoresListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 2 * 16, height: collectionView.frame.height/8)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 60, bottom: 0, right: 60)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10 } }

// MARK: - LotteryStorecvCellDelegate Navigation

extension LotteryStoresListViewController:
    LotteryStorecvCellDelegate {
    func passLocaitonInfo(location: Location) {
        let targetLocation = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        navigationLocaitonDelegate?.requestNavigation(location: targetLocation)
    }
}
