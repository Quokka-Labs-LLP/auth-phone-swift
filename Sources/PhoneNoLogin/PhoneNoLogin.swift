import Firebase
import FirebaseAuth

public struct PhoneNoLoginController {
    public static var instance = PhoneNoLoginController()
    private var mobileNumber: String?
    private var countryCode: String?
    
    public mutating func sendOtp(mobileNumber: String, countryCode: String,
                 onSuccess: @escaping(String) -> Void,
                 onFailure: @escaping(String) -> Void) {
        self.mobileNumber = mobileNumber
        self.countryCode = countryCode
        Auth.auth().languageCode = "en"
        let phoneNumber = countryCode + mobileNumber
        
        // Request OTP through sms
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                onFailure(error.localizedDescription)
                return
            }
            guard let verificationId = verificationID else {
                onFailure(kVerificationUserIdNotFound)
                return
            }
            onSuccess(verificationId)
        }
    }
    
    public mutating func resendOtp(onSuccess: @escaping(String) -> Void,
                          onFailure: @escaping(String) -> Void) {
        guard let mobileNumber = mobileNumber, let countryCode = countryCode else {
            onFailure(kDataNotFoundToMakeApiCall)
            return
        }
        self.sendOtp(mobileNumber: mobileNumber, countryCode: countryCode) { verificationID in
            onSuccess(verificationID)
        } onFailure: { error in
            onFailure(error)
        }
    }
    
    public mutating func verifyOtp(otp: String, verificationID: String,
                   onSuccess: @escaping(FirebaseAuth.User) -> Void,
                   onFailure: @escaping(String) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                 verificationCode: otp)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                onFailure(error.localizedDescription)
                return
            }
            // User has signed in successfully and currentUser object is valid
            guard let currentUser = Auth.auth().currentUser else {
                onFailure(kSomethingWentWrongWithFirebase)
                return
            }
            onSuccess(currentUser)
        }
    }
}
