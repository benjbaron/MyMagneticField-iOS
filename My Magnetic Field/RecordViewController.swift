//
//  RecordViewController.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/17/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

class RecordViewController: UIViewController, PlaceChooserProtocol {
    
    var color: UIColor = Constants.colors.orange
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var minutesLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 70, weight: .heavy)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var secondsLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 70, weight: .heavy)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var colonLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 70, weight: .heavy)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startStopButton: UIButton = {
        let l = UIButton(type: .system)
        l.layer.cornerRadius = 5.0
        l.layer.masksToBounds = true
        l.setTitle("Start", for: .normal)
        l.titleLabel?.textAlignment = .center
        l.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .heavy)
        l.setTitleColor(color, for: .normal)
        l.backgroundColor = color.withAlphaComponent(0.3)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.addTarget(self, action: #selector(tappedStartStop), for: .touchUpInside)
        return l
    }()
    
    private lazy var pickPlaceButton: UIButton = {
        let l = UIButton(type: .system)
        l.layer.cornerRadius = 5.0
        l.layer.masksToBounds = true
        l.setTitle("Pick a place", for: .normal)
        l.titleLabel?.textAlignment = .center
        l.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .heavy)
        l.setTitleColor(color, for: .normal)
        l.backgroundColor = color.withAlphaComponent(0.3)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.addTarget(self, action: #selector(pickPlace), for: .touchUpInside)
        return l
    }()
    
    private lazy var selectedPlaceIcon: RoundIconView = {
        return RoundIconView(image: UIImage(named: "map-marker")!.withRenderingMode(.alwaysTemplate), color: color, imageColor: .white, diameter: 40.0)
    }()
    
    private lazy var selectPlaceLabel: UILabel = {
        let label = UILabel()
        label.text = "No place selected"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func updateTimer() {
        seconds += 1
        if let place = selectedPlace, let epoch = recordingStartDate?.timeIntervalSince1970 {
            DataCollectionService.shared.collectData(place: place, epoch: Int(epoch))
        }
    }
    
    @objc fileprivate func tappedStartStop() {
        if isTimerRunning {
            timer.invalidate()
            DataCollectionService.shared.stopDataCollection()
            recordingStartDate = nil
            startStopButton.setTitle("Start", for: .normal)
            pickPlaceButton.isEnabled = true
            isTimerRunning = false
            appDelegate.updateRecordList()
            endBackgroundTask()
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
            DataCollectionService.shared.startDataCollection()
            recordingStartDate = Date()
            startStopButton.setTitle("Stop", for: .normal)
            pickPlaceButton.isEnabled = false
            isTimerRunning = true
            seconds = 0
            registerBackgroundTask()
        }
    }
    
    @objc fileprivate func pickPlace() {
        let controller = PlaceChooserViewController()
        controller.delegate = self
        
        let controllerNavigation = UINavigationController(rootViewController: controller)
        self.present(controllerNavigation, animated: true, completion: nil)
    }
    
    var selectedPlace: RecordingPlace? {
        didSet {
            if let name = selectedPlace?.name, let icon = selectedPlace?.icon {
                selectPlaceLabel.text = name
                selectedPlaceIcon.image = UIImage(named: icon)!.withRenderingMode(.alwaysTemplate)
                pickPlaceButton.setTitle("Pick another place", for: .normal)
            } else {
                pickPlaceButton.setTitle("Pick a place", for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    var seconds = 0 {
        didSet {
            let secStr = String(format: "%02d", seconds % 60)
            let minStr = String(format: "%02d", Int(floor(Double(seconds) / 60.0)))
            minutesLabel.text = "\(minStr)"
            secondsLabel.text = "\(secStr)"
        }
    }
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var recordingStartDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(minutesLabel)
        view.addSubview(secondsLabel)
        view.addSubview(colonLabel)
        view.addSubview(startStopButton)
        view.addSubview(pickPlaceButton)
        
        selectedPlaceIcon.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        selectedPlaceIcon.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        let stackView = UIStackView(arrangedSubviews: [selectedPlaceIcon, selectPlaceLabel])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        colonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        minutesLabel.centerYAnchor.constraint(equalTo: colonLabel.centerYAnchor).isActive = true
        secondsLabel.centerYAnchor.constraint(equalTo: colonLabel.centerYAnchor).isActive = true
        
        view.addVisualConstraint("H:[min][col][sec]", views: ["min": minutesLabel, "col": colonLabel, "sec": secondsLabel])
        view.addVisualConstraint("H:|-14-[v0]-14-|", views: ["v0": startStopButton])
        view.addVisualConstraint("H:|-14-[v0]-14-|", views: ["v0": pickPlaceButton])
        view.addVisualConstraint("H:|-14-[v0]-14-|", views: ["v0": stackView])
        view.addVisualConstraint("V:|-150-[v0(100)]-100-[v1(64)]-14-[v2(64)]-14-[v3]-(>=8)-|", views: ["v0": colonLabel, "v1": startStopButton, "v2":pickPlaceButton, "v3": stackView])
    }
    
    func placeChosen(place: RecordingPlace) {
        print("place chosen")
        selectedPlace = place
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}
