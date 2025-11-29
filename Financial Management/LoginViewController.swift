import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Logo and titles
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Input container
    private let inputContainerView = UIView()
    
    // Email input
    private let emailContainerView = UIView()
    private let emailIconImageView = UIImageView()
    private let emailTextField = UITextField()
    
    // Password input
    private let passwordContainerView = UIView()
    private let passwordIconImageView = UIImageView()
    private let passwordTextField = UITextField()
    private let showPasswordButton = UIButton(type: .custom)
    
    // Buttons
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    // Loading indicator
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    private let authManager = AuthManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0).cgColor,  // #667eea
            UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0).cgColor   // #764ba2
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // ScrollView
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        // Logo
        logoImageView.image = UIImage(systemName: "creditcard.circle.fill")
        logoImageView.tintColor = .white
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        
        // Title
        titleLabel.text = "VendorLog"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Smart budgeting, personalized Merchant Insights"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        contentView.addSubview(subtitleLabel)
        
        // Input container
        inputContainerView.backgroundColor = UIColor.white
        inputContainerView.layer.cornerRadius = 20
        inputContainerView.layer.shadowColor = UIColor.black.cgColor
        inputContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        inputContainerView.layer.shadowRadius = 12
        inputContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(inputContainerView)
        
        // Email input container
        setupInputContainer(
            containerView: emailContainerView,
            iconImageView: emailIconImageView,
            textField: emailTextField,
            iconName: "envelope.fill",
            placeholder: "Enter email address"
        )
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        inputContainerView.addSubview(emailContainerView)
        
        // Password input container
        setupInputContainer(
            containerView: passwordContainerView,
            iconImageView: passwordIconImageView,
            textField: passwordTextField,
            iconName: "lock.fill",
            placeholder: "Enter password"
        )
        passwordTextField.isSecureTextEntry = true
        
        // Show / hide password button
        showPasswordButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        showPasswordButton.tintColor = UIColor.systemGray
        passwordContainerView.addSubview(showPasswordButton)
        
        inputContainerView.addSubview(passwordContainerView)
        
        // Login button
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
        loginButton.layer.cornerRadius = 25
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.shadowRadius = 8
        loginButton.layer.shadowOpacity = 0.2
        contentView.addSubview(loginButton)
        
        // Register button
        registerButton.setTitle("Don't have an account? Sign up now", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        registerButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(registerButton)
        
        // Loading indicator
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        contentView.addSubview(loadingIndicator)
    }
    
    private func setupInputContainer(
        containerView: UIView,
        iconImageView: UIImageView,
        textField: UITextField,
        iconName: String,
        placeholder: String
    ) {
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        
        // Icon
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor.systemGray
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        
        // Text field
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor.label
        textField.borderStyle = .none
        textField.delegate = self
        containerView.addSubview(textField)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        emailContainerView.translatesAutoresizingMaskIntoConstraints = false
        emailIconImageView.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordContainerView.translatesAutoresizingMaskIntoConstraints = false
        passwordIconImageView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
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
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Input container
            inputContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            inputContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            inputContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            // Email container
            emailContainerView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 30),
            emailContainerView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 20),
            emailContainerView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -20),
            emailContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Email icon
            emailIconImageView.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 15),
            emailIconImageView.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailIconImageView.widthAnchor.constraint(equalToConstant: 20),
            emailIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Email text field
            emailTextField.leadingAnchor.constraint(equalTo: emailIconImageView.trailingAnchor, constant: 15),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -15),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            
            // Password container
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 15),
            passwordContainerView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 20),
            passwordContainerView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -20),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 50),
            passwordContainerView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -30),
            
            // Password icon
            passwordIconImageView.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 15),
            passwordIconImageView.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordIconImageView.widthAnchor.constraint(equalToConstant: 20),
            passwordIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Show password button
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -15),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 24),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Password text field
            passwordTextField.leadingAnchor.constraint(equalTo: passwordIconImageView.trailingAnchor, constant: 15),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -10),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 40),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Register button
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text else {
            showAlert(message: "Please enter email and password")
            return
        }
        
        setLoading(true)
        
        authManager.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success:
                    // Login succeeded, notify SceneDelegate to update root UI
                    NotificationCenter.default.post(name: .userDidLogin, object: nil)
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Helper Methods
    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.6 : 1.0
        
        if loading {
            loadingIndicator.startAnimating()
            loginButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            loginButton.setTitle("Log In", for: .normal)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginButtonTapped()
        }
        return true
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}
