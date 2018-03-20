//
//  PlaceChooserViewController.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/18/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import UIKit

protocol PlaceChooserProtocol {
    func placeChosen(place: RecordingPlace)
}

class PlaceChooserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: PlaceChooserProtocol?
    
    @objc func back(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    lazy var headerView: PlaceHeader = {
        let header = PlaceHeader()
        header.backgroundColor = color
        header.placeName = "Pick a place"
        return header
    }()
    
    private var selectPlaceConstraint: NSLayoutConstraint?
    private lazy var selectPlaceView: UIView = {
        let l = UIButton(type: .system)
        l.layer.cornerRadius = 5.0
        l.layer.masksToBounds = true
        l.setTitle("Select this place", for: .normal)
        l.titleLabel?.textAlignment = .center
        l.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .heavy)
        l.setTitleColor(color, for: .normal)
        l.backgroundColor = color.withAlphaComponent(0.3)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.addTarget(self, action: #selector(selectPlace), for: .touchUpInside)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(l)
        view.addVisualConstraint("H:|[v0]|", views: ["v0": l])
        view.addVisualConstraint("V:|-(8@750)-[v0(64@750)]-(14@750)-|", views: ["v0": l])
        
        return view
    }()
    
    @objc fileprivate func selectPlace() {
        if let idx = selectedPlaceIdx {
            let placeChosen: RecordingPlace = places[idx]
            delegate?.placeChosen(place: placeChosen)
            presentingViewController?.dismiss(animated: true)
        }
    }
    
    var collectionView: UICollectionView!
    var tableView: UITableView!
    let tableCellId = "TableCellId"
    let collectionCellId = "CollectionCellId"
    let color = Constants.colors.midPurple
    
    var places: [RecordingPlace] = [] {
        didSet {
            selectedPlaceIdx = nil
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    var placeTypes: [RecordingPlaceType] = [] {
        didSet {
            selectedPlaceTypeIdx = nil
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    var selectedPlaceTypeIdx: Int? {
        didSet {
            if let idx = selectedPlaceTypeIdx {
                let placetype = placeTypes[idx].type
                places = RecordingPlace.getRecordingPlaces(for: placetype)
                selectPlaceConstraint?.isActive = true
                selectPlaceView.alpha = 0.0
            }
        }
    }
    var selectedPlaceIdx: Int? {
        didSet {
            selectPlaceConstraint?.isActive = false
            selectPlaceView.alpha = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeTypes = RecordingPlace.getRecordingPlaceTypes()
        
        RecordingPlace.updateIfNeeded(force: true) { [weak self] in
            self?.placeTypes = RecordingPlace.getRecordingPlaceTypes()
        }
        
        self.tabBarController?.tabBar.isHidden = false
        
        // set up the collection view
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let cellWidth = ((UIScreen.main.bounds.width) - 42 - 30 ) / 3
        layout.itemSize = CGSize(width: cellWidth, height: 75)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        collectionView.register(PlaceTypeCell.self, forCellWithReuseIdentifier: collectionCellId)
        
        // set up the table view
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        
        tableView.register(PlaceChooserCell.self, forCellReuseIdentifier: tableCellId)
        
        // Enable keyboard notifications when showing and hiding the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupNavBarButtons()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(selectPlaceView)
        
        // add constraints
        view.addVisualConstraint("H:|[v0]|", views: ["v0": headerView])
        view.addVisualConstraint("H:|[v0]|", views: ["v0": collectionView])
        view.addVisualConstraint("H:|[v0]|", views: ["v0": tableView])
        view.addVisualConstraint("H:|-14-[v0]-14-|", views: ["v0": selectPlaceView])
        view.addVisualConstraint("V:|[header(100)][v0(200)]-14-[v1]-[v2]|", views: ["header": headerView, "v0": collectionView, "v1": tableView, "v2": selectPlaceView])
        
        selectPlaceConstraint = NSLayoutConstraint(item: selectPlaceView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        selectPlaceConstraint?.isActive = true
        selectPlaceView.alpha = 0.0
    }

    func setupNavBarButtons() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "angle-left")!.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = Constants.colors.superLightGray
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    // MARK: - CollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath) as! PlaceTypeCell
        
        let placeType = placeTypes[indexPath.item]
        cell.displayText = placeType.type
        cell.nameLabel.textColor = Constants.colors.lightGray
        cell.icon = placeType.icon
        cell.iconView.color = Constants.colors.lightGray
        cell.iconView.imageColor = .white
        
        if selectedPlaceTypeIdx != nil && indexPath.item == selectedPlaceTypeIdx {
            cell.color = color
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let idx = selectedPlaceTypeIdx {
            let cell = collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as! PlaceTypeCell
            cell.iconView.color = Constants.colors.lightGray
            cell.nameLabel.textColor = Constants.colors.lightGray
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! PlaceTypeCell
        cell.iconView.color = color
        cell.nameLabel.textColor = color
        selectedPlaceTypeIdx = indexPath.item
    }
    
    // MARK: - TableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellId, for: indexPath) as! PlaceChooserCell
        
        let place = places[indexPath.item]
        cell.color = color
        cell.displayText = place.name
        cell.icon = place.icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlaceIdx = indexPath.item
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        tableView.keyboardRaised(height: keyboardFrame.height)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        tableView.keyboardClosed()
    }

}

class PlaceChooserCell :  UITableViewCell {
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var iconView: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "metro")!.withRenderingMode(.alwaysTemplate))
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    var displayText: String? { didSet {
        nameLabel.text = displayText
        }}
    
    var icon: String? { didSet {
        iconView.image = UIImage(named: icon!)!.withRenderingMode(.alwaysTemplate)
        }}
    
    var color: UIColor = Constants.colors.primaryLight { didSet {
        iconView.tintColor = color
        }}
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(iconView)
        
        // add constraints
        addVisualConstraint("V:|-[v0(20)]", views: ["v0": iconView])
        addVisualConstraint("H:|-[v0(20)]-[v1]-|", views: ["v0": iconView, "v1": nameLabel])
        addVisualConstraint("V:|[v0]|", views: ["v0": nameLabel])
    }
}

class PlaceTypeCell :  UICollectionViewCell {
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var iconView: RoundIconView = {
        return RoundIconView(image: UIImage(named: "bus")!, color: Constants.colors.midPurple, imageColor: Constants.colors.lightPurple, diameter: 40.0)
    }()
    
    var displayText: String? { didSet {
        nameLabel.text = displayText
        }}
    
    var icon: String? { didSet {
        iconView.image = UIImage(named: icon!)!.withRenderingMode(.alwaysTemplate)
        }}
    
    var color: UIColor = Constants.colors.primaryLight { didSet {
        iconView.tintColor = color
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(iconView)
        
        // add constraints
        iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconView.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true
        addVisualConstraint("H:|-[v0]-|", views: ["v0": nameLabel])
        addVisualConstraint("V:|[v0(40)]-(>=8)-[v1]|", views: ["v0": iconView, "v1": nameLabel])
    }
}
