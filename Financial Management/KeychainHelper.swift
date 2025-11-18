import Foundation
import Security
import UIKit
import FirebaseAuth

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    // MARK: - Avatar Storage
    
    /// Save avatar data to Keychain
    /// - Parameters:
    ///   - avatarData: Avatar image data
    ///   - userId: User ID
    /// - Returns: Whether the save operation succeeded
    func saveAvatarData(_ avatarData: Data, forUserId userId: String) -> Bool {
        let key = "avatar_\(userId)"
        
        print("KeychainHelper: Preparing to save data, key: \(key), data size: \(avatarData.count)")
        
        // Delete existing data first
        let deleteResult = deleteAvatarData(forUserId: userId)
        print("KeychainHelper: Delete old data result: \(deleteResult)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: avatarData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        print("KeychainHelper: Start adding new data to Keychain")
        let status = SecItemAdd(query as CFDictionary, nil)
        let success = status == errSecSuccess
        
        print("KeychainHelper: Keychain status code: \(status), success: \(success)")
        
        return success
    }
    
    /// Load avatar data from Keychain
    /// - Parameter userId: User ID
    /// - Returns: Avatar image data, or nil if not found
    func loadAvatarData(forUserId userId: String) -> Data? {
        let key = "avatar_\(userId)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    /// Delete avatar data for a specific user
    /// - Parameter userId: User ID
    /// - Returns: Whether the delete operation succeeded
    func deleteAvatarData(forUserId userId: String) -> Bool {
        let key = "avatar_\(userId)"
        
        print("KeychainHelper: Preparing to delete old data, key: \(key)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        let success = status == errSecSuccess || status == errSecItemNotFound
        
        print("KeychainHelper: Delete status code: \(status), success: \(success)")
        
        return success
    }
    
    /// Check whether avatar data exists for a user
    /// - Parameter userId: User ID
    /// - Returns: Whether avatar data exists
    func hasAvatarData(forUserId userId: String) -> Bool {
        return loadAvatarData(forUserId: userId) != nil
    }
    
    // MARK: - Helper Methods
    
    /// Clear all avatar data (for debugging or reset)
    /// Note: Keychain does not support wildcard deletion; you still need specific user IDs in real usage.
    func clearAllAvatarData() -> Bool {
        // Note: Keychain does not support wildcard queries, this method is just a placeholder API.
        // In real usage, you must know which user IDs you want to delete.
        print("Warning: clearAllAvatarData requires specific user IDs to actually delete data")
        return true
    }
}

// MARK: - Extensions for UIImage

extension KeychainHelper {
    
    /// Save UIImage to Keychain
    /// - Parameters:
    ///   - image: Image to save
    ///   - userId: User ID
    ///   - compressionQuality: Compression quality (0.0 - 1.0)
    /// - Returns: Whether the save operation succeeded
    func saveAvatarImage(_ image: UIImage, forUserId userId: String, compressionQuality: CGFloat = 0.8) -> Bool {
        print("KeychainHelper: Start compressing image, quality: \(compressionQuality)")
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            print("KeychainHelper: Failed to compress image")
            return false
        }
        
        print("KeychainHelper: Image compressed successfully, data size: \(imageData.count) bytes")
        
        let result = saveAvatarData(imageData, forUserId: userId)
        print("KeychainHelper: Save to Keychain result: \(result)")
        
        return result
    }
    
    /// Load UIImage from Keychain
    /// - Parameter userId: User ID
    /// - Returns: Avatar image, or nil if not found
    func loadAvatarImage(forUserId userId: String) -> UIImage? {
        guard let imageData = loadAvatarData(forUserId: userId) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - UIImage Extension for Avatar Management

extension UIImage {
    
    /// Save current image as avatar into Keychain
    /// - Parameter compressionQuality: Compression quality (0.0 - 1.0)
    /// - Returns: Whether the save operation succeeded
    func saveAvatarImage(compressionQuality: CGFloat = 0.8) -> Bool {
        guard let currentUserId = getCurrentUserId() else {
            print("UIImage.saveAvatarImage: Failed to get current user ID")
            return false
        }
        
        return KeychainHelper.shared.saveAvatarImage(self, forUserId: currentUserId, compressionQuality: compressionQuality)
    }
    
    /// Load avatar image from Keychain
    /// - Returns: Avatar image, or nil if not found
    static func loadAvatarImage() -> UIImage? {
        guard let currentUserId = getCurrentUserId() else {
            print("UIImage.loadAvatarImage: Failed to get current user ID")
            return nil
        }
        
        return KeychainHelper.shared.loadAvatarImage(forUserId: currentUserId)
    }
    
    /// Helper to get current user ID
    private static func getCurrentUserId() -> String? {
        // Requires FirebaseAuth import
        guard let currentUser = FirebaseAuth.Auth.auth().currentUser else {
            return nil
        }
        return currentUser.uid
    }
    
    /// Helper to get current user ID (instance method version)
    private func getCurrentUserId() -> String? {
        return UIImage.getCurrentUserId()
    }
}
