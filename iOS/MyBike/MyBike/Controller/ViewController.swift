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
    
    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager = CLLocationManager()
//    mapView.delegate = self
//    var mapV = MKMapView()
//    var mapView = MKMapViewDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        if checkUserAuthorization(){
            locationManager.startUpdatingLocation()
            
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        getBikeLocationDetails(urlString: BIKEDETAILS_URL)
        
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

        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.myMap.setRegion(region, animated: true)
        }
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = locValue
        myAnnotation.title = "Bike"
        myAnnotation.subtitle = "current location"
        self.myMap.addAnnotation(myAnnotation)
        locationManager.stopUpdatingLocation()
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
                
                
                var locationcoordinate : CLLocationCoordinate2D
                
                for child in locations{
                    locationcoordinate = CLLocationCoordinate2D(latitude: Double(child.end_lat)!, longitude: Double(child.end_long)!)
                    
                    print(locationcoordinate)
                    self.addAnnotation(coordinate: locationcoordinate, title: "test", subtitle: "testtype")
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
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String, subtitle: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        myMap.addAnnotation(annotation)
    }
   
     func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = myMap.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "bike")
        annotationView!.image = pinImage
        
        return annotationView
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

