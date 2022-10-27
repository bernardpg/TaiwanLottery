//
//  Parentvc.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/19.
//

import UIKit
import MapKit
import CoreLocation
// pop datasource // return true number
protocol LotteryListDatasource: AnyObject {
    func passDataFromParent() -> [LotteryInfo]
}

class ParentViewController: UIViewController {
    private var m_changeDistance = 1.0 {
        didSet {
            getAPIData(
                latitude: m_currentLocation?.coordinate.latitude ?? 0,
                longtitude: m_currentLocation?.coordinate.longitude ?? 0,
                distance: m_changeDistance)
        }
    }
    private var m_listLotteriesInfo = [LotteryInfo]()// LotteryStores(list: [])
    // MARK: - Property
    private lazy var m_mapViewViewController = LotteryStoresMapViewController()
    let url = URL(string: "https://smuat.megatime.com.tw/taiwanlottery/api/Home/Station")!
    private lazy var m_lotteryStoreListViewController = LotteryStoresListViewController()
    private lazy var m_changeButton: UIBarButtonItem = {
        let barButtomItem = UIBarButtonItem(image: UIImage(named: "switchModeMapMode"),
            style: .plain, target: self,
            action: #selector(changechildViewController))
        barButtomItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return barButtomItem
    }()
    private var m_locationManager: CLLocationManager = CLLocationManager()
    private var m_currentLocation: CLLocation?
    var m_authorizationStatus: CLAuthorizationStatus?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // custom datasource
        m_mapViewViewController.mapLotteryListDatasource = self
        m_lotteryStoreListViewController.lotteryListDatasource = self
        m_mapViewViewController.navigationLocaitonDelegate = self
        m_lotteryStoreListViewController.navigationLocaitonDelegate = self
        // location manager
        m_locationManager.delegate = self
        if #available(iOS 14, *) {
            m_authorizationStatus = m_locationManager.authorizationStatus
        } else {
            m_authorizationStatus = m_locationManager.authorizationStatus
        }
        switch m_authorizationStatus {
        case .notDetermined:
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.desiredAccuracy = kCLLocationAccuracyBest
            m_locationManager.distanceFilter = kCLHeadingFilterNone
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.startUpdatingLocation()
//            m_locationManager.stopUpdatingLocation()
// First time lanch app need to get authorize from user
          fallthrough
        case .authorizedWhenInUse:
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.desiredAccuracy = kCLLocationAccuracyBest
            m_locationManager.distanceFilter = kCLHeadingFilterNone
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.startUpdatingLocation()
//            m_locationManager.stopUpdatingLocation()

        case .denied:
          let alertController = UIAlertController(
            title: "定位權限已關閉",
            message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
            preferredStyle: .alert)
          let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
        default:
          break }
        // location start
        setupNavgation()
        let notificationName = Notification.Name("changeDistance")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadMapData(_:)),
            name: notificationName,
            object: nil )
        add(childViewController: m_mapViewViewController,
            to: self.view)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: navigationsetting
    private func setupNavgation() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.init(rgb: 0xE6813C)]
        self.navigationItem.title = "附近投注站"
        let barButtomItem = m_changeButton
        self.navigationItem.setRightBarButton(barButtomItem, animated: true)
    }
    @objc private func changechildViewController() {
        // change selection
        if self.navigationItem.rightBarButtonItem?.image == UIImage(named: "switchModeMapMode") {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "switchModeListMode")
//            mapViewvc.willMove(toParent: nil)
//            mapViewvc.removeFromParent()
            add(childViewController: m_lotteryStoreListViewController,
                to: self.view)
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "switchModeMapMode")
//            lotteryStoreListvc.willMove(toParent: nil)
//            lotteryStoreListvc.removeFromParent()
            add(childViewController: m_mapViewViewController,
                to: self.view)
        }
    }
    @objc private func reloadMapData( _ notification: NSNotification) {
        guard let changeNumber = notification.object as? Double else { return }
        m_changeDistance = changeNumber
    }
}

// MARK: childVC  UI Setup

extension UIViewController {
    func add(childViewController viewController: UIViewController, to contentView: UIView) {
        let matchParentConstraints = [
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewController.view)
        NSLayoutConstraint.activate(matchParentConstraints)
        viewController.didMove(toParent: self)
    }
    // MARK: make sure deinit
    func remove(childViewController viewController: UIViewController) {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

// MARK: - fetch current(Location)

extension ParentViewController: CLLocationManagerDelegate {
    // MARK: API currentLocation MAPkit current location and fetch data on this
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { m_currentLocation = locations.last }
        if m_currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                print(userLocation.coordinate)
                getAPIData(
                    latitude: userLocation.coordinate.latitude,
                    longtitude: userLocation.coordinate.longitude,
                    distance: 1)
            }
        }
    }
    // MARK: ParentVC to MapVC and ListVC
    func getAPIData(latitude: CLLocationDegrees,
                    longtitude: CLLocationDegrees,
                    distance: Double) {
        HttpClient.shared.postAPILottery(
            url: url, lat: latitude, lon: longtitude,
            distance: distance) { [weak self] createUserResponse
                in
                self?.m_listLotteriesInfo = createUserResponse.content.list.sorted(by: { $0.distance < $1.distance })
                self?.m_mapViewViewController.configureFromParent()
                self?.m_lotteryStoreListViewController.configureFromParent()
        }
    }
}

extension ParentViewController: LotteryListDatasource {
    func passDataFromParent() -> [LotteryInfo] {
        return self.m_listLotteriesInfo
    }
}
// MARK: Navigation Map
extension ParentViewController: PassoutNavigationDelegate {
    func requestNavigation(location: CLLocationCoordinate2D) {
        let kAppleMaps = "https://maps.apple.com/?saddr=Current Location&daddr=%f,%f&z=10&t=s"
        guard let str = String(format: kAppleMaps, location.latitude, location.longitude).addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) else {
                return
        }
        UIApplication.shared.openURL(str)
    }
}
