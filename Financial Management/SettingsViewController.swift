//
//  SettingsViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let userInfoCardView = UIView()
    private let avatarImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let userEmailLabel = UILabel()
    private let settingsTableView = UITableView()
    
    // Settings items: (title, SF Symbol name, icon color)
    private let settingsItems = [
        ("Category Management", "folder.fill", UIColor.systemBlue),
        // ("Export Data", "square.and.arrow.up.fill", UIColor.systemGreen),
        // ("Theme", "paintbrush.fill", UIColor.systemPurple),
        ("About App", "info.circle.fill", UIColor.systemGray),
        ("Sign Out", "power", UIColor.systemRed)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // User info card
        setupUserInfoCard()
        
        // Settings table
        settingsTableView.backgroundColor = UIColor.clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.isScrollEnabled = false
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
        // Add subviews
        contentView.addSubview(userInfoCardView)
        contentView.addSubview(settingsTableView)
    }
    
    private func setupUserInfoCard() {
        userInfoCardView.backgroundColor = UIColor.systemBackground
        userInfoCardView.layer.cornerRadius = 12
        userInfoCardView.layer.shadowColor = UIColor.black.cgColor
        userInfoCardView.layer.shadowOpacity = 0.05
        userInfoCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userInfoCardView.layer.shadowRadius = 4
        
        // Tap gesture – go to profile screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userInfoCardTapped))
        userInfoCardView.addGestureRecognizer(tapGesture)
        userInfoCardView.isUserInteractionEnabled = true
        
        // Avatar
        avatarImageView.backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        // Username
        userNameLabel.text = "User"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        userNameLabel.textColor = UIColor.label
        
        // Email
        userEmailLabel.text = "user@example.com"
        userEmailLabel.font = UIFont.systemFont(ofSize: 14)
        userEmailLabel.textColor = UIColor.systemGray
        
        // Add subviews
        userInfoCardView.addSubview(avatarImageView)
        userInfoCardView.addSubview(userNameLabel)
        userInfoCardView.addSubview(userEmailLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        // Disable autoresizing-mask translation
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        userInfoCardView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // User info card
            userInfoCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            userInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            userInfoCardView.heightAnchor.constraint(equalToConstant: 100),
            
            // Avatar
            avatarImageView.leadingAnchor.constraint(equalTo: userInfoCardView.leadingAnchor, constant: 20),
            avatarImageView.centerYAnchor.constraint(equalTo: userInfoCardView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Username
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 5),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: userInfoCardView.trailingAnchor, constant: -20),
            
            // Email
            userEmailLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userEmailLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -5),
            userEmailLabel.trailingAnchor.constraint(lessThanOrEqualTo: userInfoCardView.trailingAnchor, constant: -20),
            
            // Settings table
            settingsTableView.topAnchor.constraint(equalTo: userInfoCardView.bottomAnchor, constant: 30),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            settingsTableView.heightAnchor.constraint(equalToConstant: CGFloat(settingsItems.count * 60)),
            settingsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Data Setup
    private func setupData() {
        loadUserInfo()
    }
    
    // MARK: - User Info Management
    private func loadUserInfo() {
        guard let currentUser = Auth.auth().currentUser else {
            print("SettingsViewController: No authenticated user")
            return
        }
        
        // Update basic info from Auth
        userEmailLabel.text = currentUser.email
        
        // Fetch user profile from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("SettingsViewController: Failed to fetch user info: \(error.localizedDescription)")
                    // Fallback to Auth info only
                    self?.updateUIWithAuthInfo(currentUser)
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    self?.updateUIWithFirestoreData(data, authUser: currentUser)
                } else {
                    print("SettingsViewController: User document does not exist, using Auth info")
                    self?.updateUIWithAuthInfo(currentUser)
                }
            }
        }
    }
    
    private func updateUIWithFirestoreData(_ data: [String: Any], authUser: FirebaseAuth.User) {
        // Display name
        if let displayName = data["displayName"] as? String, !displayName.isEmpty {
            userNameLabel.text = displayName
        } else if let authDisplayName = authUser.displayName, !authDisplayName.isEmpty {
            userNameLabel.text = authDisplayName
        } else {
            // Fallback: prefix of email as username
            let email = authUser.email ?? "User"
            userNameLabel.text = String(email.split(separator: "@").first ?? "User")
        }
        
        // Avatar from Keychain
        loadAvatarFromKeychain()
    }
    
    private func updateUIWithAuthInfo(_ authUser: FirebaseAuth.User) {
        if let displayName = authUser.displayName, !displayName.isEmpty {
            userNameLabel.text = displayName
        } else if let email = authUser.email {
            userNameLabel.text = String(email.split(separator: "@").first ?? "User")
        } else {
            userNameLabel.text = "User"
        }
        
        // Avatar from Keychain
        loadAvatarFromKeychain()
    }
    
    private func loadAvatarFromKeychain() {
        print("SettingsViewController: Trying to load avatar from Keychain")
        
        if let avatarImage = UIImage.loadAvatarImage() {
            print("SettingsViewController: Avatar loaded from Keychain")
            avatarImageView.image = avatarImage
            avatarImageView.backgroundColor = UIColor.clear
        } else {
            print("SettingsViewController: No avatar in Keychain, using default avatar style")
            setDefaultAvatar()
        }
    }
    
    private func setDefaultAvatar() {
        avatarImageView.image = nil
        avatarImageView.backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
    }
    
    // Navigate to profile screen when tapping the user card
    @objc private func userInfoCardTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        let item = settingsItems[indexPath.row]
        cell.configure(title: item.0, iconName: item.1, iconColor: item.2)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 60
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingsItems[indexPath.row]
        print("SettingsViewController: Selected setting item: \(item.0)")
        
        // Handle each settings item by index
        switch indexPath.row {
        case 0: // Category Management
            let categoryManagementVC = CategoryManagementViewController()
            navigationController?.pushViewController(categoryManagementVC, animated: true)
            
        case 1: // About App
            showAboutAppAlert()
            
        case 2: // Sign Out
            showLogoutAlert()
            
        default:
            break
        }
    }
    
    private func showAboutAppAlert() {
        let alert = UIAlertController(
            title: "About Financial Butler",
            message: """
            📱 Financial Butler v1.0
            
            A simple, focused personal finance app that helps you:
            • Track daily income and expenses
            • Organize spending by category
            • Manage merchant profiles
            • Analyze your spending trends
            
            🔒 Your data is securely stored in the cloud
            💡 Continuously improving – thank you for using the app!
            
            © 2025 Financial Butler Team
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAction(title: "Sign Out", style: .destructive) { _ in
                AuthManager.shared.logout()
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            }
        )
        
        present(alert, animated: true)
    }
}

// MARK: - SettingsTableViewCell
class SettingsTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Basic cell UI
    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.white
        iconImageView.backgroundColor = UIColor.systemBlue
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        
        // Title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.label
        
        // Chevron
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = UIColor.systemGray3
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
    }
    
    // Layout constraints
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -10),
            
            // Chevron
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // Public configure method
    func configure(title: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.backgroundColor = iconColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Card-style inset
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Shadow on outer layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
}
