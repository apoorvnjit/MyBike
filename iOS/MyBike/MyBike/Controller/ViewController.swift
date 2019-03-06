//
//  ViewController.swift
//  MyBike
//
//  Created by Apoorva Reed(Personal) on 2/5/19.
//  Copyright © 2019 Apoorva Reed(Personal). All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

struct locationdetail: Decodable {
    let end_lat : String
    let start_lat : String
    let biketype : String
    let start_long : String
    let starttime : String
    let end_long : String
    let Distance : String
    let orderid : String
    let userid : String
    let bikeid : String
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let BIKEDETAILS_URL = "http://54.144.157.152/getdata.php"
    
    @IBAction func locateMe(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            myMap.setRegion(viewRegion, animated: true)
            myMap.showsUserLocation = true
            
            deleteAnnotation()
            getBikeLocationDetails(urlString: BIKEDETAILS_URL)
        }
        
    }
//    @IBAction func buttonRefresh(_ sender: Any) {
//
//        //locationManager.startUpdatingLocation()
//        deleteAnnotation()
//        getBikeLocationDetails(urlString: BIKEDETAILS_URL)
//
//    }
    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager = CLLocationManager()
//    mapView.delegate = self
//    var mapV = MKMapView()
//    var mapView = MKMapViewDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            myMap.setRegion(viewRegion, animated: false)
            //myMap.showsUserLocation = true
        }
        
        self.locationManager = locationManager
        
        //DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        //addPolyline()
        addPolygon()
        //}
        
//
//        if checkUserAuthorization(){
//            locationManager.startUpdatingLocation()
//
//        }
//        // Do any additional setup after loading the view, typically from a nib.
//
//        getBikeLocationDetails(urlString: BIKEDETAILS_URL)
        
    }
    func deleteAnnotation(){
        let allAnnotations = self.myMap.annotations
        self.myMap.removeAnnotations(allAnnotations)
        
    }
    func checkUserAuthorization() -> Bool{
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                print("Access granted")
                return true
            case .notDetermined, .restricted, .denied, .authorizedWhenInUse :
                print("Access not granted for always")
                return false
            }
        }else{
            print("Access not granted")
            return false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
//        if let location = locations.last{
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            self.myMap.setRegion(region, animated: true)
//        }
        
        //mapview setup to show user location
        myMap.delegate = self
        myMap.showsUserLocation = true
        myMap.mapType = MKMapType(rawValue: 0)!
        //myMap.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        getBikeLocationDetails(urlString: BIKEDETAILS_URL)
        
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        let myAnnotation = MKPointAnnotation()
//        myAnnotation.coordinate = locValue
//        myAnnotation.title = "Bike"
//        myAnnotation.subtitle = "current location"
//        self.myMap.addAnnotation(myAnnotation)
       //locationManager.stopUpdatingLocation()
        
        
        
        
        //stop updating location, only need user location once to position map.
       // manager.stopUpdatingLocation()
        //CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func getBikeLocationDetails(urlString: String){
        
        // get bike details from the db
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url){(data, response, err) in
            
            guard let data = data else {return}
            do{
                let locations = try JSONDecoder().decode([locationdetail].self, from: data)
                
                print(data)
                var locationcoordinate : CLLocationCoordinate2D
                print(locations)
                for child in locations{
                    locationcoordinate = CLLocationCoordinate2D(latitude: Double(child.end_lat)!, longitude: Double(child.end_long)!)
                    
                   // print(locationcoordinate)
                    self.addAnnotation(coordinate: locationcoordinate, title: child.bikeid, subtitle: child.biketype)
                }
                
            } catch let jsonErr{
                print("Error: ", jsonErr)
            }
            
        }.resume()
    }
    func updateAnnotation(json: JSON){
        //deletenotation()
        //addAnnotation(coordinate: <#T##CLLocationCoordinate2D#>, title: <#T##String#>, subtitle: <#T##String#>)
    }
    
    func addPolyline(){
        let locations = [CLLocation(latitude: 40.737336, longitude: -74.171002), CLLocation(latitude: 40.735841,longitude: -74.166045), CLLocation(latitude: 40.735645, longitude: -74.171964)]
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        myMap?.addOverlay(polyline)
//        let polygon = MKPolygon(coordinates: &coordinates, count: locations.count)
    }
    
    func addPolygon(){
        let locations = [CLLocation(latitude: 40.737336, longitude: -74.171002), CLLocation(latitude: 40.735841,longitude: -74.166045), CLLocation(latitude: 40.734361, longitude: -74.166538), CLLocation(latitude: 40.734930,longitude: -74.169434),CLLocation(latitude: 40.735645, longitude: -74.171964)]
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
          let polygon = MKPolygon(coordinates: &coordinates, count: locations.count)
        myMap?.addOverlay(polygon)

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 3
        return renderer
        
        } else if overlay is MKPolygon {
        let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
        renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
       // renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
        
       return MKOverlayRenderer()
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String, subtitle: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        myMap.addAnnotation(annotation)
    }
   
//     func myMap(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKCircleRenderer(overlay: overlay)
//        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
//        renderer.strokeColor = UIColor.blue
//        renderer.lineWidth = 2
//        return renderer
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("hi i am her")
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
//            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
//            annotationView.image = UIImage(named: "bike")
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: restorationIdentifier)
            annotationView.canShowCallout = true
            let pinImage = UIImage(named: "bike")
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            annotationView.image = resizedImage
            
            return annotationView
        }
        
        
//        if !(annotation is MKPointAnnotation) {
//            return nil
//        }
//
//        let annotationIdentifier = "AnnotationIdentifier"
//        var annotationView = myMap.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView!.canShowCallout = true
//        }
//        else {
//            annotationView!.annotation = annotation
//        }
//
//        let pinImage = UIImage(named: "bike")
//        annotationView!.image = pinImage
//
//        return annotationView
    }
    func setMapRegion(){
//        var getUserLocation: MKUserLocation{
//
//        }
        
//        init(center centerCoordinate: CLLocationCoordinate2D,
//        latitudinalMeters: CLLocationDistance,
//        longitudinalMeters: CLLocationDistance)
    }

}

