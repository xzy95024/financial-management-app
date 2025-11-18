//
//  ProfileViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Avatar section
    private let avatarContainerView = UIView()
    private let avatarImageView = UIImageView()
    private let editAvatarButton = UIButton(type: .system)
    
    // User info section
    private let userInfoContainerView = UIView()
    private let usernameLabel = UILabel()
    private let usernameValueLabel = UILabel()
    private let phoneLabel = UILabel()
    private let phoneValueLabel = UILabel()
    private let emailLabel = UILabel()
    private let emailValueLabel = UILabel()
    
    // Time info section
    private let timeInfoContainerView = UIView()
    private let registrationTimeLabel = UILabel()
    private let registrationTimeValueLabel = UILabel()
    private let lastLoginTimeLabel = UILabel()
    private let lastLoginTimeValueLabel = UILabel()
    
    // MARK: - Properties
    private var userInfo: UserInfo?
    private var isEditMode = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadUserInfo()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        
        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Avatar section
        setupAvatarSection()
        
        // User info section
        setupUserInfoSection()
        
        // Time info section
        setupTimeInfoSection()
        
        // Add sections to content view
        contentView.addSubview(avatarContainerView)
        contentView.addSubview(userInfoContainerView)
        contentView.addSubview(timeInfoContainerView)
    }
    
    private func setupAvatarSection() {
        avatarContainerView.backgroundColor = UIColor.systemBackground
        avatarContainerView.layer.cornerRadius = 12
        avatarContainerView.layer.shadowColor = UIColor.black.cgColor
        avatarContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        avatarContainerView.layer.shadowRadius = 4
        avatarContainerView.layer.shadowOpacity = 0.1
        
        // Avatar image
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.backgroundColor = UIColor.systemGray5
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = UIColor.systemGray3
        
        // Tap to change avatar
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        // Legacy edit button (kept but hidden – avatar is edited via tap)
        editAvatarButton.setTitle("Change Avatar", for: .normal)
        editAvatarButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editAvatarButton.setTitleColor(UIColor.systemBlue, for: .normal)
        editAvatarButton.addTarget(self, action: #selector(editAvatarTapped), for: .touchUpInside)
        editAvatarButton.isHidden = true
        
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(editAvatarButton)
    }
    
    private func setupUserInfoSection() {
        userInfoContainerView.backgroundColor = UIColor.systemBackground
        userInfoContainerView.layer.cornerRadius = 12
        userInfoContainerView.layer.shadowColor = UIColor.black.cgColor
        userInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userInfoContainerView.layer.shadowRadius = 4
        userInfoContainerView.layer.shadowOpacity = 0.1
        
        // Username
        usernameLabel.text = "Username"
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        usernameLabel.textColor = UIColor.label
        
        usernameValueLabel.font = UIFont.systemFont(ofSize: 16)
        usernameValueLabel.textColor = UIColor.secondaryLabel
        usernameValueLabel.textAlignment = .right
        
        // Phone
        phoneLabel.text = "Phone"
        phoneLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        phoneLabel.textColor = UIColor.label
        
        phoneValueLabel.font = UIFont.systemFont(ofSize: 16)
        phoneValueLabel.textColor = UIColor.secondaryLabel
        phoneValueLabel.textAlignment = .right
        
        // Email
        emailLabel.text = "Email"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emailLabel.textColor = UIColor.label
        
        emailValueLabel.font = UIFont.systemFont(ofSize: 16)
        emailValueLabel.textColor = UIColor.secondaryLabel
        emailValueLabel.textAlignment = .right
        
        userInfoContainerView.addSubview(usernameLabel)
        userInfoContainerView.addSubview(usernameValueLabel)
        userInfoContainerView.addSubview(phoneLabel)
        userInfoContainerView.addSubview(phoneValueLabel)
        userInfoContainerView.addSubview(emailLabel)
        userInfoContainerView.addSubview(emailValueLabel)
    }
    
    private func setupTimeInfoSection() {
        timeInfoContainerView.backgroundColor = UIColor.systemBackground
        timeInfoContainerView.layer.cornerRadius = 12
        timeInfoContainerView.layer.shadowColor = UIColor.black.cgColor
        timeInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        timeInfoContainerView.layer.shadowRadius = 4
        timeInfoContainerView.layer.shadowOpacity = 0.1
        
        // Registration time
        registrationTimeLabel.text = "Joined"
        registrationTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        registrationTimeLabel.textColor = UIColor.label
        
        registrationTimeValueLabel.font = UIFont.systemFont(ofSize: 16)
        registrationTimeValueLabel.textColor = UIColor.secondaryLabel
        registrationTimeValueLabel.textAlignment = .right
        
        // Last login time
        lastLoginTimeLabel.text = "Last Sign-in"
        lastLoginTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lastLoginTimeLabel.textColor = UIColor.label
        
        lastLoginTimeValueLabel.font = UIFont.systemFont(ofSize: 16)
        lastLoginTimeValueLabel.textColor = UIColor.secondaryLabel
        lastLoginTimeValueLabel.textAlignment = .right
        
        timeInfoContainerView.addSubview(registrationTimeLabel)
        timeInfoContainerView.addSubview(registrationTimeValueLabel)
        timeInfoContainerView.addSubview(lastLoginTimeLabel)
        timeInfoContainerView.addSubview(lastLoginTimeValueLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        editAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        userInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        timeInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Labels
        [
            usernameLabel, usernameValueLabel,
            phoneLabel, phoneValueLabel,
            emailLabel, emailValueLabel,
            registrationTimeLabel, registrationTimeValueLabel,
            lastLoginTimeLabel, lastLoginTimeValueLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Avatar container
            avatarContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 160),
            
            // Avatar image
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Edit avatar button (hidden but kept)
            editAvatarButton.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            editAvatarButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            
            // User info container
            userInfoContainerView.topAnchor.constraint(equalTo: avatarContainerView.bottomAnchor, constant: 20),
            userInfoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userInfoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            userInfoContainerView.heightAnchor.constraint(equalToConstant: 180),
            
            // Username
            usernameLabel.topAnchor.constraint(equalTo: userInfoContainerView.topAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor, constant: 16),
            
            usernameValueLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            usernameValueLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor, constant: -16),
            usernameValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor, constant: 16),
            
            // Phone
            phoneLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 30),
            phoneLabel.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor, constant: 16),
            
            phoneValueLabel.centerYAnchor.constraint(equalTo: phoneLabel.centerYAnchor),
            phoneValueLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor, constant: -16),
            phoneValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: phoneLabel.trailingAnchor, constant: 16),
            
            // Email
            emailLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 30),
            emailLabel.leadingAnchor.constraint(equalTo: userInfoContainerView.leadingAnchor, constant: 16),
            
            emailValueLabel.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            emailValueLabel.trailingAnchor.constraint(equalTo: userInfoContainerView.trailingAnchor, constant: -16),
            emailValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emailLabel.trailingAnchor, constant: 16),
            
            // Time info container
            timeInfoContainerView.topAnchor.constraint(equalTo: userInfoContainerView.bottomAnchor, constant: 20),
            timeInfoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeInfoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeInfoContainerView.heightAnchor.constraint(equalToConstant: 120),
            timeInfoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Registration time
            registrationTimeLabel.topAnchor.constraint(equalTo: timeInfoContainerView.topAnchor, constant: 20),
            registrationTimeLabel.leadingAnchor.constraint(equalTo: timeInfoContainerView.leadingAnchor, constant: 16),
            
            registrationTimeValueLabel.centerYAnchor.constraint(equalTo: registrationTimeLabel.centerYAnchor),
            registrationTimeValueLabel.trailingAnchor.constraint(equalTo: timeInfoContainerView.trailingAnchor, constant: -16),
            registrationTimeValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: registrationTimeLabel.trailingAnchor, constant: 16),
            
            // Last login time
            lastLoginTimeLabel.topAnchor.constraint(equalTo: registrationTimeLabel.bottomAnchor, constant: 30),
            lastLoginTimeLabel.leadingAnchor.constraint(equalTo: timeInfoContainerView.leadingAnchor, constant: 16),
            
            lastLoginTimeValueLabel.centerYAnchor.constraint(equalTo: lastLoginTimeLabel.centerYAnchor),
            lastLoginTimeValueLabel.trailingAnchor.constraint(equalTo: timeInfoContainerView.trailingAnchor, constant: -16),
            lastLoginTimeValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: lastLoginTimeLabel.trailingAnchor, constant: 16)
        ])
    }
    
    // MARK: - Data Loading
    private func loadUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load user profile: \(error.localizedDescription)")
                    self?.loadBasicUserInfo()
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    self?.updateUI(with: data, currentUser: currentUser)
                } else {
                    self?.loadBasicUserInfo()
                }
            }
        }
    }
    
    /// Fallback when there is no custom user document – use FirebaseAuth basic info
    private func loadBasicUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        usernameValueLabel.text = currentUser.displayName ?? "Not set"
        phoneValueLabel.text = currentUser.phoneNumber ?? "Not set"
        emailValueLabel.text = currentUser.email ?? "Not set"
        
        // Registration time
        if let creationDate = currentUser.metadata.creationDate {
            registrationTimeValueLabel.text = formatDate(creationDate)
        } else {
            registrationTimeValueLabel.text = "Unknown"
        }
        
        // Last sign-in time
        if let lastSignInDate = currentUser.metadata.lastSignInDate {
            lastLoginTimeValueLabel.text = formatDate(lastSignInDate)
        } else {
            lastLoginTimeValueLabel.text = "Unknown"
        }
    }
    
    private func updateUI(with data: [String: Any]?, currentUser: FirebaseAuth.User) {
        usernameValueLabel.text = data?["displayName"] as? String
            ?? currentUser.displayName
            ?? "Not set"
        
        phoneValueLabel.text = data?["phoneNumber"] as? String
            ?? currentUser.phoneNumber
            ?? "Not set"
        
        emailValueLabel.text = data?["email"] as? String
            ?? currentUser.email
            ?? "Not set"
        
        // Registration time
        if let createdAt = data?["createdAt"] as? Timestamp {
            registrationTimeValueLabel.text = formatDate(createdAt.dateValue())
        } else if let creationDate = currentUser.metadata.creationDate {
            registrationTimeValueLabel.text = formatDate(creationDate)
        } else {
            registrationTimeValueLabel.text = "Unknown"
        }
        
        // Last sign-in time
        if let lastLoginAt = data?["lastLoginAt"] as? Timestamp {
            lastLoginTimeValueLabel.text = formatDate(lastLoginAt.dateValue())
        } else if let lastSignInDate = currentUser.metadata.lastSignInDate {
            lastLoginTimeValueLabel.text = formatDate(lastSignInDate)
        } else {
            lastLoginTimeValueLabel.text = "Unknown"
        }
        
        // Load avatar from Keychain
        loadAvatarFromKeychain(userId: currentUser.uid)
    }
    
    private func loadAvatarFromKeychain(userId: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let avatarImage = KeychainHelper.shared.loadAvatarImage(forUserId: userId) {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = avatarImage
                }
            } else {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        // e.g. "Nov 18, 2025 at 10:23 AM"
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        isEditMode.toggle()
        updateEditMode()
    }
    
    @objc private func avatarTapped() {
        // Tap directly opens avatar picker
        editAvatarTapped()
    }
    
    @objc private func editAvatarTapped() {
        let alert = UIAlertController(
            title: "Change Avatar",
            message: "Choose how you’d like to update your avatar.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func updateEditMode() {
        navigationItem.rightBarButtonItem?.title = isEditMode ? "Done" : "Edit"
        
        if isEditMode {
            showEditAlert()
        }
    }
    
    private func showEditAlert() {
        let alert = UIAlertController(
            title: "Edit Profile",
            message: "Update your basic info.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = (self.usernameValueLabel.text == "Not set") ? "" : self.usernameValueLabel.text
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Phone"
            textField.keyboardType = .phonePad
            textField.text = (self.phoneValueLabel.text == "Not set") ? "" : self.phoneValueLabel.text
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let username = alert.textFields?[0].text ?? ""
            let phone = alert.textFields?[1].text ?? ""
            self.saveUserInfo(username: username, phone: phone)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isEditMode = false
            self.updateEditMode()
        })
        
        present(alert, animated: true)
    }
    
    private func saveUserInfo(username: String, phone: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        var updateData: [String: Any] = [
            "updatedAt": Timestamp(date: Date())
        ]
        
        if !username.isEmpty {
            updateData["displayName"] = username
        }
        
        if !phone.isEmpty {
            updateData["phoneNumber"] = phone
        }
        
        // Update last login timestamp as “recent activity”
        updateData["lastLoginAt"] = Timestamp(date: Date())
        
        userRef.setData(updateData, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(
                        title: "Save Failed",
                        message: error.localizedDescription
                    )
                } else {
                    self?.showAlert(
                        title: "Profile Updated",
                        message: "Your profile information has been saved."
                    )
                    self?.loadUserInfo()
                }
                
                self?.isEditMode = false
                self?.updateEditMode()
            }
        }
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage
            ?? info[.originalImage] as? UIImage else { return }
        
        avatarImageView.image = image
        uploadAvatar(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func uploadAvatar(image: UIImage) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "No logged-in user.")
            return
        }
        
        print("uploadAvatar: start, userID: \(currentUser.uid)")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("uploadAvatar: saving avatar to Keychain in background")
            
            let success = KeychainHelper.shared.saveAvatarImage(
                image,
                forUserId: currentUser.uid,
                compressionQuality: 0.8
            )
            
            print("uploadAvatar: save finished, success: \(success)")
            
            DispatchQueue.main.async {
                if success {
                    self?.avatarImageView.image = image
                    self?.showAlert(title: "Avatar Updated", message: "Your avatar has been saved.")
                    print("uploadAvatar: success alert shown")
                    self?.updateAvatarStatus(hasAvatar: true)
                } else {
                    self?.showAlert(title: "Save Failed", message: "Unable to save avatar locally.")
                    print("uploadAvatar: failure alert shown")
                }
            }
        }
    }
    
    private func updateAvatarStatus(hasAvatar: Bool) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).updateData([
            "hasAvatar": hasAvatar,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Failed to update avatar status: \(error.localizedDescription)")
            } else {
                print("Avatar status updated successfully")
            }
        }
    }
}

// MARK: - UserInfo Model
struct UserInfo {
    var displayName: String?
    var phoneNumber: String?
    var email: String?
    var hasAvatar: Bool?
    var createdAt: Date?
    var lastLoginAt: Date?
}
