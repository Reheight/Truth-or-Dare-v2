//
//  CardViewController.swift
//  truthordare
//
//  Created by Dustin Palmatier on 11/5/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit
import SCSDKBitmojiKit

class CardView: UIView, UITextViewDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bitmojiImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var bitmojiButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var stickerLabel: UITextView!
    @IBOutlet weak var bitmojiPickerContraints: UIView!
    @IBOutlet weak var convertedView: UIView!
    
    let topBar : UIView = {
        let bar = UIView()
        bar.backgroundColor = .black
        bar.layer.cornerRadius = 4
        bar.clipsToBounds = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    @IBAction func randomButton(_ sender: UIButton) {
        let arrColors = ["53ff2f", "40ffe7", "#ff27ee", "ffffff", "#faff1f"]
        let arrMessages = ["Give me a challenge 😏", "Give me a Truth or Dare! 😬", "Give me something to do 🤔", "I will answer or do anything 😶", "Give me something good 🙌🏻"]
        let randomIndex = Int(arc4random_uniform(UInt32(arrColors.count)))
        
        let finishColor:UIColor = hexStringToUIColor(hex: arrColors[randomIndex])
        
        stickerLabel.backgroundColor = finishColor
        
        let randomMessage = Int(arc4random_uniform(UInt32(arrMessages.count)))
        let finishMessage:String = arrMessages[randomMessage]
        
        stickerLabel.text = finishMessage
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupCard()
    }
    
    private func setupCard() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBar)
        topBar.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
        topBar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        topBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundedCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 25.0
    private var fillColor: UIColor = .blue
    
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    private func commonInit() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        Bundle.main.loadNibNamed("CardViewController", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = .lightGray
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        shareButton.layer.shadowColor = UIColor.black.cgColor
        
        shareButton.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        
        shareButton.layer.masksToBounds = false
        
        shareButton.layer.shadowRadius = 1
        
        shareButton.layer.shadowOpacity = 0.5
        
        shareButton.layer.cornerRadius = 10
        
        // Shadow and Radius for Circle Button
        randomButton.layer.shadowColor = UIColor.black.cgColor
        randomButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        randomButton.layer.masksToBounds = false
        randomButton.layer.shadowRadius = 1.0
        randomButton.layer.shadowOpacity = 0.5
        randomButton.layer.cornerRadius = randomButton.frame.width / 2
        
        bitmojiButton.layer.shadowColor = UIColor.black.cgColor
        bitmojiButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        bitmojiButton.layer.masksToBounds = false
        bitmojiButton.layer.shadowRadius = 1.0
        bitmojiButton.layer.shadowOpacity = 0.5
        bitmojiButton.layer.cornerRadius = randomButton.frame.width / 2
        
        fontButton.layer.shadowColor = UIColor.black.cgColor
        fontButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        fontButton.layer.masksToBounds = false
        fontButton.layer.shadowRadius = 1.0
        fontButton.layer.shadowOpacity = 0.5
        fontButton.layer.cornerRadius = randomButton.frame.width / 2
        // Do any additional setup after loading the view.
        
        stickerLabel.layer.shadowColor = UIColor.black.cgColor
        
        stickerLabel.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        
        stickerLabel.layer.masksToBounds = false
        
        stickerLabel.layer.shadowRadius = 1
        
        stickerLabel.layer.shadowOpacity = 0.5
        
        stickerLabel.layer.cornerRadius = 10
        
        stickerLabel.delegate = self
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.bitmojiImage.image = UIImage(data: data)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        if (numberOfChars > 120) {
            return false
        }
        
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
            
            return true
        }
        
        textView.resignFirstResponder()
        return false    // 10 Limit Value
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
    
    func roundedCorners(corners : UIRectCorner, radius : CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func animateCardFlow(duration: TimeInterval, constraint: NSLayoutConstraint, constant: CGFloat, initialSpringVelocity: CGFloat, usingSpringWithDamping: CGFloat, completion : @escaping () -> ()) {
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: .curveEaseInOut, animations: {
            constraint.constant = constant
            completion()
        })
    }
}
