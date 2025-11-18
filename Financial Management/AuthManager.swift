//
//  AuthManager.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - User Model
struct User {
    let uid: String
    let email: String
    let displayName: String?
    let createdAt: Date
    
    init(uid: String, email: String, displayName: String? = nil, createdAt: Date = Date()) {
        self.uid = uid
        self.email = email
        this.displayName = displayName
        self.createdAt = createdAt
    }
    
    // Initialize from Firebase User
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.displayName = firebaseUser.displayName
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
    }
    
    // Convert to dictionary for Firestore storage
    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "email": email,
            "displayName": displayName ?? "",
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}

// MARK: - Auth Result
enum AuthResult {
    case success(User)
    case failure(AuthError)
}

// MARK: - Auth Error
enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case passwordMismatch
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email format"
        case .weakPassword:
            return "Password is too weak (minimum 6 characters)"
        case .passwordMismatch:
            return "Passwords do not match"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .userNotFound:
            return "User does not exist"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network connection failed"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Auth Manager
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {
        // Listen for authentication state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = User(from: user)
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Register
    func register(email: String, password: String, confirmPassword: String, completion: @escaping (AuthResult) -> Void) {
        
        // Validate input
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        guard password.count >= 6 else {
            completion(.failure(.weakPassword))
            return
        }
        
        guard password == confirmPassword else {
            completion(.failure(.passwordMismatch))
            return
        }
        
        // Firebase register
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                let authError = self?.mapFirebaseError(error) ?? .unknown(error.localizedDescription)
                completion(.failure(authError))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(.unknown("Registration failed")))
                return
            }
            
            let user = User(from: firebaseUser)
            
            // Save user info to Firestore
            self?.saveUserToFirestore(user) { success in
                if success {
                    completion(.success(user))
                } else {
                    completion(.failure(.unknown("Failed to save user information")))
                }
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (AuthResult) -> Void) {
        
        // Validate input
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        guard !password.isEmpty else {
            completion(.failure(.weakPassword))
            return
        }
        
        // Firebase login
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                let authError = self?.mapFirebaseError(error) ?? .unknown(error.localizedDescription)
                completion(.failure(authError))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(.unknown("Login failed")))
                return
            }
            
            let user = User(from: firebaseUser)
            completion(.success(user))
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try auth.signOut()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        guard let authError = error as NSError? else {
            return .unknown(error.localizedDescription)
        }
        
        switch authError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .unknown(authError.localizedDescription)
        }
    }
    
    private func saveUserToFirestore(_ user: User, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(user.uid).setData(user.toDictionary()) { error in
            completion(error == nil)
        }
    }
}
