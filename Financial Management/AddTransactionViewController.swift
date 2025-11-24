//
//  AddTransactionViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit
import FirebaseAuth

class AddTransactionViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Transaction type selection
    private let typeSegmentedControl = UISegmentedControl(items: ["Expense", "Income"])
    
    // Amount input
    private let amountContainer = UIView()
    private let currencyLabel = UILabel()
    private let amountTextField = UITextField()
    
    // Category selection
    private let categoryContainer = UIView()
    private let categoryLabel = UILabel()
    private let categoryButton = UIButton(type: .system)
    private let categoryCollectionView: UICollectionView
    
    // Merchant input
    private let merchantContainer = UIView()
    private let merchantTextField = UITextField()
    private let merchantTableView = UITableView()
    private var merchantTableViewHeightConstraint: NSLayoutConstraint?
    private let historyMerchantButton = UIButton(type: .system)
    
    // Date selection
    private let dateContainer = UIView()
    private let dateTextField = UITextField()
    private let datePicker = UIDatePicker()
    
    // Note input
    private let noteContainer = UIView()
    private let noteTextView = UITextView()
    
    // Save button
    private let saveButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    private var selectedTransactionType: Transaction.TransactionType = .expense
    private var categories: [Category] = []
    private var selectedCategory: Category?
    private var merchants: [Merchant] = []
    private var filteredMerchants: [Merchant] = []
    private var selectedMerchant: Merchant?
    private var isMerchantTableVisible = false
    
    // Edit mode related properties
    var isEditMode: Bool = false
    var transactionToEdit: Transaction?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadCategories()
        loadMerchants()
        
        // If in edit mode, populate existing data
        if isEditMode {
            populateEditData()
        }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = isEditMode ? "Edit Transaction" : "Add Transaction"
        
        // Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Transaction type segmented control
        typeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        typeSegmentedControl.selectedSegmentIndex = 0
        typeSegmentedControl.backgroundColor = UIColor.systemGray6
        typeSegmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        typeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        contentView.addSubview(typeSegmentedControl)
        
        // Amount container
        setupAmountContainer()
        
        // Category container
        setupCategoryContainer()
        
        // Merchant container
        setupMerchantContainer()
        
        // Date container
        setupDateContainer()
        
        // Note container
        setupNoteContainer()
        
        // Save button
        setupSaveButton()
    }
    
    private func setupAmountContainer() {
        amountContainer.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.backgroundColor = UIColor.systemBackground
        amountContainer.layer.cornerRadius = 12
        amountContainer.layer.shadowColor = UIColor.black.cgColor
        amountContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        amountContainer.layer.shadowRadius = 4
        amountContainer.layer.shadowOpacity = 0.1
        contentView.addSubview(amountContainer)
        
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyLabel.text = "$"
        currencyLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        currencyLabel.textColor = UIColor.systemBlue
        amountContainer.addSubview(currencyLabel)
        
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.placeholder = "0.00"
        amountTextField.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        amountTextField.textColor = UIColor.label
        amountTextField.keyboardType = .decimalPad
        amountTextField.textAlignment = .left
        amountContainer.addSubview(amountTextField)
    }
    
    private func setupCategoryContainer() {
        categoryContainer.translatesAutoresizingMaskIntoConstraints = false
        categoryContainer.backgroundColor = UIColor.systemBackground
        categoryContainer.layer.cornerRadius = 12
        categoryContainer.layer.shadowColor = UIColor.black.cgColor
        categoryContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        categoryContainer.layer.shadowRadius = 4
        categoryContainer.layer.shadowOpacity = 0.1
        contentView.addSubview(categoryContainer)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.text = "Category"
        categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryLabel.textColor = UIColor.label
        categoryContainer.addSubview(categoryLabel)
        
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.backgroundColor = UIColor.clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoryContainer.addSubview(categoryCollectionView)
    }
    
    private func setupMerchantContainer() {
        merchantContainer.translatesAutoresizingMaskIntoConstraints = false
        merchantContainer.backgroundColor = UIColor.systemBackground
        merchantContainer.layer.cornerRadius = 12
        merchantContainer.layer.shadowColor = UIColor.black.cgColor
        merchantContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        merchantContainer.layer.shadowRadius = 4
        merchantContainer.layer.shadowOpacity = 0.1
        contentView.addSubview(merchantContainer)
        
        merchantTextField.translatesAutoresizingMaskIntoConstraints = false
        merchantTextField.placeholder = "Select or enter merchant name (optional)"
        merchantTextField.font = UIFont.systemFont(ofSize: 16)
        merchantTextField.borderStyle = .none
        merchantTextField.delegate = self
        merchantTextField.addTarget(self, action: #selector(merchantTextFieldChanged), for: .editingChanged)
        
        // Create merchant icon and set constraints
        let merchantIcon = UIImageView(image: UIImage(systemName: "storefront"))
        merchantIcon.translatesAutoresizingMaskIntoConstraints = false
        merchantIcon.tintColor = UIColor.systemGray
        merchantIcon.contentMode = .scaleAspectFit
        
        // Create a container view to hold the icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(merchantIcon)
        
        // Set icon constraints
        NSLayoutConstraint.activate([
            merchantIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            merchantIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            merchantIcon.widthAnchor.constraint(equalToConstant: 20),
            merchantIcon.heightAnchor.constraint(equalToConstant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 30),
            iconContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        merchantTextField.leftView = iconContainer
        merchantTextField.leftViewMode = .always
        merchantContainer.addSubview(merchantTextField)
        
        // Configure merchant table view
        merchantTableView.translatesAutoresizingMaskIntoConstraints = false
        merchantTableView.backgroundColor = UIColor.systemBackground
        merchantTableView.layer.cornerRadius = 8
        merchantTableView.layer.borderWidth = 1
        merchantTableView.layer.borderColor = UIColor.systemGray4.cgColor
        merchantTableView.separatorStyle = .singleLine
        merchantTableView.delegate = self
        merchantTableView.dataSource = self
        merchantTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MerchantCell")
        merchantTableView.isHidden = true
        merchantContainer.addSubview(merchantTableView)
        
        // Create height constraint
        merchantTableViewHeightConstraint = merchantTableView.heightAnchor.constraint(equalToConstant: 0)
        merchantTableViewHeightConstraint?.isActive = true
        
        // Configure history merchants button
        historyMerchantButton.translatesAutoresizingMaskIntoConstraints = false
        historyMerchantButton.setTitle("Recent Merchants", for: .normal)
        historyMerchantButton.setTitleColor(.systemBlue, for: .normal)
        historyMerchantButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        historyMerchantButton.backgroundColor = UIColor.systemGray6
        historyMerchantButton.layer.cornerRadius = 6
        historyMerchantButton.addTarget(self, action: #selector(historyMerchantButtonTapped), for: .touchUpInside)
        merchantContainer.addSubview(historyMerchantButton)
    }
    
    private func setupDateContainer() {
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.backgroundColor = UIColor.systemBackground
        dateContainer.layer.cornerRadius = 12
        dateContainer.layer.shadowColor = UIColor.black.cgColor
        dateContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        dateContainer.layer.shadowRadius = 4
        dateContainer.layer.shadowOpacity = 0.1
        contentView.addSubview(dateContainer)
        
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.placeholder = "Select date"
        dateTextField.font = UIFont.systemFont(ofSize: 16)
        dateTextField.borderStyle = .none
        let dateIcon = UIImageView(image: UIImage(systemName: "calendar"))
        dateIcon.tintColor = UIColor.systemGray
        dateTextField.leftView = dateIcon
        dateTextField.leftViewMode = .always
        dateContainer.addSubview(dateTextField)
        
        // Configure date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale.current
        dateTextField.inputView = datePicker
        
        // Set default date to today
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        dateTextField.text = formatter.string(from: Date())
    }
    
    private func setupNoteContainer() {
        noteContainer.translatesAutoresizingMaskIntoConstraints = false
        noteContainer.backgroundColor = UIColor.systemBackground
        noteContainer.layer.cornerRadius = 12
        noteContainer.layer.shadowColor = UIColor.black.cgColor
        noteContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        noteContainer.layer.shadowRadius = 4
        noteContainer.layer.shadowOpacity = 0.1
        contentView.addSubview(noteContainer)
        
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        noteTextView.backgroundColor = UIColor.clear
        noteTextView.layer.cornerRadius = 8
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        noteTextView.text = "Note (optional)"
        noteTextView.textColor = UIColor.placeholderText
        noteTextView.delegate = self
        noteContainer.addSubview(noteTextView)
    }
    
    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Transaction", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.layer.shadowColor = UIColor.systemBlue.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 8
        saveButton.layer.shadowOpacity = 0.3
        contentView.addSubview(saveButton)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        saveButton.addSubview(loadingIndicator)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
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
            
            // Transaction type segmented control
            typeSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            typeSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            // Amount container
            amountContainer.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 20),
            amountContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            amountContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amountContainer.heightAnchor.constraint(equalToConstant: 80),
            
            currencyLabel.leadingAnchor.constraint(equalTo: amountContainer.leadingAnchor, constant: 20),
            currencyLabel.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            
            amountTextField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8),
            amountTextField.trailingAnchor.constraint(equalTo: amountContainer.trailingAnchor, constant: -20),
            amountTextField.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            
            // Category container
            categoryContainer.topAnchor.constraint(equalTo: amountContainer.bottomAnchor, constant: 20),
            categoryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryContainer.heightAnchor.constraint(equalToConstant: 120),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 20),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            categoryCollectionView.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 20),
            categoryCollectionView.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -20),
            categoryCollectionView.bottomAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: -16),
            
            // Merchant container
            merchantContainer.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 20),
            merchantContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            merchantContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            merchantContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            merchantTextField.leadingAnchor.constraint(equalTo: merchantContainer.leadingAnchor, constant: 20),
            merchantTextField.trailingAnchor.constraint(equalTo: merchantContainer.trailingAnchor, constant: -20),
            merchantTextField.topAnchor.constraint(equalTo: merchantContainer.topAnchor, constant: 20),
            merchantTextField.heightAnchor.constraint(equalToConstant: 20),
            
            // History merchants button constraints
            historyMerchantButton.topAnchor.constraint(equalTo: merchantTextField.bottomAnchor, constant: 8),
            historyMerchantButton.leadingAnchor.constraint(equalTo: merchantContainer.leadingAnchor, constant: 20),
            historyMerchantButton.widthAnchor.constraint(equalToConstant: 120),
            historyMerchantButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Merchant table view constraints
            merchantTableView.topAnchor.constraint(equalTo: historyMerchantButton.bottomAnchor, constant: 8),
            merchantTableView.leadingAnchor.constraint(equalTo: merchantContainer.leadingAnchor, constant: 10),
            merchantTableView.trailingAnchor.constraint(equalTo: merchantContainer.trailingAnchor, constant: -10),
            merchantTableView.bottomAnchor.constraint(equalTo: merchantContainer.bottomAnchor, constant: -10),
            
            // Date container
            dateContainer.topAnchor.constraint(equalTo: merchantContainer.bottomAnchor, constant: 20),
            dateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateContainer.heightAnchor.constraint(equalToConstant: 60),
            
            dateTextField.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 20),
            dateTextField.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: -20),
            dateTextField.centerYAnchor.constraint(equalTo: dateContainer.centerYAnchor),
            
            // Note container
            noteContainer.topAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: 20),
            noteContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            noteContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            noteContainer.heightAnchor.constraint(equalToConstant: 100),
            
            noteTextView.topAnchor.constraint(equalTo: noteContainer.topAnchor, constant: 8),
            noteTextView.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor, constant: 8),
            noteTextView.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor, constant: -8),
            noteTextView.bottomAnchor.constraint(equalTo: noteContainer.bottomAnchor, constant: -8),
            
            // Save button
            saveButton.topAnchor.constraint(equalTo: noteContainer.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        typeSegmentedControl.addTarget(self, action: #selector(transactionTypeChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveTransaction), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // Add keyboard toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        amountTextField.inputAccessoryView = toolbar
        
        // Add tap gesture recognizer to hide merchant list
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideMerchantTable))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func transactionTypeChanged() {
        selectedTransactionType = typeSegmentedControl.selectedSegmentIndex == 0 ? .expense : .income
        loadCategories()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTransaction() {
        guard validateInput() else { return }
        
        setLoadingState(true)
        
        print("💾 Start saving transaction")
        
        if isEditMode {
            // Edit mode: update existing transaction
            guard let transactionToEdit = transactionToEdit else { return }
            
            var updatedTransaction = createTransaction()
            updatedTransaction.id = transactionToEdit.id
            updatedTransaction.createdAt = transactionToEdit.createdAt
            updatedTransaction.updatedAt = Date()
            
            print("✏️ Edit mode: updating transaction ID: \(transactionToEdit.id ?? "unknown")")
            
            DataManager.shared.updateTransaction(updatedTransaction) { [weak self] result in
                DispatchQueue.main.async {
                    self?.setLoadingState(false)
                    
                    switch result {
                    case .success:
                        print("✅ Transaction updated successfully")
                        // After successful update, update merchant stats and recent transaction list
                        if let merchantName = updatedTransaction.merchantName,
                           let merchant = self?.findExistingMerchant(name: merchantName),
                           let transactionId = updatedTransaction.id,
                           let categoryName = updatedTransaction.categoryName {
                            print("🔄 Updating merchant stats and recent transactions: \(merchantName)")
                            
                            // Update merchant recent transactions
                            self?.updateMerchantRecentTransactions(
                                merchant: merchant,
                                transactionId: transactionId,
                                amount: updatedTransaction.amount,
                                date: updatedTransaction.date,
                                categoryName: categoryName
                            )
                        }
                        self?.showSuccessAlert()
                    case .failure(let error):
                        print("❌ Failed to update transaction: \(error.localizedDescription)")
                        self?.showErrorAlert(error.localizedDescription)
                    }
                }
            }
        } else {
            // Add mode: create new transaction
            let transaction = createTransaction()
            
            print("➕ Add mode: creating new transaction, merchant: \(transaction.merchantName ?? "none")")
            
            DataManager.shared.addTransaction(transaction) { [weak self] result in
                DispatchQueue.main.async {
                    self?.setLoadingState(false)
                    
                    switch result {
                    case .success(let transactionId):
                        print("✅ Transaction created successfully, ID: \(transactionId)")
                        // After successful creation, handle merchant-related logic
                        if let merchantName = transaction.merchantName, !merchantName.isEmpty {
                            print("🏪 Handling merchant logic: \(merchantName)")
                            if let merchant = self?.selectedMerchant {
                                print("📝 Using selected merchant: \(merchant.merchantDisplayName)")
                                
                                // Update merchant recent transactions
                                if let categoryName = transaction.categoryName {
                                    self?.updateMerchantRecentTransactions(
                                        merchant: merchant,
                                        transactionId: transactionId,
                                        amount: transaction.amount,
                                        date: transaction.date,
                                        categoryName: categoryName
                                    )
                                }
                            } else {
                                // Check if a merchant with the same name already exists
                                if let existingMerchant = self?.findExistingMerchant(name: merchantName) {
                                    print("🔍 Found existing merchant: \(existingMerchant.merchantDisplayName)")
                                    
                                    // Update merchant recent transactions
                                    if let categoryName = transaction.categoryName {
                                        self?.updateMerchantRecentTransactions(
                                            merchant: existingMerchant,
                                            transactionId: transactionId,
                                            amount: transaction.amount,
                                            date: transaction.date,
                                            categoryName: categoryName
                                        )
                                    }
                                } else {
                                    print("🆕 Need to create new merchant: \(merchantName)")
                                    // If not exists, create new merchant
                                    if let categoryName = transaction.categoryName {
                                        self?.createNewMerchant(
                                            name: merchantName,
                                            amount: transaction.amount,
                                            date: transaction.date,
                                            transactionId: transactionId,
                                            categoryName: categoryName
                                        )
                                    }
                                }
                            }
                        }
                        self?.showSuccessAlert()
                    case .failure(let error):
                        print("❌ Failed to create transaction: \(error.localizedDescription)")
                        self?.showErrorAlert(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func historyMerchantButtonTapped() {
        showMerchantSelectionAlert()
    }
    
    private func showMerchantSelectionAlert() {
        let alertController = UIAlertController(title: "Select Merchant", message: nil, preferredStyle: .actionSheet)
        
        // Add all merchant options
        for merchant in merchants {
            let action = UIAlertAction(title: merchant.name, style: .default) { [weak self] _ in
                self?.selectMerchant(merchant)
            }
            alertController.addAction(action)
        }
        
        // Add cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // For iPad, set popover source view
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = historyMerchantButton
            popover.sourceRect = historyMerchantButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func selectMerchant(_ merchant: Merchant) {
        selectedMerchant = merchant
        merchantTextField.text = merchant.name
        showMerchantTable(false)
    }
    
    // MARK: - Data Loading
    
    private func loadCategories() {
        DataManager.shared.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    self?.categoryCollectionView.reloadData()
                    
                    // If no categories, initialize default ones
                    if categories.isEmpty {
                        self?.initializeDefaultCategories()
                    }
                case .failure(let error):
                    self?.showErrorAlert("Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func initializeDefaultCategories() {
        DataManager.shared.initializeDefaultCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadCategories()
                case .failure(let error):
                    self?.showErrorAlert("Failed to initialize categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadMerchants() {
        DataManager.shared.fetchMerchants { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let merchants):
                    self?.merchants = merchants
                    // Ensure filteredMerchants is also updated when text is empty
                    if self?.merchantTextField.text?.isEmpty != false {
                        self?.filteredMerchants = merchants
                    }
                case .failure(let error):
                    print("Failed to load merchants: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateInput() -> Bool {
        guard let amountText = amountTextField.text,
              !amountText.isEmpty,
              let amount = Double(amountText),
              amount > 0 else {
            showErrorAlert("Please enter a valid amount")
            return false
        }
        
        guard selectedCategory != nil else {
            showErrorAlert("Please select a category")
            return false
        }
        
        return true
    }
    
    private func createTransaction() -> Transaction {
        let amount = Double(amountTextField.text ?? "0") ?? 0
        let merchantName = selectedMerchant?.merchantDisplayName ?? merchantTextField.text
        let merchantKey = selectedMerchant?.merchantKey
        let note = noteTextView.text == "Note (optional)" ? nil : noteTextView.text
        
        let transaction = Transaction(
            userId: Auth.auth().currentUser?.uid ?? "",
            amount: amount,
            type: selectedTransactionType,
            categoryId: selectedCategory?.id ?? "",
            categoryName: selectedCategory?.name ?? "",
            merchantName: merchantName?.isEmpty == false ? merchantName : nil,
            description: note,
            date: datePicker.date
        )
        
        return transaction
    }
    
    private func findExistingMerchant(name: String) -> Merchant? {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return merchants.first { merchant in
            let merchantName = merchant.merchantDisplayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return merchantName == normalizedName
        }
    }
        
    private func updateMerchantRecentTransactions(merchant: Merchant, transactionId: String, amount: Double, date: Date, categoryName: String) {
        guard let merchantId = merchant.id else {
            print("Merchant ID is nil; cannot update recent transaction list")
            return
        }
        
        // Get category ID and transaction type
        let categoryId = selectedCategory?.id ?? "default"
        let transactionType = selectedTransactionType
        
        DataManager.shared.updateMerchantRecentTransactions(
            merchantId: merchantId,
            transactionId: transactionId,
            amount: amount,
            date: date,
            categoryName: categoryName,
            categoryId: categoryId,
            type: transactionType
        ) { result in
            switch result {
            case .success:
                print("Merchant recent transaction list updated successfully")
            case .failure(let error):
                print("Failed to update merchant recent transaction list: \(error.localizedDescription)")
            }
        }
    }
    
    private func createNewMerchant(name: String, amount: Double, date: Date, transactionId: String, categoryName: String) {
        let merchantKey = name.lowercased().replacingOccurrences(of: " ", with: "")
        
        var note = MerchantNote()
        note.category = "Other"
        
        let merchant = Merchant(
            userId: Auth.auth().currentUser?.uid ?? "",
            merchantKey: merchantKey,
            merchantDisplayName: name,
            note: note
        )
        
        print("🏪 Start creating new merchant: \(name)")
        
        DataManager.shared.addMerchant(merchant) { [weak self] result in
            switch result {
            case .success(let merchantId):
                print("✅ New merchant created successfully, ID: \(merchantId)")
                // After creation, use the returned ID to update stats and recent transactions
                var merchantWithId = merchant
                merchantWithId.id = merchantId
                // Update merchant recent transactions
                self?.updateMerchantRecentTransactions(
                    merchant: merchantWithId,
                    transactionId: transactionId,
                    amount: amount,
                    date: date,
                    categoryName: categoryName
                )
                
                // Reload merchant list to include the new one
                self?.loadMerchants()
            case .failure(let error):
                print("❌ Failed to create new merchant: \(error.localizedDescription)")
            }
        }
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        saveButton.isEnabled = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
            saveButton.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            saveButton.setTitle("Save Transaction", for: .normal)
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Transaction has been saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Edit Mode Support
    
    private func populateEditData() {
        guard let transaction = transactionToEdit else { return }
        
        // Set transaction type
        selectedTransactionType = transaction.type
        typeSegmentedControl.selectedSegmentIndex = transaction.type == .expense ? 0 : 1
        
        // Set amount
        amountTextField.text = String(format: "%.2f", transaction.amount)
        
        // Set merchant name
        if let merchantName = transaction.merchantName {
            merchantTextField.text = merchantName
            // Try to find matching merchant
            selectedMerchant = merchants.first { $0.merchantDisplayName == merchantName }
        }
        
        // Set date
        datePicker.date = transaction.date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateTextField.text = formatter.string(from: transaction.date)
        
        // Set note
        if let description = transaction.description, !description.isEmpty {
            noteTextView.text = description
            noteTextView.textColor = UIColor.label
        }
        
        // Set category (needs to run after categories are loaded)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.selectCategoryForEdit(categoryId: transaction.categoryId)
        }
    }
    
    private func selectCategoryForEdit(categoryId: String) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            selectedCategory = categories[categoryIndex]
            categoryCollectionView.reloadData()
            
            // Scroll to selected category
            let indexPath = IndexPath(item: categoryIndex, section: 0)
            categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension AddTransactionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell.configure(with: category, isSelected: selectedCategory?.id == category.id)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 60)
    }
}

// MARK: - UITextViewDelegate

extension AddTransactionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Note (optional)" {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note (optional)"
            textView.textColor = UIColor.placeholderText
        }
    }
}

// MARK: - CategoryCollectionViewCell

class CategoryCollectionViewCell: UICollectionViewCell {
    
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 8
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        addSubview(iconLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.label
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with category: Category, isSelected: Bool) {
        iconLabel.text = category.icon
        nameLabel.text = category.name
        
        if isSelected {
            backgroundColor = UIColor.systemBlue
            nameLabel.textColor = UIColor.white
        } else {
            backgroundColor = UIColor.systemGray6
            nameLabel.textColor = UIColor.label
        }
    }
}

// MARK: - Merchant TextField Methods

extension AddTransactionViewController {
    
    @objc private func merchantTextFieldChanged() {
        let searchText = merchantTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if searchText.isEmpty {
            filteredMerchants = merchants
            hideMerchantTable()
        } else {
            filteredMerchants = merchants.filter { merchant in
                merchant.merchantDisplayName.localizedCaseInsensitiveContains(searchText)
            }
            showMerchantTable(true)
        }
        
        // Ensure UI updates are executed on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.merchantTableView.reloadData()
        }
    }
    
    @objc private func hideMerchantTable() {
        showMerchantTable(false)
    }
    
    private func showMerchantTable(_ show: Bool) {
        isMerchantTableVisible = show
        merchantTableViewHeightConstraint?.constant = show ? min(200, CGFloat(filteredMerchants.count * 44)) : 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate (Merchant selection)

extension AddTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == merchantTableView {
            return filteredMerchants.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == merchantTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCell", for: indexPath)
            
            // Add bounds check to avoid index out of range
            guard indexPath.row < filteredMerchants.count else {
                print("Warning: merchant table view index out of range - row: \(indexPath.row), count: \(filteredMerchants.count)")
                return cell
            }
            
            let merchant = filteredMerchants[indexPath.row]
            
            cell.textLabel?.text = merchant.merchantDisplayName
            cell.detailTextLabel?.text = merchant.note.category
            cell.imageView?.image = UIImage(systemName: "storefront")
            cell.imageView?.tintColor = UIColor.systemBlue
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == merchantTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // Add bounds check to avoid index out of range
            guard indexPath.row < filteredMerchants.count else {
                print("Warning: merchant table view selection index out of range - row: \(indexPath.row), count: \(filteredMerchants.count)")
                return
            }
            
            let merchant = filteredMerchants[indexPath.row]
            selectedMerchant = merchant
            merchantTextField.text = merchant.merchantDisplayName
            
            showMerchantTable(false)
            view.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITextFieldDelegate

extension AddTransactionViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == merchantTextField {
            filteredMerchants = merchants
            if !merchants.isEmpty {
                showMerchantTable(true)
                merchantTableView.reloadData()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == merchantTextField {
            // Delay hiding the table so the user can tap and select
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.isMerchantTableVisible {
                    self.showMerchantTable(false)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
