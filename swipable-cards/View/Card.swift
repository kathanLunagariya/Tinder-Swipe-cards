//
//  Card.swift
//  swipable-cards
//
//  Created by Kathan Lunagariya on 24/12/21.
//

import UIKit

enum Action{
    case like
    case dislike
}

class Card: UIView {
    
    var animator:UIViewPropertyAnimator!
    
    var fractionComplete:CGFloat?{
        didSet{
            self.animator.fractionComplete = fractionComplete ?? 0
        }
    }
    
    let overlay:UIView = {
       
        let v = UIView()
        v.layer.cornerRadius = 10
        v.alpha = 0.0
        return v
    }()
    
    let userImg:UIImageView = {
       
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 10
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    let userName:UILabel = {
        
        let lbl = UILabel()
        lbl.font = UIFont(name: "Arial", size: 25)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let userDetails:UILabel = {
        
        let lbl = UILabel()
        lbl.font = .preferredFont(forTextStyle: .title2)
        lbl.textColor = .darkGray
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 0
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.75
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(userImg)
        self.addSubview(userName)
        self.addSubview(userDetails)
        self.addSubview(overlay)
        
        setUpAnimator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            userImg.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            userImg.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userImg.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            userImg.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7,constant: -10),
            
            userName.topAnchor.constraint(equalTo: userImg.bottomAnchor, constant: 7),
            userName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            userDetails.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 5),
            userDetails.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userDetails.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            userDetails.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
        
        overlay.frame = self.bounds
    }
    
    private func setUpAnimator(){
        
        animator = UIViewPropertyAnimator(duration: 1.2, curve: .easeIn, animations: {
            self.overlay.alpha = 0.5
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
