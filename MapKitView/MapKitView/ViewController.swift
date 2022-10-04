//
//  ViewController.swift
//  MapKitView
//
//  Created by perfil on 04/10/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textEndereco: UITextField!
    @IBOutlet weak var btnEndereco: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        /*let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 41.890251, longitude: 12.492373)
        annotation.title = "O Coliseu"
        annotation.subtitle = "A casa dos gladiadores"
        mapView.addAnnotation(annotation)*/
        
        let region = MKCoordinateRegion(center: locationManager.location?.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        //mapView.setRegion(region, animated: true)
    }
    
    @IBAction func Buscar(_ sender: Any) {
        localizarEndereco()
    }
    
    func localizarEndereco(){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(textEndereco.text!){
            placemarks, error in guard let placemarks = placemarks, let location = placemarks.first?.location
            else{
                print("Não encontrei o endereço")
                return
            }
            print(location)
            self.rota(destinationCord: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func rota(destinationCord: CLLocationCoordinate2D){
        let sourceCordinate = (locationManager.location?.coordinate)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { response, error in guard let response = response
            else{
                if let error = error{
                    print("Alguma coisa deu errada \(error.localizedDescription)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

