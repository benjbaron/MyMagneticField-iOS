//
//  RecordListViewController.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/19/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

struct RecordedPlace {
    let name: String
    let epoch: Int
    let place: RecordingPlace
    let url: URL
    var uploaded: Bool = false
    
    func getDatePhrase() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        return "Recorded on \(date.dateToDayLetterString()) at \(date.dateToTimePeriodString())"
    }
}


class RecordListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, RecordingItemDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var color: UIColor = Constants.colors.midPurple {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    var collectionView: UICollectionView!
    let collectionCellId = "collectionCellId"
    let collectionHeaderCellId = "collectionHeaderCellId"
    var files:[URL] = [] {
        didSet {
            places.removeAll()
            for url in files {
                if let place = getRecordedPlace(from: url) {
                    let fname = url.deletingPathExtension().lastPathComponent
                    places[fname] = place
                }
            }
        }
    }
    var uploadedFiles: [String] = [] {
        didSet {
            for file in uploadedFiles {
                places[file]?.uploaded = true
            }
            self.collectionView.reloadData()
        }
    }
    var places: [String: RecordedPlace] = [:] {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    func getRecordedPlace(from url: URL) -> RecordedPlace? {
        let fname = url.deletingPathExtension().lastPathComponent
        let fields = fname.split(separator: "_")
        let placeId = fields[1]
        let epoch = Int(fields[2])!
        if let place = RecordingPlace.getRecordingPlace(with: String(placeId)) {
            return RecordedPlace(name: place.name, epoch: epoch, place: place, url: url, uploaded: false)
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the collection view
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let cellWidth = ((UIScreen.main.bounds.width) - 20) // for the margins
        layout.itemSize = CGSize(width: cellWidth, height: 90)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 100)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView.register(RecordingItem.self, forCellWithReuseIdentifier: collectionCellId)
        collectionView.register(RecordingsHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: collectionHeaderCellId)

        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        files = FileService.shared.listFiles()
        uploadedFiles = Settings.getUploadedFiles()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        let margins = self.view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: margins.topAnchor)
        ])
        
        view.addVisualConstraint("H:|[v0]|", views: ["v0": collectionView])
        view.addVisualConstraint("V:[collection]|", views: ["collection": collectionView])
    }
    
    // MARK: - CollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath) as! RecordingItem
        
        let placeURLs = places.keys.sorted(by: { $0 < $1 })
        let placeIdx = placeURLs[indexPath.item]
        let place = places[placeIdx]!
        cell.color = color
        cell.place = place
        cell.iconView.image = UIImage(named: place.place.icon)!.withRenderingMode(.alwaysTemplate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionHeaderCellId, for: indexPath) as! RecordingsHeader
            return headerCell
        } else {
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    // MARK: - RecordingItemDelegate method
    func didUploadFile(with url: URL) {
        uploadedFiles = Settings.getUploadedFiles()
        appDelegate.updateRecordList()
    }
    
}

protocol RecordingItemDelegate {
    func didUploadFile(with url: URL)
}

class RecordingItem : UICollectionViewCell {
    var delegate: RecordingItemDelegate?
    
    var color: UIColor = Constants.colors.midPurple {
        didSet {
            backgroundColor = color.withAlphaComponent(0.3)
            iconView.color = color
            uploadButton.tintColor = color
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = color
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "subtitle goes here"
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = color
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var iconView: RoundIconView = {
        return RoundIconView(image: UIImage(named: "map-marker")!.withRenderingMode(.alwaysTemplate), color: color, imageColor: .white, diameter: 40.0)
    }()
    
    lazy var uploadButton: UIButton = {
        let button   = UIButton(type: .system) as UIButton
        button.tintColor = color
        button.addTarget(self, action: #selector(upload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc fileprivate func upload() {
        if let url = place?.url {
            FileService.upload(file: url) { [weak self] _ in
                let fname =  url.deletingPathExtension().lastPathComponent
                Settings.addUploadedFile(fname: fname)
                self?.uploadButton.setImage(UIImage(named: "check")!.withRenderingMode(.alwaysTemplate), for: .normal)
                self?.uploadButton.isEnabled = false
                self?.delegate?.didUploadFile(with: url)
            }
            
        }
    }
    
    var place: RecordedPlace? {
        didSet {
            if let place = place {
                titleLabel.text = place.name
                subtitleLabel.text = place.getDatePhrase()
                if place.uploaded {
                    uploadButton.setImage(UIImage(named: "check")!.withRenderingMode(.alwaysTemplate), for: .normal)
                    uploadButton.isEnabled = false
                } else {
                    uploadButton.setImage(UIImage(named: "arrow-up")!.withRenderingMode(.alwaysTemplate), for: .normal)
                    uploadButton.isEnabled = true
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(iconView)
        addSubview(uploadButton)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        iconView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        uploadButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        // add constraints
        addVisualConstraint("H:|-14-[icon]-14-[text]-[upload]-14-|", views: ["icon": iconView, "text": stackView, "upload": uploadButton])
        addVisualConstraint("V:|-14-[text]-(>=8)-|", views: ["text": stackView])
        
        iconView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        uploadButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        backgroundColor = color.withAlphaComponent(0.3)
    }
}

class RecordingsHeader : UICollectionViewCell {
    var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Recordings"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(mainTitle)
        
        addVisualConstraint("H:|[v0]|", views: ["v0": mainTitle])
        addVisualConstraint("V:|-48-[v0(40)]-12-|", views: ["v0": mainTitle])
    }
}
