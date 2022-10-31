//
//  Parentvc.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/19.
//

import UIKit
import MapKit
import CoreLocation

protocol LotteryListDataSource: AnyObject {
    func passDataFromParent() -> [LotteryInfo]
}

class ParentViewController: UIViewController {
    private var m_changeDistance = 1.0 {
        didSet { 
            if m_defaultLocation != nil {
                getAPIData(
                    latitude: m_defaultLocation?.coordinate.latitude ?? 0,
                    longtitude: m_defaultLocation?.coordinate.longitude ?? 0,
                    distance: m_changeDistance)
            } else if m_currentLocation != nil { getAPIData(
                    latitude: m_currentLocation?.coordinate.latitude ?? 0,
                    longtitude: m_currentLocation?.coordinate.longitude ?? 0,
                    distance: m_changeDistance)
            }
        }
    }
    
    private var m_listLotteriesInfo = [LotteryInfo]()// LotteryStores(list: [])
    // MARK: - Property
    private lazy var m_vcMapView = LotteryStoresMapViewController()
    
    let url = URL(string: "https://smuat.megatime.com.tw/taiwanlottery/api/Home/Station")!
    private lazy var m_vcLotteryStoreList = LotteryStoresListViewController()
    private lazy var m_btnChange: UIBarButtonItem = {
        let barButtomItem = UIBarButtonItem(image: UIImage(named: "switchModeMapMode"),
            style: .plain, target: self,
            action: #selector(changechildViewController))
        barButtomItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return barButtomItem
    }()
    private var m_locationManager: CLLocationManager = CLLocationManager()
    private var m_currentLocation: CLLocation?
    private var m_defaultLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // custom datasource
        m_vcMapView.mapLotteryListDatasource = self
        m_vcLotteryStoreList.lotteryListDatasource = self
        m_vcMapView.navigationLocaitonDelegate = self
        m_vcLotteryStoreList.navigationLocaitonDelegate = self
        // location manager
        m_locationManager.delegate = self
        if #available(iOS 14, *) {
            authorizationStatus = m_locationManager.authorizationStatus
        } else {
            authorizationStatus = m_locationManager.authorizationStatus
        }
        switch authorizationStatus {
        case .notDetermined:
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.desiredAccuracy = kCLLocationAccuracyBest
            m_locationManager.distanceFilter = kCLHeadingFilterNone
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.startUpdatingLocation()
          fallthrough
        case .authorizedWhenInUse:
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.desiredAccuracy = kCLLocationAccuracyBest
            m_locationManager.distanceFilter = kCLHeadingFilterNone
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.startUpdatingLocation()
        case .denied:
            m_defaultLocation = CLLocation(latitude: 25.0338, longitude: 121.5647)
            getAPIData(
                latitude: m_defaultLocation?.coordinate.latitude ?? 0,
                longtitude: m_defaultLocation?.coordinate.longitude ?? 0, distance: 1)
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
        add(childViewController: m_vcMapView,
            to: self.view)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(m_locationManager.authorizationStatus)
//        locationManagerDidChangeAuthorization(m_locationManager)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: navigationsetting
    private func setupNavgation() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkOrangeColor]
        self.navigationItem.title = "附近投注站"
        let barButtomItem = m_btnChange
        self.navigationItem.setRightBarButton(barButtomItem, animated: true)
    }
    @objc private func changechildViewController() {
        // change selection
        if self.navigationItem.rightBarButtonItem?.image == UIImage(named: "switchModeMapMode") {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "switchModeListMode")
//            mapViewvc.willMove(toParent: nil)
//            mapViewvc.removeFromParent()
            add(childViewController: m_vcLotteryStoreList,
                to: self.view)
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "switchModeMapMode")
//            lotteryStoreListvc.willMove(toParent: nil)
//            lotteryStoreListvc.removeFromParent()
            add(childViewController: m_vcMapView,
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
                getAPIData(
                    latitude: userLocation.coordinate.latitude,
                    longtitude: userLocation.coordinate.longitude,
                    distance: 1)
                self.m_locationManager.stopUpdatingLocation()
            }
        } else {
        }
    }
    // MARK: ParentVC to MapVC and ListVC
    func getAPIData(latitude: CLLocationDegrees,
                    longtitude: CLLocationDegrees,
                    distance: Double) {
        TLHttpClient.shared.postAPILottery(
            url: url, lat: latitude, lon: longtitude,
            distance: distance) { [weak self] (result: Result<TLResponse<LotteryStores>, NetworkErrorConditions>) in
                switch result {
                case .success(let decodedData):
                    self?.m_listLotteriesInfo = decodedData.content?.list.sorted(by: { $0.distance < $1.distance }) ?? []
                        self?.m_vcMapView.configureFromParent()
                        self?.m_vcLotteryStoreList.configureFromParent()
                case .failure:
                    print("Decode error")
                }
            }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = manager.authorizationStatus
        }
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = kCLHeadingFilterNone
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
          fallthrough
        case .authorizedWhenInUse:
            m_defaultLocation = nil
            m_currentLocation = nil
            manager.requestWhenInUseAuthorization()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = kCLHeadingFilterNone
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        case .denied:
            m_currentLocation = nil
            m_defaultLocation = CLLocation(latitude: 25.0338, longitude: 121.5647)
            getAPIData(
                latitude: m_defaultLocation?.coordinate.latitude ?? 0,
                longtitude: m_defaultLocation?.coordinate.longitude ?? 0, distance: 1)
          let alertController = UIAlertController(
            title: "定位權限已關閉",
            message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
            preferredStyle: .alert)
          let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
        default:
          break }
    }
}
extension ParentViewController: LotteryListDataSource {
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
