//
//  selectionViewController.swift
//  truthordare
//
//  Created by Palmatier, Dustin on 10/29/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//  yizq-jsyd-rlsm-exrk
// uipp-bzxc-ihyq-nsdr
import UIKit
import SCSDKBitmojiKit
import SCSDKLoginKit
import SCSDKCreativeKit
import WebKit

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}

extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
}

fileprivate let externalIdQuery = "{me{externalId}}"

class selectionViewController: UIViewController, WKScriptMessageHandler, UITextViewDelegate {
    var stickerViewHeight: CGFloat {
        if !bitmojiSearchHasFocus {
            return 250
        }
        var availableHeight = view.frame.height - keyboardHeight
        
        if #available(iOS 11.0, *) {
            availableHeight -= view.safeAreaInsets.top
        } else {
            availableHeight -= topLayoutGuide.length
        }
        
        return availableHeight * 0.9
    }
    
    let stickerVC: SCSDKBitmojiStickerPickerViewController =
        SCSDKBitmojiStickerPickerViewController(config: SCSDKBitmojiStickerPickerConfigBuilder()
            .withShowSearchBar(true)
            .withShowSearchPills(true)
            .withTheme(.light)
            .build())
    var bottomConstraint: NSLayoutConstraint!
    var stickerPickerTopConstraint: NSLayoutConstraint!
    var isStickerViewVisible = true {
        didSet {
            guard isStickerViewVisible != oldValue else {
                return
            }
            stickerVC.view.isHidden = !isStickerViewVisible
            stickerPickerTopConstraint.constant = isStickerViewVisible ? -stickerViewHeight : 0
        }
    }
    var keyboardHeight: CGFloat = 0
    var bitmojiSearchHasFocus = false {
        didSet {
            guard bitmojiSearchHasFocus != oldValue else {
                return
            }
            updateAndAnimateLayoutContstraints(duration: 0.3, options: [.beginFromCurrentState])
        }
    }
    
    private func updateAndAnimateLayoutContstraints(duration: TimeInterval, options: UIView.AnimationOptions) {
        bottomConstraint.constant = -keyboardHeight
        stickerPickerTopConstraint.constant = -keyboardHeight - (isStickerViewVisible ? stickerViewHeight : 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    var externalIdentifier:String = ""
    var displayName:String = ""
    var bitmojiLink:String = ""
    var encodedImageData:String = ""
    
    @IBAction func truthButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let selectionViewController = storyBoard.instantiateViewController(withIdentifier: "truthsView") as! truthsViewController
            
            
            selectionViewController.identifier = self.externalIdentifier
            selectionViewController.bitmojiLink = self.bitmojiLink
            selectionViewController.displayName = self.displayName
            self.navigationController?.pushViewController(selectionViewController, animated: true)
        }
        
    }
    
    @IBAction func dareButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let selectionViewController = storyBoard.instantiateViewController(withIdentifier: "daresView") as! daresViewController
            
            selectionViewController.identifier = self.externalIdentifier
            selectionViewController.bitmojiLink = self.bitmojiLink
            selectionViewController.displayName = self.displayName
            self.navigationController?.pushViewController(selectionViewController, animated: true)
        }
    }
    
    @IBOutlet weak var viewShare: CardView!
    var card = CardView()
    var bottomAnchorConstraint: NSLayoutConstraint?
    
    
    var testFlag:Bool = false //Just for testing purposes
    let cardHeight = UIScreen.main.bounds.height * 3/4
    var startingConstant : CGFloat = 0
    
    let backBar : UIView = {
        let bar = UIView()
        bar.backgroundColor = .lightGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
    }
    
    @objc func shareToApp(sender: UIButton!) {
        sendSnapToAppShare { (Bool, Error) in
            print("There was an error!");
        }
    }
    
    @IBOutlet weak var bitmojiSelectionView: UIView!
    @objc func bitmojiButton(sender: UIButton!) {
    }
    @objc func buttonAction(sender: UIButton!) {
        viewShare.isHidden = true
    }
    
    @IBOutlet weak var iconView: UIImageView! {
        didSet {
            iconView.backgroundColor = .white
            iconView.layer.cornerRadius = iconView.frame.width/2
            iconView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var truthButton: UIButton!
    @IBOutlet weak var dareButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    var snapAPI: SCSDKSnapAPI?
    var webView = WKWebView()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != stickerVC.view {
            if (!stickerVC.view.isHidden) {
                stickerVC.view.isHidden = true
            }
        }
        view.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.shareButton.isHidden = true
        
        webView = WKWebView(frame:  UIScreen.main.bounds, configuration: self.config())
        view.addSubview(webView)
        // Do any additional setup after loading the view.
        if let url = URL(string: "https://truthordare.hexhamnetwork.com/images/generateResponse.php?alpha=1&bitmoji=\(self.bitmojiLink)") {
            webView.load(URLRequest(url: url))
            webView.isHidden = true
        }
        
        if let url = URL(string: bitmojiLink) {
            downloadImage(from: url)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedMe))
            self.iconView.addGestureRecognizer(tap)
            self.iconView.isUserInteractionEnabled = true
        }
        
        dareButton.layer.cornerRadius = 10
        dareButton.clipsToBounds = true
        
        truthButton.layer.cornerRadius = 10
        truthButton.clipsToBounds = true
        
        shareButton.layer.cornerRadius = 10
        shareButton.clipsToBounds = true
        
        card.bitmojiButton.addTarget(self, action: #selector(toggleStickerViewVisible), for: .touchUpInside)
        card.shareButton.addTarget(self, action: #selector(shareToApp), for: .touchUpInside)
        snapAPI = SCSDKSnapAPI()
        
        let bottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchor = view.bottomAnchor
        }
        
        bottomConstraint = stickerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        stickerPickerTopConstraint = stickerVC.view.topAnchor.constraint(equalTo: bottomAnchor, constant: -stickerViewHeight)
        
        stickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        stickerVC.delegate = self
        self.addChild(stickerVC)
        view.addSubview(stickerVC.view)
        stickerVC.didMove(toParent: self)
        stickerVC.view.isHidden = true
        NSLayoutConstraint.activate([
            stickerVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stickerVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stickerVC.view.topAnchor.constraint(equalTo: self.card.stickerLabel.bottomAnchor),
            stickerVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func setupView() {
        view.addSubview(card)
        view.addSubview(backBar)
        view.sendSubviewToBack(backBar)
        
        view.backgroundColor = .white
        title = "Home"
        shareButton.addTarget(self, action: #selector(handleActiveCard), for: .touchUpInside)
        
        layoutView()
        setupGestureRecogizer()
    }
    
    func setupGestureRecogizer() {
        card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:))))
    }
    
    func layoutView() {
        
        bottomAnchorConstraint = card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: cardHeight)
        bottomAnchorConstraint?.isActive                                    = true
        card.leftAnchor.constraint(equalTo: view.leftAnchor).isActive       = true
        card.rightAnchor.constraint(equalTo: view.rightAnchor).isActive     = true
        card.heightAnchor.constraint(equalToConstant: cardHeight) .isActive = true
        
        backBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backBar.topAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
        
    }
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began:
            startingConstant = (bottomAnchorConstraint?.constant)!
        case .changed:
            
            
            let translationY = sender.translation(in: self.card).y
            self.bottomAnchorConstraint?.constant = startingConstant + translationY
            
            
            
        case .ended:
            if (Int((self.bottomAnchorConstraint?.constant)!)) < 0 {
                card.animateCardFlow(duration: 0.3, constraint: bottomAnchorConstraint!, constant: 0, initialSpringVelocity: 0.6, usingSpringWithDamping: 0.9) { [unowned self] in
                    self.view.layoutIfNeeded()
                }
            } else if sender.velocity(in: self.card).y > 0 {
                
                //Card is moving down
                if (sender.velocity(in: self.card).y < 300 && Int((self.bottomAnchorConstraint?.constant)!) < 180)
                {
                    card.animateCardFlow(duration: 0.3, constraint: bottomAnchorConstraint!, constant: 0, initialSpringVelocity: 3, usingSpringWithDamping: 0.9) { [unowned self] in
                        self.view.layoutIfNeeded()
                    }
                } else {
                    card.animateCardFlow(duration: 0.5, constraint: bottomAnchorConstraint!, constant: cardHeight, initialSpringVelocity: 0.6, usingSpringWithDamping: 0.9) { [unowned self] in
                        self.view.layoutIfNeeded()
                        self.testFlag.toggle()
                    }
                }
            }else {
                
                //Card is moving up
                card.animateCardFlow(duration: 0.3, constraint: bottomAnchorConstraint!, constant: 0, initialSpringVelocity: 0.6, usingSpringWithDamping: 0.9) { [unowned self] in
                    self.view.layoutIfNeeded()
                }
                
            }
        default:
            break
        }
        
    }
    
    
    @objc func handleActiveCard() {
        testFlag.toggle()
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            self.testFlag ? ( self.bottomAnchorConstraint?.constant = 0.0 ) : (self.bottomAnchorConstraint?.constant = self.cardHeight)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func config() -> WKWebViewConfiguration {
        let scriptName = "GetDownloadData"
        let javaScript = "$('body').on('click', 'a.download-anchor', function(e) {"
            +    "    webkit.messageHandlers.\(scriptName).postMessage('clicked ' + e.target.href); "
            +    "}); "
        let userScript = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(userScript)
        config.userContentController.add(self, name: scriptName)
        return config
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        var sentence:String = message.body as! String
        let wordToRemove = "clicked "
        if let range = sentence.range(of: wordToRemove) {
            sentence.removeSubrange(range)
        }
        
        self.shareButton.isHidden = false
        self.encodedImageData = sentence
    }
    
    func sendSnapToAppShare(completionHandler: (Bool, Error?) ->()) {
        let imageOne:UIImage = image(with: card.convertedView)!
        let imageSticker = imageOne
        let sticker = SCSDKSnapSticker(stickerImage: imageOne)
        let snap = SCSDKNoSnapContent()
        snap.sticker = sticker
        snap.attachmentUrl = "https://truthordare.hexhamnetwork.com/\(self.externalIdentifier)"
        view.isUserInteractionEnabled = false
        snapAPI?.startSending(snap) { [weak self] (error: Error?) in
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func base64Convert(base64String: String?) -> UIImage{
        if ((base64String?.isEmpty) == true) {
            return #imageLiteral(resourceName: "no_image_found")
        }else {
            // !!! Separation part is optional, depends on your Base64String !!!
            let temp = base64String?.components(separatedBy: ",")
            let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage!
        }
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
                self.iconView.image = UIImage(data: data)
                self.card.bitmojiImage.image = UIImage(data: data)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedMe()
    {
        let alert = UIAlertController(title: "Truth or Dare 👻", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Refresh", style: .default) { _ in
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let selectionViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! ViewController
                self.present(selectionViewController, animated: true, completion: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            SCSDKLoginClient.unlinkCurrentSession { (success: Bool) in
                DispatchQueue.main.async {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let selectionViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! ViewController
                    self.present(selectionViewController, animated: true, completion: nil)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @objc func toggleStickerViewVisible() {
        stickerVC.view.isHidden = !stickerVC.view.isHidden
    }
    
}

extension selectionViewController: SCSDKBitmojiStickerPickerViewControllerDelegate {
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController,
                                            didSelectBitmojiWithURL bitmojiURL: String,
                                            image: UIImage?) {
        handleBitmojiSend(imageURL: bitmojiURL, image: image)
    }
    
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, searchFieldFocusDidChangeWithFocus hasFocus: Bool) {
        bitmojiSearchHasFocus = hasFocus
    }
}

extension selectionViewController {
    func handleBitmojiSend(imageURL: String, image: UIImage?) {
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
                    self.card.bitmojiImage.image = UIImage(data: data)
                }
            }
        }
        
        if let url = URL(string: imageURL) {
            downloadImage(from: url)
        }
    }
}
