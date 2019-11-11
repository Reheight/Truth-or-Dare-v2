import UIKit
import SCSDKLoginKit
import SCSDKBitmojiKit

class ViewController: UIViewController {
    var externalIdentifier = "empty"
    var displayName = "empty"
    var bitmojiLink = ""
    let iconView = SCSDKBitmojiIconView()
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: Any) {
        SCSDKLoginClient.login(from: self, completion: { success, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if success {
                self.retrieveExternalId()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.retrieveExternalId()
        self.fetchUserData()
    }
    private func fetchUserData() {
        let graphQLQuery = "{me{displayName, bitmoji{avatar}}}"
        
        let variables = ["page": "bitmoji"]
        
        SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: variables, success: { (resources: [AnyHashable: Any]?) in
            guard let resources = resources,
                let data = resources["data"] as? [String: Any],
                let me = data["me"] as? [String: Any] else { return }
            
            let displayName = me["displayName"] as? String
            var bitmojiAvatarUrl: String?
            if let bitmoji = me["bitmoji"] as? [String: Any] {
                bitmojiAvatarUrl = bitmoji["avatar"] as? String
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            self.loginButton.isHidden = false
        })
    }
    
    private func fetchSnapUserInfo(){
        let graphQLQuery = "{me{displayName, bitmoji{avatar}}}"
        
        let variables = ["page": "bitmoji"]
        
        SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: variables, success: { (resources: [AnyHashable: Any]?) in
            guard let resources = resources,
                let data = resources["data"] as? [String: Any],
                let me = data["me"] as? [String: Any] else { return }
            
            let displayName = me["displayName"] as? String
            var bitmojiAvatarUrl: String?
            
            self.displayName = displayName!
            if let bitmoji = me["bitmoji"] as? [String: Any] {
                bitmojiAvatarUrl = bitmoji["avatar"] as? String
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            // handle error
        })
    }
    
    private func retrieveExternalId() {
        let graphQLQuery = "{me{externalId, displayName, bitmoji{avatar}}}"
        
        SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: nil, success: { (resources: [AnyHashable: Any]?) in
            guard let resources = resources,
                let data = resources["data"] as? [String: Any],
                let me = data["me"] as? [String: Any] else { return }
            let displayName = me["displayName"] as? String
            let externalId = me["externalId"] as? String
            var bitmojiAvatarUrl: String?
            
            let delimiter = "/"
            var token = externalId?.components(separatedBy: delimiter)
            
            let stepOne = externalId?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let stepTwo = stepOne?.replacingOccurrences(of: "+", with: "")
            
            self.externalIdentifier = stepTwo?.replacingOccurrences(of: "/", with: "") ?? "error"
            
            print(self.externalIdentifier)
            
            self.displayName = displayName!
            
            if let bitmoji = me["bitmoji"] as? [String: Any] {
                bitmojiAvatarUrl = bitmoji["avatar"] as? String
            }
            
            self.bitmojiLink = bitmojiAvatarUrl!
            
            let myUrl = URL(string: "https://truthordare.hexhamnetwork.com/api/92fFDd93D/register.php");
            
            var request = URLRequest(url:myUrl!)
            
            request.httpMethod = "POST"// Compose a query string
            
            let postString = "displayname=\(self.displayName)&externalid=\(self.externalIdentifier)&bitmoji=\(self.bitmojiLink)";
            
            request.httpBody = postString.data(using: String.Encoding.utf8);
            
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil
                {
                    print("error=\(error)")
                    return
                }
                
                // You can print out response object
                
                //Let's convert response sent from a server side script to a NSDictionary object:
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    if let parseJSON = json {
                        
                        // Now we can access value of First Name by its key
                        let error = parseJSON["error"] as? String
                        let message = parseJSON["message"] as? String
                        print("Error: \(error)")
                        print("Message: \(message)")
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
            
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let selectionViewController = storyBoard.instantiateViewController(withIdentifier: "selectionMenu") as! selectionViewController
            
                let navController = UINavigationController(rootViewController: selectionViewController)
                selectionViewController.displayName = self.displayName
                selectionViewController.externalIdentifier = self.externalIdentifier
                selectionViewController.bitmojiLink = self.bitmojiLink
                
                self.present(navController, animated:true, completion: nil)
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            self.loginButton.isHidden = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
