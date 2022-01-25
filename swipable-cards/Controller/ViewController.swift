//
//  ViewController.swift
//  swipable-cards
//
//  Created by Kathan Lunagariya on 24/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    let cardsView = Card()
    
    var cards = model(results: [])
    var currentCardIndex = 0
    
    var originalCardFrame:CGRect = .zero
    var viewCenter = 0.0
    
    let likeBtn:UIButton = {
       
        let btn = UIButton()
        btn.configuration = .filled()
        btn.configuration?.cornerStyle = .capsule
        btn.configuration?.image = UIImage(systemName: "heart.fill")
        btn.configuration?.baseBackgroundColor = .systemGray6
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed]).applying(UIImage.SymbolConfiguration(scale: .large))
        btn.configuration?.preferredSymbolConfigurationForImage = config
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let dislikeBtn:UIButton = {
       
        let btn = UIButton()
        btn.configuration = .filled()
        btn.configuration?.cornerStyle = .capsule
        btn.configuration?.image = UIImage(systemName: "multiply.circle.fill")
        btn.configuration?.baseBackgroundColor = .systemGray6
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .black]).applying(UIImage.SymbolConfiguration(scale: .large))
        btn.configuration?.preferredSymbolConfigurationForImage = config
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let stack:UIStackView = {
            
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 25
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardsView)
        
        stack.addArrangedSubview(likeBtn)
        stack.addArrangedSubview(dislikeBtn)
        view.addSubview(stack)
        
        Task{
            await loadCardsData()
            await setUpInfoFor(index: 0)
        }
        
        likeBtn.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        dislikeBtn.addTarget(self, action: #selector(didTapDislike), for: .touchUpInside)
        
        cardsView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didSwapCard(sender:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.originalCardFrame = self.cardsView.frame
        self.viewCenter = view.frame.midX
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            cardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardsView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -75),
            cardsView.heightAnchor.constraint(equalTo: cardsView.widthAnchor),
            
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: cardsView.bottomAnchor, constant: 15),
            stack.heightAnchor.constraint(equalToConstant: 75),
            stack.widthAnchor.constraint(equalToConstant: 75+75+25)
        ])
    }
    
    func loadCardsData() async{
        
        let url = URL(string: "https://randomuser.me/api/?results=5&gender=female")
        guard url != nil else{
            print("nil url...")
            return
        }
        self.cards = model(results: [])
        self.currentCardIndex = 0
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url!, delegate: nil)
            let results = try JSONDecoder().decode(model.self, from: data)
            
            self.cards = results
        }catch{
            print(error)
        }
    }
    
    func setUpInfoFor(index:Int) async{
        
        DispatchQueue.main.async {
            let user = self.cards.results
            
            Task{
                await self.imageFromURL(url: user[index].picture.large, completion: { imgData in
                    DispatchQueue.main.async {
                        self.cardsView.userImg.image = UIImage(data: imgData)
                    }
                })
            }

            self.cardsView.userName.text = user[index].name.first + " " + user[index].name.last
            self.cardsView.userDetails.text = "\(user[index].dob.age)\n\(user[index].location.city),\(user[index].location.country)"
        }
    }
    
    func imageFromURL(url:String, completion:@escaping (Data) -> Void) async{
        
        guard let url = URL(string: url) else {
            print("nil profile-pic url...")
            completion(Data())
            return
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            completion(data)
        }catch{
            print(error)
            completion(Data())
        }
    }
}


//MARK: BUTTON-ACTIONS...
extension ViewController{
    
    @objc func didTapLike(){
        currentCardIndex += 1
        
        if currentCardIndex == cards.results.count{
            Task{
                await loadCardsData()
                await setUpInfoFor(index: currentCardIndex)
            }
        }else{
            Task{
                await setUpInfoFor(index: currentCardIndex)
            }
        }
    }
    
    @objc func didTapDislike(){
        currentCardIndex += 1
        
        if currentCardIndex == cards.results.count{
            Task{
                await loadCardsData()
                await setUpInfoFor(index: currentCardIndex)
            }
        }else{
            Task{
                await setUpInfoFor(index: currentCardIndex)
            }
        }
    }
    
    
    //MARK: GESTURE-logic...
    @objc func didSwapCard(sender:UIPanGestureRecognizer){
        
        guard let card = sender.view as? Card else {
            print("sender's view is nil...")
            return
        }
        let translation = sender.translation(in: view)
        
        switch sender.state{
            
        case .began, .changed:
            card.center = CGPoint(x: card.center.x + translation.x, y: card.center.y + translation.y)
            sender.setTranslation(.zero, in: view)
            
            if card.center.x > self.viewCenter{
                card.transform = CGAffineTransform(rotationAngle: .pi/12)
                card.overlay.backgroundColor = .systemRed
                
                card.fractionComplete = card.center.x / self.view.frame.maxX - 1.0
            }else{
                card.transform = CGAffineTransform(rotationAngle: -.pi/12)
                card.overlay.backgroundColor = .systemGreen
                
                card.fractionComplete = 0.5 - card.center.x / self.viewCenter
            }
            
            break
            
        case .ended:
            
            if card.frame.minX < view.frame.minX - 50{
                executeAnimation(sender: card, action: .like)
            }
            else if card.frame.maxX > view.frame.maxX + 50{
                executeAnimation(sender: card, action: .dislike)
            }
            else{
                UIView.animate(withDuration: 1) {
                    card.transform = .identity
                    card.frame = self.originalCardFrame
                }
            }
            
            break
            
        default:
            print("not recognized gesture state...")
        }
    }
    
    //MARK: GESTURE-animation...
    func executeAnimation(sender:Card, action:Action){
        
        UIView.animate(withDuration: 0.5) {
            sender.alpha = 0.0
        }completion: { _ in
            sender.transform = .identity
            sender.frame = self.originalCardFrame
            sender.overlay.alpha = 0.0
            sender.overlay.backgroundColor = .clear
            
            if action == .like{
                self.didTapLike()
            }else{
                self.didTapDislike()
            }
            
            UIView.animate(withDuration: 0.3) {
                sender.alpha = 1.0
            }
        }
    }
    
}
