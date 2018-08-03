//
//  SolarCalculatorVC.swift
//  SolarCalculator
//
//  Created by Manjeet Singh on 24/07/18.
//  Copyright © 2018 Manjeet Singh. All rights reserved.
//

import UIKit
import MapKit



class SolarCalculatorVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var currentLocationBtn: UIButton?
    @IBOutlet weak var locationsList: UIButton?
    @IBOutlet weak var locationLbl: UILabel?
    @IBOutlet weak var locationSearchBar: UISearchBar?
    
    @IBOutlet weak var risesetView: UIView?
    @IBOutlet weak var sunRiseLbl: UILabel?
    @IBOutlet weak var sunSetLbl: UILabel?
    
    @IBOutlet weak var dayLbl: UILabel?
    @IBOutlet weak var searchResultsTableView: UITableView?
    
    var dateInput:Date = Date()
    lazy var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var selectedDate = Date()
    var selectedLocation :CLLocationCoordinate2D = CLLocationCoordinate2D()
    @IBOutlet weak var sunStatus: UIView?
    var locationManager = CLLocationManager()
    var isInitailUpdateCurrentLocation = false
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView?.delegate = self
        mapView?.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        let scale = MKScaleView(mapView: mapView)
        scale.scaleVisibility = .visible // always visible
        view.addSubview(scale)
         searchCompleter.delegate = self
        searchResultsTableView?.isHidden = true
        setCurrentDate()
        
    }
    
    func setCurrentDate(){
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDate = dateFormatterGet.string(from: Date())
        dateInput = Date()
        dayLbl?.text = currentDate
         getSolarTime()
    }
    
    
    func getSolarTime(){
        
        let solar = Solar(for: dateInput, coordinate: selectedLocation)
        print(dateInput)
        print(selectedLocation)
        print(solar?.sunrise)
        print(solar?.sunset)
        
        let sunrise = solar?.sunrise
        let sunset = solar?.sunset
        
        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatterGet.dateFormat = "hh:mm a"
        let sunRiseStr = dateFormatterGet.string(from: sunrise!)
        let sunSetStr = dateFormatterGet.string(from: sunset!)
        
        sunSetLbl?.text = sunSetStr
        sunRiseLbl?.text = sunRiseStr
        
    }
    
     @IBAction func SetCurrentLocation(_ sender: UIButton) {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            mapView?.setRegion(region, animated: true)
    }
    
    
    @IBAction func SetCurrentDate(_ sender: UIButton) {
        
        dateInput = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMMM dd, yyyy"
        let dateStr = dateFormatterGet.string(from: dateInput)
        dayLbl?.text = dateStr
    }
    
    @IBAction func SetNextDate(_ sender: UIButton) {
        dateInput = dateInput.addingTimeInterval(TimeInterval(86400.0))
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMMM dd, yyyy"
        let dateStr = dateFormatterGet.string(from: dateInput)
        print(dateStr)
        dayLbl?.text = dateStr
        getSolarTime()
    
    }
    
    @IBAction func SetPreviousDate(_ sender: UIButton) {
        dateInput = dateInput.addingTimeInterval(TimeInterval(-86400.0))
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMMM dd, yyyy"
        let dateStr = dateFormatterGet.string(from: dateInput)
        print(dateStr)
        dayLbl?.text = dateStr
        getSolarTime()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SolarCalculatorVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        let mapCordinate = mapView.centerCoordinate
        selectedLocation = mapCordinate
        let mapLocation  = CLLocation(latitude: mapCordinate.latitude, longitude: mapCordinate.longitude)
        print(mapCordinate)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(mapLocation, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            var addressStr = ""
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                print(formattedAddress.joined(separator: ", "))
                addressStr = addressStr +  formattedAddress.joined(separator: ", ")
            }
            self.locationLbl?.text = addressStr
            
        })
        
        getSolarTime()
        view.endEditing(true)
    }
}

extension SolarCalculatorVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last?.coordinate
        currentLocation = location!
        if isInitailUpdateCurrentLocation == false{
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location!, span: span)
            mapView?.setRegion(region, animated: true)
            isInitailUpdateCurrentLocation = true
        }
    }
}


extension SolarCalculatorVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            searchResultsTableView?.isHidden = true
        }else{
        searchCompleter.queryFragment = searchText
            searchResultsTableView?.isHidden = false
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        view.endEditing(true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        view.endEditing(true)
    }
    
}

extension SolarCalculatorVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView?.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension SolarCalculatorVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension SolarCalculatorVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        locationLbl?.text = completion.title
        
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            print(String(describing: coordinate))
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: coordinate!, span: span)

            self.mapView?.setRegion(region, animated: true)
            
        }
        searchResultsTableView?.isHidden = true
        view.endEditing(true)
        locationSearchBar?.text = nil
    }
}

