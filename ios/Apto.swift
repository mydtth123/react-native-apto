
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
    
    @objc(initial:isSanbox:)
    func initial(apiKey:String?, isSanbox:Bool) -> Void {
        AptoPlatform.defaultManager().initializeWithApiKey(apiKey ?? "", environment: isSanbox ? .sandbox : .production)
        AptoPlatform.defaultManager().tokenProvider = token
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
                    reject("ERROR","Something went wrong",error)
                case .success(let verf):
                    if verf.status == .passed {
                        self.secondCredential = verf
                        // The verification succeeded. If it belongs to an existing user, it will contain a non null `secondaryCredential`.
//                        resolve(verification)
                        self.loginWithExistingUser(resolve: resolve, reject: reject)
                    }
                    else {
                        // The verification failed: the secret is invalid.
                        reject("333","Code invalid",NSError())

                    }
                }
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
        let userData = DataPointList()

        userData.add(dataPoint: primaryCredential ?? PhoneNumber(countryCode: 1, phoneNumber: "1234567890"))
        let email  = Email(email: "user@gmail.com", verified:true, notSpecified: false)
        userData.add(dataPoint: email)
        let name = PersonalName(firstName: "DA", lastName: "AAS")//
        userData.add(dataPoint: name)
        let address = Address(address: "123 Main Street", apUnit: "456", country: .defaultCountry, city: "San Francisco,", region: "CA", zip: "94128")
        userData.add(dataPoint: address)
        let dateString = "06/07/1992"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter.date(from: dateString) {
            print(date) // Output: 1992-06-07 00:00:00 +0000
            let birthDate = BirthDate(date:date)
            userData.add(dataPoint: birthDate)
        } else {
            print("Invalid date string")
        }
        return userData
    }
    
}

class MyProviderToken: AptoPlatformWebTokenProvider {
    
    
    public func getToken(_ payload: [String: Any], callback: @escaping (Result<String, NSError>) -> ()) {
        let url = URL(string: "https://api-dev.tappo.uk/v1/sign")!
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
    //    }
}
struct JWTToken: Decodable {
    let token: String
}

//
//  ViewController.swift
//  AptoTest
//
//  Created by devcoco on 22/05/2023.
//



//// MARK: - Payload
struct Payload  {
    let dataPoints: DataPoints

    init(dictionary: [String: Any]) {
        self.dataPoints = DataPoints(dictionary: dictionary["data_points"] as! [String : Any])
    }

    enum CodingKeys: String, CodingKey {
        case dataPoints = "data_points"
    }
}
//
//// MARK: - DataPoints
struct DataPoints {
    let type: String
    let data: [Datum]

    init(dictionary: [String: Any]) {
        self.type = dictionary["type"] as! String
        var datum = [Datum]()
        for d in dictionary["data"] as! [[String:Any]] {
            datum.append(Datum(dictionary: d))
        }
        self.data = datum
    }
}
//// MARK: - Datum
struct Datum {
    let verified, notSpecified: Bool?
    let dataType, type: String?
    let countryCode: Int?
    let phoneNumber: String?
    let verification: Verification?
    let value, country, docType, email: String?
    let date, firstName, lastName, streetOne: String?
    let streetTwo, locality, region, postalCode: String?

    init(dictionary: [String: Any]) {
        self.verified = dictionary["verified"] as? Bool
        self.notSpecified = dictionary["not_specified"] as? Bool
        self.dataType = dictionary["data_type"] as? String
        self.type = dictionary["type"] as? String
        self.countryCode = dictionary["country_code"] as? Int
        self.phoneNumber = dictionary["phone_number"] as? String
        let verifi = Verification(verificationId: "", verificationType: .phoneNumber, status: .pending)
        verifi.createFromDict(dictionary: (dictionary["verification"] as? [String:Any])!)
        self.verification = verifi
        self.value = dictionary["value"] as? String
        self.country = dictionary["country"] as? String
        self.docType = dictionary["doc_type"] as? String
        self.email = dictionary["email"] as? String
        self.date = dictionary["date"] as? String
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
        self.streetOne = dictionary["street_one"] as? String
        self.streetTwo = dictionary["street_two"] as? String
        self.locality = dictionary["locality"] as? String
        self.region = dictionary["region"] as? String
        self.postalCode = dictionary["postal_code"] as? String
    }

    enum CodingKeys: String, CodingKey {
        case verified
        case notSpecified = "not_specified"
        case dataType = "data_type"
        case type
        case countryCode = "country_code"
        case phoneNumber = "phone_number"
        case verification, value, country
        case docType = "doc_type"
        case email, date
        case firstName = "first_name"
        case lastName = "last_name"
        case streetOne = "street_one"
        case streetTwo = "street_two"
        case locality, region
        case postalCode = "postal_code"
    }
}
////
//// MARK: - Verification
extension Verification {
//    let verificationID: String
//    let secret: String?
//    let verificationType: String?
    func createFromDict(dictionary: [String: Any]) {
        self.verificationId = dictionary["verification_id"] as! String
        self.secret = dictionary["secret"] as? String
        let type = dictionary["verification_type"]  as? String
        self.verificationType = type  == "phoneNumber" ? .phoneNumber : .birthDate
    }


    enum CodingKeys: String, CodingKey {
        case verificationID = "verification_id"
        case secret
        case verificationType = "verification_type"
    }
}

