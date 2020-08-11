//
//  CollectionViewListCell.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
import UIKit
import Combine

let imageCache = NSCache<NSString, UIImage>()
class CollectionViewListCell: UICollectionViewListCell {
    var user: UserViewModel!
    var cancellable: AnyCancellable?
    //User role image View
    let userRoleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    //activity indicator on image
    let activityIndicator: UIActivityIndicatorView = {
        let actind = UIActivityIndicatorView()
        actind.translatesAutoresizingMaskIntoConstraints = false
        actind.hidesWhenStopped = true
        actind.tintColor = UIColor(white: 0.90, alpha: 1.0)
        actind.style = .medium
        actind.startAnimating()
        return actind
    }()
    
    //list contentView
    lazy var listContentView = UIListContentView(configuration: self.getSubtitleConfiguration())
    //tupple of constraints
    var constraintsApplied: (imageLeadingConstraints: NSLayoutConstraint, viewTrailingConstraint: NSLayoutConstraint)?
    //MARK:- View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    // UICellConfigurationState key
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = user
        return state
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        addViewAndApplyConstraints()
        var stateConfig = self.defaultContentConfiguration().updated(for: state)
        if let item =  state.item  {
            //1.
            stateConfig.image = UIImage(named: "default-logo")
            if let image = imageCache.object(forKey: item.avatar as NSString) {
                stateConfig.image = image
                self.activityIndicator.isHidden = true
            }
            else {
                cancellable = NetworkRequest.imagePublisher(for: item.avatar).sink { (completion) in
                    self.activityIndicator.isHidden = true
                } receiveValue: { (image) in
                    stateConfig.image = image
                    imageCache.setObject(image, forKey: item.avatar as NSString)
                    self.activityIndicator.isHidden = true
                }
            }
            stateConfig.text = item.name
            stateConfig.textProperties.font = UIFont.systemFont(ofSize: 16.0)
            stateConfig.secondaryText = item.role.rawValue
            stateConfig.imageProperties.preferredSymbolConfiguration = .init(font: stateConfig.textProperties.font, scale: .large)
            self.listContentView.configuration = stateConfig
            //2.
            let valueCellConfig = UIListContentConfiguration.valueCell().updated(for: state)
            self.userRoleImageView.image = self.getImage(for: item.role)
            self.userRoleImageView.tintColor = valueCellConfig.imageProperties.resolvedTintColor(for: tintColor)
            self.userRoleImageView.preferredSymbolConfiguration = .init(font: valueCellConfig.secondaryTextProperties.font, scale: .large)
            
            //3.
            self.constraintsApplied?.imageLeadingConstraints.constant = valueCellConfig.textToSecondaryTextHorizontalPadding
            self.constraintsApplied?.viewTrailingConstraint.constant = stateConfig.directionalLayoutMargins.trailing
        }
    }
    
    //MARK:- Add imageview on content view
    fileprivate func addSubViewOnContentView() {
        self.listContentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.listContentView)
        self.contentView.addSubview(self.userRoleImageView)
        self.contentView.addSubview(self.activityIndicator)
    }
    
    //MARK:- Add views and apply constraints
    fileprivate func addViewAndApplyConstraints() {
        guard self.constraintsApplied == nil else {
            return
        }
        //1.
        self.addSubViewOnContentView()
        //2.
        let applyConstraints = (imageLeadingConstraints: self.userRoleImageView.leadingAnchor.constraint(equalTo: self.listContentView.trailingAnchor), viewTrailingConstraint: self.contentView.trailingAnchor.constraint(equalTo: self.userRoleImageView.trailingAnchor))
        //3.
        NSLayoutConstraint.activate([
            self.listContentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.listContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.listContentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.userRoleImageView.centerYAnchor),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.userRoleImageView.centerXAnchor),
            self.userRoleImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            applyConstraints.imageLeadingConstraints,
            applyConstraints.viewTrailingConstraint
        ])
        self.constraintsApplied = applyConstraints
    }
    
    //MARK:- Update view with user
    func update(for user: UserViewModel) {
        self.user = user
        setNeedsUpdateConfiguration()
    }
    //MARK:- Get UIList Content Configuration
    fileprivate func getSubtitleConfiguration() -> UIListContentConfiguration {
        return .subtitleCell()
    }
    
    //MARK:- Get  image as per user role
   fileprivate func getImage(for role: Role) -> UIImage {
        switch role {
        case .Admin:
            return UIImage(systemName: "person.fill.and.arrow.left.and.arrow.right")!
        case .Owner:
            return UIImage(systemName: "person.fill.badge.plus")!
        case .User:
            return UIImage(systemName: "person.2.fill")!
        case .notAvailable:
            return UIImage(systemName: "person.crop.circle.badge.questionmark")!
        }
    }
}

//MARK:- UIConfigurationStateCustomKey
extension UIConfigurationStateCustomKey {
    static var key = UIConfigurationStateCustomKey("user")
}

//MARK:- UIConfigurationState
extension UIConfigurationState {
    var item: UserViewModel? {
        set {
            self[.key] = newValue
        }
        get {
            return self[.key] as? UserViewModel
        }
    }
}
