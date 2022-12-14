//
//  Parentvc.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/19.
//

import UIKit
import MapKit
import CoreLocation

protocol TLLotteryListDataSource: AnyObject {
    func passDataFromParent() -> [TLLotteryInfo]
}
// TL 
class TLParentViewController: UIViewController {
    // MARK: - Property
    // enum chnage better
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
    
    private var m_listLotteriesInfo = [TLLotteryInfo]()
    private lazy var m_vcMapView = TLLotteryStoresMapViewController()
    private lazy var m_vcLotteryStoreList = TLLotteryStoresListViewController()
    private lazy var m_btnChange: UIBarButtonItem = {
        let barButtomItem = UIBarButtonItem(image: UIImage.switchModeMapMode,
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
            // string ????????????
            let alertController = UIAlertController(
                title: LString("AlertInfo:NavigationTitle"),
                message: LString("AlertInfo:NavigationMessage"),
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: LString("AlertAction:Confirmed"), style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
        
        // location start
        setupNavgation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadMapData(_:)),
            name: .notifyChangeDistance,
            object: nil )
        add(childViewController: m_vcMapView,
            to: self.view)
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: navigationsetting
    private func setupNavgation() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkOrangeColor]
        self.navigationItem.title = LString("Text:Nearest Lottery Stores")
        let barButtomItem = m_btnChange
        self.navigationItem.setRightBarButton(barButtomItem, animated: true)
    }
    
    @objc private func changechildViewController() {
        // change selection
        if self.navigationItem.rightBarButtonItem?.image == UIImage.switchModeMapMode {
            self.navigationItem.rightBarButtonItem?.image =
            UIImage.switchModeListMode
            //            mapViewvc.willMove(toParent: nil)
            //            mapViewvc.removeFromParent()
            add(childViewController: m_vcLotteryStoreList,
                to: self.view)
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage.switchModeMapMode
            //            lotteryStoreListvc.willMove(toParent: nil)
            //            lotteryStoreListvc.removeFromParent()
            add(childViewController: m_vcMapView,
                to: self.view)
        }
    }
    
    @objc private func reloadMapData( _ notification: NSNotification) {
        guard let changeNumber = notification.object as? LotteryDistances else { return }
        m_changeDistance = Double(changeNumber.rawValue)
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

extension TLParentViewController: CLLocationManagerDelegate {
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
    
    // CreateRequestBody
    // MARK: ParentVC to MapVC and ListVC
    func getAPIData(latitude: CLLocationDegrees,
                    longtitude: CLLocationDegrees,
                    distance: Double) {
        TLHttpClient.shared.lotteryAPI(
            method: .post, TLStationRequestDTO(lat: latitude, lon: longtitude, distance: distance), url: URL(string: TLWSPathHome.Station.urlPath())!) { [weak self] (result: Result<TLResponse<TLLotteryStores>, TLNetworkErrorConditions>) in
                switch result {
                case .success(let decodedData):
                    self?.m_listLotteriesInfo = decodedData.content?.list.sorted(by: { $0.distance < $1.distance }) ?? []
                    self?.m_vcMapView.configureFromParent()
                    self?.m_vcLotteryStoreList.configureFromParent()
                case .failure(let errordata):
                    // UIAlert error handling
                    let alertController = UIAlertController(
                        title: LString(errordata.type), message: "",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: LString("AlertAction:Confirmed"), style: .default, handler: nil)
                    alertController.addAction(okAction)
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true, completion: nil)
                    }
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
                title: LString("AlertInfo:NavigationTitle"),
                message: LString("AlertInfo:NavigationMessage"),
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: LString("AlertAction:Confirmed"), style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension TLParentViewController: TLLotteryListDataSource {
    func passDataFromParent() -> [TLLotteryInfo] {
        return self.m_listLotteriesInfo
    }
}

// MARK: Navigation Map
extension TLParentViewController: TLPassoutNavigationDelegate {
    func requestNavigation(location: CLLocationCoordinate2D) {
        let kAppleMaps = kAppleMaps
        guard let str = String(format: kAppleMaps, location.latitude, location.longitude).addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        UIApplication.shared.openURL(str)
    }
}
