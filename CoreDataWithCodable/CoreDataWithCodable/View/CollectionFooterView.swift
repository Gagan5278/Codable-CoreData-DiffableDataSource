//
//  CollectionFooterView.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import UIKit

class CollectionFooterView: UICollectionReusableView {
    //activity indicator on image
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        let actind = UIActivityIndicatorView()
        actind.translatesAutoresizingMaskIntoConstraints = false
        actind.hidesWhenStopped = true
        actind.color = .white
        actind.style = .medium
        actind.startAnimating()
        return actind
    }()
    //message label
    private let messageLabel: UILabel = {
        let message = UILabel()
        message.text = "Loading..."
        message.textColor = .white
        message.font = UIFont.italicSystemFont(ofSize: 16.0)
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    //stackview
    let holderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10.0
        return stackView
    }()
    
    //MARK:- View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        //1.
        self.addViewAndAdjustAlignment()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK:- Add view and place alignment
    fileprivate func addViewAndAdjustAlignment() {
        self.holderStackView.addArrangedSubview(self.activityIndicator)
        self.holderStackView.addArrangedSubview(self.messageLabel)
        self.addSubview(self.holderStackView)
        NSLayoutConstraint.activate([
            self.holderStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.holderStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
