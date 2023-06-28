
import UIKit
import AptoUISDK
import AptoSDK

@objc(Apto)
class Apto: NSObject {
    let token = MyProviderToken()
    //    var verification: Verification? = nil
    var primaryCredential:PhoneNumber?
    var secondCredential: Verification? = nil
    
    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(a*b)
    }
    
    @objc(initial:baseURL:isSanbox:)
    func initial(apiKey:String?, baseURL:String, isSanbox:Bool) -> Void {
        AptoPlatform.defaultManager().initializeWithApiKey(apiKey ?? "", environment: isSanbox ? .sandbox : .production)
        token.baseURL = baseURL
        AptoPlatform.defaultManager().tokenProvider = token
        //        "https://api-dev.tappo.uk/v1/sign"
    }
    
    @objc(startPhoneVerification:withResolver:withRejecter:)
    func startPhoneVerification(phoneNumber: String?,  resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        self.primaryCredential = PhoneNumber(countryCode: 1, phoneNumber: phoneNumber)
        if let primaryCredential = primaryCredential {
            AptoPlatform.defaultManager().startPhoneVerification(primaryCredential) { result in
                switch result {
                case .failure(let error):
                    // Do something with the error
                    reject("ERROR_CODE","Something went wrong",error)
                case .success(let ver):
                    // The verification started and the user received an SMS with a single use code (OTP).
                    self.primaryCredential?.verification = ver;
                    resolve(result)
                }
            }
            
        }
    }
    
    @objc(completeVerificataion:withResolver:withRejecter:)
    func completeVerificataion(secret: String?,  resolve:  @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        if let verification  =  self.primaryCredential?.verification {
            verification.secret = secret
            AptoPlatform.defaultManager().completeVerification( verification) { result in
                switch result {
                case .failure(let error):
                    // Do something with the error
                    reject("ERROR_CODE","Something went wrong",error)
                case .success(let verifier):
                    if verifier.status == .passed {
                        var data: [String: Any] = [
                            "verificationId": verifier.verificationId]
                        // The verification succeeded. If it belongs to an existing user, it will contain a non null `secondaryCredential`.
                        if let secondaryCredential = verifier.secondaryCredential {
                            data["secondaryCredential"] = secondaryCredential.verificationId
                            self.secondCredential = secondaryCredential
                        }
                        resolve(data)
                    }
                    else {
                        // The verification failed: the secret is invalid.
                        reject("ERROR_CODE","Code invalid",nil)
                        
                    }
                }
            }
        }
    }
    
    @objc(createUser:withResolver:withRejecter:)
    func createUser(data: [String: Any],  resolve:  @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let userData = mappingUserData(data:data)
        AptoPlatform.defaultManager().createUser(userData: userData) { result in
            switch result {
            case .failure(let error):
                reject("ERROR_CODE","Create user Failed", error)
                // Do something with the error
            case .success(let user):
                let data: [String: Any] = [
                    "userId": user.userId,
                    "accessToken": user.accessToken?.token ?? "",
                ]
                resolve(data)
                // The user created. It contains the user id and the user session token.
            }
        }
    }
    
    
    
    
    /**
     This function for login flow
     */
    @objc(completeSercondaryVerificataion:withResolver:withRejecter:)
    func completeSercondaryVerificataion(secret: String?,  resolve:  @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        if let verification = secondCredential {
            verification.secret = secret
            AptoPlatform.defaultManager().completeVerification(verification) { result in
                switch result {
                case .failure(let error):
                    // Do something with the error
                    reject("ERROR_CODE","Something went wrong",error)
                case .success(let verf):
                    if verf.status == .passed {
                        self.secondCredential = verf
                        // The verification succeeded. If it belongs to an existing user, it will contain a non null `secondaryCredential`.
                        //                        resolve(verification)
                        self.loginWithExistingUser(resolve: resolve, reject: reject)
                    }
                    else {
                        // The verification failed: the secret is invalid.
                        reject("ERROR_CODE","Code invalid",nil)
                        
                    }
                }
            }
        }
        
    }
    @objc(startCardFlow:withRejecter:)
    func startCardFlow (resolve:  @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        DispatchQueue.main.async {
            if let currentViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
                
                AptoPlatform.defaultManager().startCardFlow(from: currentViewController, mode: .standalone, googleMapsApiKey: "AIzaSyAj21pmvNCyCzFqYq2D3nL4FwYPCzpHwRA") { [weak self] result in
                    switch result {
                    case .failure(let error):
                        // handle error
                        reject("ERROR","Something went wrong",error)
                        print("Error: \(error)")
                        break
                    case .success(let module):
                        // SDK successfully initialized
                        resolve(" SDK successfully initialized")
                        print(module)
                        break
                    }
                }
            } else {
                reject("viewController_not_found", "Unable to find the current UIViewController.", nil)
            }
            
        }
    }
    
    func loginWithExistingUser(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        if let secondCredential = self.secondCredential, let primaryCredential = self.primaryCredential?.verification {
            AptoPlatform.defaultManager().loginUserWith(verifications: [primaryCredential, secondCredential]) { result in
                switch result {
                case .failure(let error):
                    reject("ERROR","Something went wrong",error)
                    // Do something with the error
                case .success(let user):
                    let data: [String: Any] = [
                        "userId": user.userId,
                        "accessToken": user.accessToken?.token ?? "",
                    ]
                    resolve(data)
                    // The user logged in. The user variable contains the user id and the user session token.
                }
            }
        }
        
    }
    
    
    func mappingUserData(data: [String: Any]) -> DataPointList {
        let email = data["email"] as? String
        let firstName = data["firstName"] as? String
        let lastName = data["lastName"] as? String
        // address picking data
        let street = data["street"] as? String
        let apUnit = data["apUnit"] as? String
        let city = data["city"] as? String
        let region = data["region"] as? String
        let zip = data["zip"] as? String
        
        let birthDate = data["birthDate"] as? String // must format YYYY-DD-MM
        
        let userData = DataPointList()
        // adding phone number
        userData.add(dataPoint: primaryCredential ?? PhoneNumber(countryCode: 1, phoneNumber: "0000000"))
        // Email
        userData.add(dataPoint: Email(email: email, verified:true, notSpecified: false))
        //Name
        let fullName = PersonalName(firstName: firstName, lastName: lastName)//
        userData.add(dataPoint: fullName)
        
        //Adrress
        let address = Address(address: street, apUnit: apUnit, country: .defaultCountry, city: city, region: region, zip: zip)
        userData.add(dataPoint: address)
        
        if let dateString = birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-DD-MM"
            if let date = dateFormatter.date(from: dateString) {
                print(date) // Output: 1992-06-07 00:00:00 +0000
                let d = BirthDate(date:date)
                userData.add(dataPoint: d)
            } else {
                print("Invalid date string")
            }
        }
        return userData
    }
    
}

class MyProviderToken: AptoPlatformWebTokenProvider {
    var baseURL = ""
    
    public func getToken(_ payload: [String: Any], callback: @escaping (Result<String, NSError>) -> ()) {
        let url = URL(string: self.baseURL)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.headers = ["Content-Type": "application/json", "Accept": "application/json"];
        
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("HTTP Request Failed \(error)")
            // let SDK know an error happened
            callback(.failure(WebTokenError()))
        }
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            do {
                if let data = data {
                    let result: JWTToken = try JSONDecoder().decode(JWTToken.self, from: data)
                    // send the JWT back to the SDK
                    callback(.success(result.token))
                } else if let error = error {
                    print("HTTP Request returned bad data \(error)")
                    // let SDK know an error happened
                    callback(.failure(WebTokenError()))
                }
            } catch {
                print("HTTP Request Failed \(error)")
                // let SDK know an error happened
                callback(.failure(WebTokenError()))
            }
        }
        
        task.resume()
        
    }
}

struct JWTToken: Decodable {
    let token: String
}

