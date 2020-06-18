//
//  DocumentViewController.swift
//  assign4
//
//  Created by Kevin Nogales on 4/22/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DocumentViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var document: GPX436Document?
    
    
    @IBOutlet var closeButtonOutlet: UIButton!
    @IBOutlet var distanceOutlet: UILabel!
    @IBOutlet var speedOutlet: UILabel!
    @IBOutlet var mapSegmentOutlet: UISegmentedControl!
    @IBOutlet var currentLocationButton: UIButton!
    
    @IBOutlet var mapOutlet: MKMapView!
    var locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    var viewMode: Bool = true
    var viewModeRegion: MKCoordinateRegion?
    var centerMapFlag: Bool = true
    
    
    
    @IBAction func currentLocationAction(_ sender: UIButton) {
        if self.viewMode {
            self.mapOutlet.setRegion(viewModeRegion!, animated: true)
        } else {
            self.centerMapFlag = true
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        // Resume Ride
        // Cancel Ride
        // Save
        
        
        if self.viewMode {
            print("Success clsing file in view mode.")
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: "Please select a ride option.",
                message: "Canceling will delete ride.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "Resume Ride",
                style: .default,
                handler: nil)
            )
            
            alert.addAction(UIAlertAction(
                title: "Cancel Ride",
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true) {
                        self.document?.close(completionHandler: { success in
                            if success {
                                do {
                                    self.locationManager.stopUpdatingLocation()
                                    try FileManager.default.removeItem(at: self.document!.fileURL)
                                } catch let error {
                                    print("Failed canceling ride.")
                                    print(error)
                                }
                            } else {
                                print("Failed closing file without saving.")
                            }
                        })
                    }
            }))
            
            alert.addAction(UIAlertAction(
                title: "Save Ride",
                style: .default,
                handler: { (action: UIAlertAction!) in
                    
                    self.locationManager.stopUpdatingLocation()
                    self.mapOutlet.showsUserLocation = false
                    
                    let alert1 = UIAlertController(
                        title: "Saving ride.",
                        message: "Please enter a name for the current ride.",
                        preferredStyle: .alert
                    )
                    
                    
                    alert1.addTextField(configurationHandler: { (textfield) in
                        textfield.text = String(Date().description(with: .current))
                        
                    })
                    
                    alert1.addAction(UIAlertAction(
                        title: "Okay",
                        style: .default,
                        handler: { (action: UIAlertAction!) in
                            
                            self.dismiss(animated: true) {
                                self.document?.updateChangeCount(.done)
                                self.document?.close(completionHandler: { success in
                                    if success {
                                        print("Success closing file in view mode.")
                                        
                                        let fileName = alert1.textFields![0].text!.replacingOccurrences(of: " ", with: "_")
                                        
                                        if fileName.count != 0 {
                                            let newDocURL = try? FileManager.default.url(
                                                for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true
                                            ).appendingPathComponent(fileName + ".gpx436")
                                            
                                            if newDocURL != nil && self.document?.fileURL != nil {
                                                do {
                                                    try FileManager.default.moveItem(at: self.document!.fileURL.absoluteURL, to: newDocURL!.absoluteURL)
                                                } catch let error {
                                                    print("failed to change filename.")
                                                    print(error)
                                                    
                                                    let newDocURLCopy = try? FileManager.default.url(
                                                        for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true
                                                    ).appendingPathComponent(fileName + "_copy" + ".gpx436")
                                                    
                                                    do {
                                                        try FileManager.default.moveItem(at: self.document!.fileURL.absoluteURL, to: newDocURLCopy!.absoluteURL)
                                                    } catch let error1 {
                                                        print("failed due to error: ")
                                                        print(error1)
                                                    }
                                                    
                                                    
                                                    print("changed file name.")
                                                }
                                            }
                                        }

                                    } else {
                                        print("Failed saving file.")
                                    }
                                })
                            }
                    }))
                    
                    self.present(alert1, animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    @IBAction func segmentSwitch(_ sender: UISegmentedControl) {
        switch mapSegmentOutlet.selectedSegmentIndex {
        case 1:
            self.mapOutlet.mapType = .satellite
        default:
            self.mapOutlet.mapType = .standard
        }
    }
    
    override func viewDidLoad() {
        self.mapOutlet.delegate = self
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(turnOffRegionUpdate))
        swipeUp.direction = .up
        self.mapOutlet.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(turnOffRegionUpdate))
        swipeDown.direction = .down
        self.mapOutlet.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(turnOffRegionUpdate))
        swipeLeft.direction = .left
        self.mapOutlet.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(turnOffRegionUpdate))
        swipeRight.direction = .right
        self.mapOutlet.addGestureRecognizer(swipeRight)
        
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 10)
    }
    
    @objc func turnOffRegionUpdate() {
        self.centerMapFlag = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                if let container = self.document?.container {
                    if container.distance == 0 {
                        self.viewMode = false
                        self.mapOutlet.showsUserLocation = true
                        self.startTracking()
                    } else {
                        self.viewMode = true
                        
                        self.locationManager.stopUpdatingLocation()
                        
                        //print("COORDINATE POINTS:")
                        //print(container.points)
                        
                        self.mapOutlet.showsUserLocation = false
                        self.distanceOutlet.text = String(format: "%.2f miles", Double(container.distance))
                        self.speedOutlet.text = "-"
                        
                        
                        
                        var coords = container.points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                        coords.removeFirst()
                        
                        let minLat = coords.map { $0.latitude }.min()!
                        let maxLat = coords.map { $0.latitude }.max()!
                        let minLong = coords.map { $0.longitude }.min()!
                        let maxLong = coords.map { $0.longitude }.max()!
                        
                        let midLat = (minLat + maxLat) / 2
                        let midLong = (minLong + maxLong) / 2
                        
                        let maxPoint = MKMapPoint(CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong))
                        let minPoint = MKMapPoint(CLLocationCoordinate2D(latitude: minLat, longitude: minLong))
                        let distancePoints = maxPoint.distance(to: minPoint)
                        
                        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: midLat, longitude: midLong), latitudinalMeters: distancePoints, longitudinalMeters: distancePoints)
                        self.viewModeRegion = region
                        self.mapOutlet.setRegion(region, animated: true)
                        
                        
                        let poly = MKPolyline(coordinates: coords, count: coords.count)
                        self.mapOutlet.addOverlay(poly)
                        
                        
                    }
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    
    private func startTracking() {
        let status = CLLocationManager.authorizationStatus()
        
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            print("already approved.")
            locationManager.startUpdatingLocation()
        } else {
            print("need to request.")
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("erro: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.startTracking()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updating location.")
        
        if self.viewMode == false {
            if self.previousLocation == nil {
                self.previousLocation = locations.first
                self.document!.container!.points.append(GPX436Point(lat: self.previousLocation!.coordinate.latitude, long: self.previousLocation!.coordinate.longitude))
            } else {
                
                guard let latest = locations.first else {
                    return
                }
                
                print(latest.coordinate)
                
                self.document!.container!.points.append(GPX436Point(lat: latest.coordinate.latitude, long: latest.coordinate.longitude))
                
                let distanceInMeters = previousLocation?.distance(from: latest) ?? 0
                let distanceInMiles = distanceInMeters * 3.28 / 5280
                self.document?.container?.distance += CGFloat(distanceInMiles)
                
                let duration = latest.timestamp.timeIntervalSince(previousLocation!.timestamp)
                let speed = distanceInMiles * (3600.0 / duration)
                
                self.distanceOutlet.text = String(format: "%.2f miles", Double((self.document?.container!.distance)!))
                self.speedOutlet.text = String(format: "%.1f mph", speed)
                            
                let coords = [previousLocation!.coordinate] + locations.map { $0.coordinate }
                
                let minLat = coords.map { $0.latitude }.min()!
                let maxLat = coords.map { $0.latitude }.max()!
                let minLong = coords.map { $0.longitude }.min()!
                let maxLong = coords.map { $0.longitude }.min()!
                
                let midLat = (minLat + maxLat) / 2
                let midLong = (minLong + maxLong) / 2
                
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: midLat, longitude: midLong), latitudinalMeters: 500, longitudinalMeters: 500)
                
                if self.centerMapFlag {
                    self.mapOutlet.setRegion(region, animated: true)
                }
                
                let poly = MKPolyline(coordinates: coords, count: coords.count)
                self.mapOutlet.addOverlay(poly)
                
                previousLocation = latest
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: poly)
            renderer.lineWidth = 3
            renderer.strokeColor = .red
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
    func centerMap(loc: CLLocationCoordinate2D) {
        let radius: CLLocationDistance = 300
        let region = MKCoordinateRegion(center: loc, latitudinalMeters: radius, longitudinalMeters: radius)
        
        self.mapOutlet.setRegion(region, animated: true)
    }
}
