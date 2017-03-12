//
//  AuthProvider.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/11/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import Foundation
import Firebase

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginErrorCode {
    
    static let INVALID_EMAIL = "Invalid Email Address, please provide a valid email address"
    static let WRONG_PASSWORD = "Wrong PASSWORD, please enter the correct password"
    static let PROBLEM_CONNECTING = "PRoblem connecting to database, please try later"
    static let USER_NOT_FOUND = "User not found. Please register"
    static let EMAIL_ALREADY_IN_USE = "Email already in use, please use another email"
    static let WEAK_PASSWORD = "Password should be at least 6 characters long"
}


class AuthProvider {
    
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
        
    }
    
    var userName = FIRAuth.auth()?.currentUser?.email
    
    func login(withEmail: String, withPassword: String, loginHandler: LoginHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: withPassword, completion: { (user, error) in
            if error != nil {
                
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
                
            } else {
                loginHandler?(nil)
            }
            
            
        })
        
    }
    
    func signUp(email: String, password: String, loginHandler: LoginHandler?) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                
                if user?.uid != nil {
                    //STORE user to Database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: email, password: password)
                    
                    //Login the User
                    self.login(withEmail: email, withPassword: password, loginHandler: loginHandler)
                    
                }
            }
            
            
        })
    }
    
    func isLoggedIn() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            return true
        }
        return false
    }
    
    func logOut() -> Bool {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                return true
            } catch {
                return false
            }
        }
        
        return true
    }
    
    func userID() -> String {
        return FIRAuth.auth()!.currentUser!.uid
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = FIRAuthErrorCode(rawValue: err.code) {
            
            switch errCode {
            case .errorCodeWrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
                
            case .errorCodeInvalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
                
            case .errorCodeUserNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
                
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
                
            case .errorCodeWeakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
                
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
            }
        }
        
    }
    
}
