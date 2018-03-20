//
//  HelperFunctions.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/18/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

class IconView: UIView {
    
    var icon: String? = "profile" {
        didSet {
            imageView.image = UIImage(named: icon!)!.withRenderingMode(.alwaysTemplate)
            imageView.layoutIfNeeded()
        }
    }
    
    var iconColor: UIColor? = Constants.colors.primaryDark {
        didSet {
            imageView.tintColor = iconColor
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: icon!)!.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = iconColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(icon: String?, iconColor: UIColor?) {
        self.init(frame: CGRect.zero)
        
        self.icon = icon
        self.iconColor = iconColor
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setupViews() {
        addSubview(imageView)
        
        addVisualConstraint("V:|[v0]|", views: ["v0": imageView])
        addVisualConstraint("H:|[v0]|", views: ["v0": imageView])
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}


class RoundIconView: UIView {
    var iconDiameter: CGFloat = 30.0
    var scale: CGFloat = 0.75
    var fill: Bool = true
    
    var color: UIColor! {
        didSet {
            if fill {
                shapeLayer.fillColor = color.cgColor
            } else {
                shapeLayer.strokeColor = color.cgColor
            }
            imageView.layoutIfNeeded()
        }
    }
    
    var image: UIImage! {
        didSet {
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            imageView.layoutIfNeeded()
        }
    }
    
    var imageColor: UIColor! {
        didSet {
            imageView.tintColor = imageColor
            imageView.layoutIfNeeded()
        }
    }
    
    lazy var shapeLayer: CAShapeLayer = {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: iconDiameter, height: iconDiameter))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        if fill {
            shapeLayer.fillColor = color.cgColor
            shapeLayer.lineWidth = 0
        } else {
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 2
        }
        
        return shapeLayer
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.tintColor = imageColor
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (1.0-scale)/2*iconDiameter, y: (1.0-scale)/2*iconDiameter, width: scale*iconDiameter, height: scale*iconDiameter)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(image: UIImage, color: UIColor, imageColor: UIColor, diameter: CGFloat = 30.0, scale: CGFloat = 0.75, fill: Bool = true) {
        self.init(frame: CGRect.zero)
        
        self.image = image
        self.color = color
        self.imageColor = imageColor
        self.iconDiameter = diameter
        self.scale = scale
        self.fill = fill
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setupViews() {
        self.layer.addSublayer(shapeLayer)
        self.addSubview(imageView)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}


class PlaceHeader: UIView {
    var placeName : String? {
        didSet {
            placeNameLabel.text = placeName
        }
    }
    
    internal let placeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "place name"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setupViews() {
        addSubview(placeNameLabel)
        
        // add constraints
        addVisualConstraint("V:|-(28@750)-[title]-(14@750)-|", views: ["title": placeNameLabel])
        
        addVisualConstraint("H:|-75-[title]-75-|", views: ["title": placeNameLabel])
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

