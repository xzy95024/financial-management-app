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
        
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupUserInfoCard()
        
        settingsTableView.backgroundColor = UIColor.clear
        settingsTableView.separatorStyle = .none
        settingsTableView.showsVerticalScrollIndicator = false
        settingsTableView.isScrollEnabled = false
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userInfoCardTapped))
        userInfoCardView.addGestureRecognizer(tapGesture)
        userInfoCardView.isUserInteractionEnabled = true
        
        avatarImageView.backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        userNameLabel.text = "User"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        userEmailLabel.text = "user@example.com"
        userEmailLabel.font = UIFont.systemFont(ofSize: 14)
        userEmailLabel.textColor = UIColor.systemGray
        
        userInfoCardView.addSubview(avatarImageView)
        userInfoCardView.addSubview(userNameLabel)
        userInfoCardView.addSubview(userEmailLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        userInfoCardView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
            
            avatarImageView.leadingAnchor.constraint(equalTo: userInfoCardView.leadingAnchor, constant: 20),
            avatarImageView.centerYAnchor.constraint(equalTo: userInfoCardView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 5),
            
            userEmailLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userEmailLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -5),
            
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
    
    // MARK: - User Info Loading
    private func loadUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        userEmailLabel.text = currentUser.email
        
        Firestore.firestore()
            .collection("users")
            .document(currentUser.uid)
            .getDocument { [weak self] (document, error) in
                
                DispatchQueue.main.async {
                    if let data = document?.data() {
                        self?.updateUIWithFirestoreData(data, authUser: currentUser)
                    } else {
                        self?.updateUIWithAuthInfo(currentUser)
                    }
                }
            }
    }
    
    private func updateUIWithFirestoreData(_ data: [String: Any], authUser: FirebaseAuth.User) {
        if let name = data["displayName"] as? String, !name.isEmpty {
            userNameLabel.text = name
        } else {
            updateUIWithAuthInfo(authUser)
        }
        
        loadAvatarFromKeychain()
    }
    
    private func updateUIWithAuthInfo(_ authUser: FirebaseAuth.User) {
        if let name = authUser.displayName, !name.isEmpty {
            userNameLabel.text = name
        } else if let email = authUser.email {
            userNameLabel.text = String(email.split(separator: "@").first ?? "User")
        } else {
            userNameLabel.text = "User"
        }
        
        loadAvatarFromKeychain()
    }
    
    private func loadAvatarFromKeychain() {
        if let avatarImage = UIImage.loadAvatarImage() {
            avatarImageView.image = avatarImage
            avatarImageView.backgroundColor = .clear
        } else {
            setDefaultAvatar()
        }
    }
    
    private func setDefaultAvatar() {
        avatarImageView.image = nil
        avatarImageView.backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
    }
    
    @objc private func userInfoCardTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(CategoryManagementViewController(), animated: true)
        case 1:
            showAboutAppAlert()
        case 2:
            showLogoutAlert()
        default:
            break
        }
    }
    
    // MARK: - Alerts
    
    private func showAboutAppAlert() {
        let alert = UIAlertController(
            title: "About Financial Butler",
            message: """
            📱 Financial Butler v1.0
            
            A simple and secure personal finance app.
            • Track income and expenses
            • Categorize spending
            • Manage merchants
            • Analyze financial trends
            
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
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            AuthManager.shared.logout()
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        }
        
        alert.addAction(signOutAction)
        present(alert, animated: true)
    }
}

// MARK: - Settings Cell
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
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.white
        iconImageView.backgroundColor = UIColor.systemBlue
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray3
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
    }
    
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func configure(title: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.backgroundColor = iconColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(
            by: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20)
        )
        contentView.layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
}
