//
//  ViewController.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//

import UIKit
import MapKit
import CoreLocation

// login -> User location -> 第一個 no pin
// 滑到  collectionview -> pin 變色
// bool 偵測

// 附近投注站預設位置
protocol PassoutNavigationDelegate: AnyObject {
    func requestNavigation(location: CLLocationCoordinate2D)
}

class LotteryStoresMapViewController: UIViewController {
    var button = DropDownBtn()
    // MARK: Properties
    private lazy var m_mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    private var m_kSelectedRow: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                let indexPath = NSIndexPath(item: self.m_kSelectedRow, section: 0)
//                self.m_lotteryInfocv.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                for (index, item) in  (self.m_mapView.annotations).enumerated() {
                    if  index == self.m_kSelectedRow {
                        print(index)
                        print(item.coordinate)
                        self.m_mapView.selectAnnotation(item, animated: true)
                    }
                }
            }
        }
    }
    weak var mapLotteryListDatasource: LotteryListDatasource?
    weak var navigationLocaitonDelegate: PassoutNavigationDelegate?
    private var m_routeCoordinates: [CLLocation] = []
    private lazy var m_cvLotteryInfo: UICollectionView = {
        let layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
            let itemWidth = UIScreen.main.bounds.width - (35 * 2)
            layout.itemSize = CGSize(width: itemWidth, height: 90)
            return layout
        }()
//        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(
            UINib(nibName: "LotteryStoreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "LotteryStoreCollectionViewCell")
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    let url = URL(string: "https://smuat.megatime.com.tw/taiwanlottery/api/Home/Station")!
    private var m_locationManager: CLLocationManager = CLLocationManager()
    private var m_currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        m_mapView.delegate = self
        m_mapView.showsUserLocation = true
        m_cvLotteryInfo.delegate = self
        m_cvLotteryInfo.dataSource = self
        m_cvLotteryInfo.allowsMultipleSelection = true
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
// First time lanch app need to get authorize from user
          fallthrough
        case .authorizedWhenInUse:
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.desiredAccuracy = kCLLocationAccuracyBest
            m_locationManager.distanceFilter = kCLHeadingFilterNone
            m_locationManager.requestWhenInUseAuthorization()
            m_locationManager.startUpdatingLocation()

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
//        m_locationManager.stopUpdatingLocation()
        setupUI()
    }
    // MARK: - UI setup (Helper)
    func setupUI() {
        view.addSubview(m_mapView)
        m_mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            m_mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            m_mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            m_mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            m_mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        m_mapView.addSubview(m_cvLotteryInfo)
        m_cvLotteryInfo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            m_cvLotteryInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            m_cvLotteryInfo.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            m_cvLotteryInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            m_cvLotteryInfo.heightAnchor.constraint(equalTo: m_cvLotteryInfo.widthAnchor, multiplier: 1.0/5.0)
        ])
        button = DropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle(" 1 公里", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFang TC", size: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        // Add Button to the View Controller
        self.view.addSubview(button)
        // button Constraints
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor,
            constant: 140).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,
            constant: -UIScreen.main.bounds.width + 100 ).isActive = true
        button.layer.cornerRadius = 5
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.dropView.dropDownOptions = ["5公里", "2公里", "1公里"]
    }
    // MARK: configure function from ParentView
    func configureFromParent() {
        DispatchQueue.main.async {
                    self.updateCoordinate()
                    self.addPins()
                    self.m_cvLotteryInfo.reloadData()
        }
    }
}
// MARK: - MapKit Pin (local location)
extension LotteryStoresMapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        defer { m_currentLocation = locations.last }
        if m_currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    latitudinalMeters: 1500,
                    longitudinalMeters: 1500)
                m_mapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    func updateCoordinate() {
        m_routeCoordinates = []
        guard let listLottery =  mapLotteryListDatasource?.passDataFromParent() else { return }
        for lottery in listLottery {
            let loc = CLLocation(latitude: lottery.lat,
                                 longitude: lottery.lon)
            m_routeCoordinates.append(loc)
        }
    }
    // addPins
    func addPins() {
        let allAnnotaitons = self.m_mapView.annotations
        self.m_mapView.removeAnnotations(allAnnotaitons)
        if m_routeCoordinates.count != 0 {
            for (index, location) in m_routeCoordinates.enumerated() {
                let lotteriesPin = CustomPointAnnotation()
                lotteriesPin.coordinate = CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude)
                print(lotteriesPin.coordinate.latitude)
                lotteriesPin.lotteryId = index
                m_mapView.addAnnotation(lotteriesPin)
            }
        }
    }
    // Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil {
            // Create View
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            // Assign Annotation
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "mapPinOff")
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotationview ID 去判斷
        let region = MKCoordinateRegion(
            center: view.annotation!.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        view.image = UIImage(named: "mapPinOn")
        guard let listLottery =  mapLotteryListDatasource?.passDataFromParent() else { return }
/*        for annotationsItem in m_mapView.annotations {
            if annotationsItem.coordinate.latitude ==
                listLottery[indexPath.row].lat {
                self.m_mapView.selectAnnotation(annotationsItem, animated: true)
            }
        }
*/
        for (index, item) in listLottery.enumerated() {
            guard let lat = view.annotation?.coordinate.latitude else { return }
            guard let lon = view.annotation?.coordinate.longitude else { return }
            print(lat, lon)
            if item.lon == lon && item.lat == lat {
                let path = IndexPath(item: index, section: 0)
                print(index)
                m_cvLotteryInfo.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
            }
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "mapPinOff")
    }
}

// MARK: - CollectionView FlowLayout

extension LotteryStoresMapViewController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
            guard let layout = m_cvLotteryInfo.collectionViewLayout as? UICollectionViewFlowLayout else { return   }
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing // Calculate cell size
            
            let offset = scrollView.contentOffset.x
            let index = (offset + scrollView.contentInset.left) / cellWidthIncludingSpacing // Calculate the cell need to be center

            if velocity.x > 0 { // Scroll to -->
                targetContentOffset.pointee = CGPoint(x: ceil(index) * cellWidthIncludingSpacing - scrollView.contentInset.right, y: -scrollView.contentInset.top)
            } else if velocity.x < 0 { // Scroll to <---
                targetContentOffset.pointee = CGPoint(x: floor(index) * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            } else if velocity.x == 0 { // No dragging
                targetContentOffset.pointee = CGPoint(x: round(index) * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            }
        }
}

// MARK: - CollectionViewDelegate
extension LotteryStoresMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let listLottery =  mapLotteryListDatasource?.passDataFromParent() else { return }
        for annotationsItem in m_mapView.annotations {
            if annotationsItem.coordinate.latitude ==
                listLottery[indexPath.row].lat {
                self.m_mapView.selectAnnotation(annotationsItem, animated: true)
            }
        }
    }
}

// MARK: - Colleciton View DataSource
extension LotteryStoresMapViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        guard let listLottery =  mapLotteryListDatasource?.passDataFromParent() else { return 0 }
        return listLottery.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LotteryStoreCollectionViewCell",
            for: indexPath) as? LotteryStoreCollectionViewCell
                else { return UICollectionViewCell()  }
            guard let listLottery =  mapLotteryListDatasource?.passDataFromParent()
                else { return UICollectionViewCell() }
            cell.layer.cornerRadius = 5
            cell.delegate = self
            cell.configure(
            lotteryName: listLottery[indexPath.row].name,
            lotteryAddress: listLottery[indexPath.row].address,
            lotteryDistance: listLottery[indexPath.row].distance,
            lon: listLottery[indexPath.row].lon,
            lat: listLottery[indexPath.row].lat)
            return cell
    }
}

// MARK: - LotteryStorecvCellDelegate Navigation
// StoreMapViewController 
extension LotteryStoresMapViewController: LotteryStorecvCellDelegate {
    func passLocaitonInfo(location: Location) {
        let targetLocation = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        navigationLocaitonDelegate?.requestNavigation(location: targetLocation)
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var lotteryId: Int?
}
