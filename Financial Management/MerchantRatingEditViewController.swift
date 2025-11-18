//
//  MerchantRatingEditViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit

protocol MerchantRatingEditDelegate: AnyObject {
    func didUpdateMerchantRating(_ merchant: Merchant)
}

class MerchantRatingEditViewController: UIViewController {
    
    // MARK: - Properties
    private var merchant: Merchant
    weak var delegate: MerchantRatingEditDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerLabel = UILabel()
    private let merchantNameLabel = UILabel()
    
    // Rating Section
    private let ratingContainerView = UIView()
    private let ratingTitleLabel = UILabel()
    private let ratingStackView = UIStackView()
    private var starButtons: [UIButton] = []
    private var currentRating: Int = 0
    
    // Verdict Section
    private let verdictContainerView = UIView()
    private let verdictTitleLabel = UILabel()
    private let verdictSegmentedControl = UISegmentedControl(items: ["Recommend", "Neutral", "Avoid"])
    
    // Notes Section
    private let notesContainerView = UIView()
    private let notesTitleLabel = UILabel()
    
    // Pros Section
    private let prosContainerView = UIView()
    private let prosTitleLabel = UILabel()
    private let prosTextView = UITextView()
    private let prosPlaceholderLabel = UILabel()
    
    // Cons Section
    private let consContainerView = UIView()
    private let consTitleLabel = UILabel()
    private let consTextView = UITextView()
    private let consPlaceholderLabel = UILabel()
    
    // Tips Section
    private let tipsContainerView = UIView()
    private let tipsTitleLabel = UILabel()
    private let tipsTextView = UITextView()
    private let tipsPlaceholderLabel = UILabel()
    
    // Raw Notes Section
    private let rawNotesContainerView = UIView()
    private let rawNotesTitleLabel = UILabel()
    private let rawNotesTextView = UITextView()
    private let rawNotesPlaceholderLabel = UILabel()
    
    // Category Section
    private let categoryContainerView = UIView()
    private let categoryTitleLabel = UILabel()
    private let categoryTextField = UITextField()
    
    // Save Button
    private let saveButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    init(merchant: Merchant) {
        self.merchant = merchant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "Edit Merchant Review"
        
        // Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupHeader()
        setupRatingSection()
        setupVerdictSection()
        setupNotesSection()
        setupSaveButton()
        setupConstraints()
    }
    
    private func setupHeader() {
        headerLabel.text = "Merchant Review"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textColor = UIColor.label
        headerLabel.textAlignment = .center
        
        merchantNameLabel.text = merchant.merchantDisplayName
        merchantNameLabel.font = UIFont.systemFont(ofSize: 18)
        merchantNameLabel.textColor = UIColor.secondaryLabel
        merchantNameLabel.textAlignment = .center
        merchantNameLabel.numberOfLines = 0
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(merchantNameLabel)
    }
    
    private func setupRatingSection() {
        ratingContainerView.backgroundColor = UIColor.systemBackground
        ratingContainerView.layer.cornerRadius = 12
        ratingContainerView.layer.shadowColor = UIColor.black.cgColor
        ratingContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        ratingContainerView.layer.shadowOpacity = 0.1
        ratingContainerView.layer.shadowRadius = 3
        
        ratingTitleLabel.text = "Rating"
        ratingTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        ratingTitleLabel.textColor = UIColor.label
        
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8
        ratingStackView.alignment = .center
        ratingStackView.distribution = .fillEqually
        
        // Create star buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("☆", for: .normal)
            starButton.setTitle("⭐", for: .selected)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starButtons.append(starButton)
            ratingStackView.addArrangedSubview(starButton)
        }
        
        ratingContainerView.addSubview(ratingTitleLabel)
        ratingContainerView.addSubview(ratingStackView)
        contentView.addSubview(ratingContainerView)
    }
    
    private func setupVerdictSection() {
        verdictContainerView.backgroundColor = UIColor.systemBackground
        verdictContainerView.layer.cornerRadius = 12
        verdictContainerView.layer.shadowColor = UIColor.black.cgColor
        verdictContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        verdictContainerView.layer.shadowOpacity = 0.1
        verdictContainerView.layer.shadowRadius = 3
        
        verdictTitleLabel.text = "Recommendation"
        verdictTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        verdictTitleLabel.textColor = UIColor.label
        
        // Default to Neutral
        verdictSegmentedControl.selectedSegmentIndex = 1
        
        verdictContainerView.addSubview(verdictTitleLabel)
        verdictContainerView.addSubview(verdictSegmentedControl)
        contentView.addSubview(verdictContainerView)
    }
    
    private func setupNotesSection() {
        setupTextViewContainer(
            container: prosContainerView,
            titleLabel: prosTitleLabel,
            title: "Pros",
            textView: prosTextView,
            placeholderLabel: prosPlaceholderLabel,
            placeholder: "What do you like about this merchant?"
        )
        
        setupTextViewContainer(
            container: consContainerView,
            titleLabel: consTitleLabel,
            title: "Cons",
            textView: consTextView,
            placeholderLabel: consPlaceholderLabel,
            placeholder: "What could be better?"
        )
        
        setupTextViewContainer(
            container: tipsContainerView,
            titleLabel: tipsTitleLabel,
            title: "Tips",
            textView: tipsTextView,
            placeholderLabel: tipsPlaceholderLabel,
            placeholder: "Any useful tips for future visits?"
        )
        
        setupTextViewContainer(
            container: rawNotesContainerView,
            titleLabel: rawNotesTitleLabel,
            title: "Detailed Review",
            textView: rawNotesTextView,
            placeholderLabel: rawNotesPlaceholderLabel,
            placeholder: "Write a more detailed review (optional)..."
        )
        
        // Category section
        categoryContainerView.backgroundColor = UIColor.systemBackground
        categoryContainerView.layer.cornerRadius = 12
        categoryContainerView.layer.shadowColor = UIColor.black.cgColor
        categoryContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        categoryContainerView.layer.shadowOpacity = 0.1
        categoryContainerView.layer.shadowRadius = 3
        
        categoryTitleLabel.text = "Merchant Category"
        categoryTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        categoryTitleLabel.textColor = UIColor.label
        
        categoryTextField.placeholder = "Add a category tag (optional)"
        categoryTextField.font = UIFont.systemFont(ofSize: 16)
        categoryTextField.borderStyle = .roundedRect
        categoryTextField.backgroundColor = UIColor.systemGray6
        
        categoryContainerView.addSubview(categoryTitleLabel)
        categoryContainerView.addSubview(categoryTextField)
        contentView.addSubview(categoryContainerView)
    }
    
    private func setupTextViewContainer(
        container: UIView,
        titleLabel: UILabel,
        title: String,
        textView: UITextView,
        placeholderLabel: UILabel,
        placeholder: String
    ) {
        container.backgroundColor = UIColor.systemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 1)
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 3
        
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.label
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.delegate = self
        
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.numberOfLines = 0
        
        container.addSubview(titleLabel)
        container.addSubview(textView)
        textView.addSubview(placeholderLabel)
        contentView.addSubview(container)
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        loadingIndicator.hidesWhenStopped = true
        
        contentView.addSubview(saveButton)
        saveButton.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        // Disable autoresizing mask
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingContainerView.translatesAutoresizingMaskIntoConstraints = false
        ratingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        verdictContainerView.translatesAutoresizingMaskIntoConstraints = false
        verdictTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        verdictSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prosContainerView.translatesAutoresizingMaskIntoConstraints = false
        prosTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        prosTextView.translatesAutoresizingMaskIntoConstraints = false
        prosPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        consContainerView.translatesAutoresizingMaskIntoConstraints = false
        consTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        consTextView.translatesAutoresizingMaskIntoConstraints = false
        consPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsContainerView.translatesAutoresizingMaskIntoConstraints = false
        tipsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsTextView.translatesAutoresizingMaskIntoConstraints = false
        tipsPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        rawNotesContainerView.translatesAutoresizingMaskIntoConstraints = false
        rawNotesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rawNotesTextView.translatesAutoresizingMaskIntoConstraints = false
        rawNotesPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            merchantNameLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            merchantNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            merchantNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Rating section
            ratingContainerView.topAnchor.constraint(equalTo: merchantNameLabel.bottomAnchor, constant: 20),
            ratingContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ratingContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: ratingContainerView.topAnchor, constant: 16),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            ratingTitleLabel.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -16),
            
            ratingStackView.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            ratingStackView.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -16),
            ratingStackView.bottomAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: -16),
            
            // Verdict section
            verdictContainerView.topAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: 16),
            verdictContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            verdictContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            verdictContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            verdictTitleLabel.topAnchor.constraint(equalTo: verdictContainerView.topAnchor, constant: 16),
            verdictTitleLabel.leadingAnchor.constraint(equalTo: verdictContainerView.leadingAnchor, constant: 16),
            verdictTitleLabel.trailingAnchor.constraint(equalTo: verdictContainerView.trailingAnchor, constant: -16),
            
            verdictSegmentedControl.topAnchor.constraint(equalTo: verdictTitleLabel.bottomAnchor, constant: 12),
            verdictSegmentedControl.leadingAnchor.constraint(equalTo: verdictContainerView.leadingAnchor, constant: 16),
            verdictSegmentedControl.trailingAnchor.constraint(equalTo: verdictContainerView.trailingAnchor, constant: -16),
            verdictSegmentedControl.bottomAnchor.constraint(equalTo: verdictContainerView.bottomAnchor, constant: -16),
        ])
        
        setupTextViewConstraints()
        setupCategoryConstraints()
        setupSaveButtonConstraints()
    }
    
    private func setupTextViewConstraints() {
        NSLayoutConstraint.activate([
            // Pros
            prosContainerView.topAnchor.constraint(equalTo: verdictContainerView.bottomAnchor, constant: 16),
            prosContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prosContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            prosContainerView.heightAnchor.constraint(equalToConstant: 140),
            
            prosTitleLabel.topAnchor.constraint(equalTo: prosContainerView.topAnchor, constant: 16),
            prosTitleLabel.leadingAnchor.constraint(equalTo: prosContainerView.leadingAnchor, constant: 16),
            prosTitleLabel.trailingAnchor.constraint(equalTo: prosContainerView.trailingAnchor, constant: -16),
            
            prosTextView.topAnchor.constraint(equalTo: prosTitleLabel.bottomAnchor, constant: 12),
            prosTextView.leadingAnchor.constraint(equalTo: prosContainerView.leadingAnchor, constant: 16),
            prosTextView.trailingAnchor.constraint(equalTo: prosContainerView.trailingAnchor, constant: -16),
            prosTextView.bottomAnchor.constraint(equalTo: prosContainerView.bottomAnchor, constant: -16),
            
            prosPlaceholderLabel.topAnchor.constraint(equalTo: prosTextView.topAnchor, constant: 8),
            prosPlaceholderLabel.leadingAnchor.constraint(equalTo: prosTextView.leadingAnchor, constant: 8),
            prosPlaceholderLabel.trailingAnchor.constraint(equalTo: prosTextView.trailingAnchor, constant: -8),
            
            // Cons
            consContainerView.topAnchor.constraint(equalTo: prosContainerView.bottomAnchor, constant: 16),
            consContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            consContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            consContainerView.heightAnchor.constraint(equalToConstant: 140),
            
            consTitleLabel.topAnchor.constraint(equalTo: consContainerView.topAnchor, constant: 16),
            consTitleLabel.leadingAnchor.constraint(equalTo: consContainerView.leadingAnchor, constant: 16),
            consTitleLabel.trailingAnchor.constraint(equalTo: consContainerView.trailingAnchor, constant: -16),
            
            consTextView.topAnchor.constraint(equalTo: consTitleLabel.bottomAnchor, constant: 12),
            consTextView.leadingAnchor.constraint(equalTo: consContainerView.leadingAnchor, constant: 16),
            consTextView.trailingAnchor.constraint(equalTo: consContainerView.trailingAnchor, constant: -16),
            consTextView.bottomAnchor.constraint(equalTo: consContainerView.bottomAnchor, constant: -16),
            
            consPlaceholderLabel.topAnchor.constraint(equalTo: consTextView.topAnchor, constant: 8),
            consPlaceholderLabel.leadingAnchor.constraint(equalTo: consTextView.leadingAnchor, constant: 8),
            consPlaceholderLabel.trailingAnchor.constraint(equalTo: consTextView.trailingAnchor, constant: -8),
            
            // Tips
            tipsContainerView.topAnchor.constraint(equalTo: consContainerView.bottomAnchor, constant: 16),
            tipsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tipsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tipsContainerView.heightAnchor.constraint(equalToConstant: 140),
            
            tipsTitleLabel.topAnchor.constraint(equalTo: tipsContainerView.topAnchor, constant: 16),
            tipsTitleLabel.leadingAnchor.constraint(equalTo: tipsContainerView.leadingAnchor, constant: 16),
            tipsTitleLabel.trailingAnchor.constraint(equalTo: tipsContainerView.trailingAnchor, constant: -16),
            
            tipsTextView.topAnchor.constraint(equalTo: tipsTitleLabel.bottomAnchor, constant: 12),
            tipsTextView.leadingAnchor.constraint(equalTo: tipsContainerView.leadingAnchor, constant: 16),
            tipsTextView.trailingAnchor.constraint(equalTo: tipsContainerView.trailingAnchor, constant: -16),
            tipsTextView.bottomAnchor.constraint(equalTo: tipsContainerView.bottomAnchor, constant: -16),
            
            tipsPlaceholderLabel.topAnchor.constraint(equalTo: tipsTextView.topAnchor, constant: 8),
            tipsPlaceholderLabel.leadingAnchor.constraint(equalTo: tipsTextView.leadingAnchor, constant: 8),
            tipsPlaceholderLabel.trailingAnchor.constraint(equalTo: tipsTextView.trailingAnchor, constant: -8),
            
            // Detailed review
            rawNotesContainerView.topAnchor.constraint(equalTo: tipsContainerView.bottomAnchor, constant: 16),
            rawNotesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rawNotesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rawNotesContainerView.heightAnchor.constraint(equalToConstant: 140),
            
            rawNotesTitleLabel.topAnchor.constraint(equalTo: rawNotesContainerView.topAnchor, constant: 16),
            rawNotesTitleLabel.leadingAnchor.constraint(equalTo: rawNotesContainerView.leadingAnchor, constant: 16),
            rawNotesTitleLabel.trailingAnchor.constraint(equalTo: rawNotesContainerView.trailingAnchor, constant: -16),
            
            rawNotesTextView.topAnchor.constraint(equalTo: rawNotesTitleLabel.bottomAnchor, constant: 12),
            rawNotesTextView.leadingAnchor.constraint(equalTo: rawNotesContainerView.leadingAnchor, constant: 16),
            rawNotesTextView.trailingAnchor.constraint(equalTo: rawNotesContainerView.trailingAnchor, constant: -16),
            rawNotesTextView.bottomAnchor.constraint(equalTo: rawNotesContainerView.bottomAnchor, constant: -16),
            
            rawNotesPlaceholderLabel.topAnchor.constraint(equalTo: rawNotesTextView.topAnchor, constant: 8),
            rawNotesPlaceholderLabel.leadingAnchor.constraint(equalTo: rawNotesTextView.leadingAnchor, constant: 8),
            rawNotesPlaceholderLabel.trailingAnchor.constraint(equalTo: rawNotesTextView.trailingAnchor, constant: -8),
        ])
    }
    
    private func setupCategoryConstraints() {
        NSLayoutConstraint.activate([
            categoryContainerView.topAnchor.constraint(equalTo: rawNotesContainerView.bottomAnchor, constant: 16),
            categoryContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 16),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            
            categoryTextField.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 12),
            categoryTextField.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            categoryTextField.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupSaveButtonConstraints() {
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Data Population
    private func populateData() {
        // Rating
        currentRating = merchant.note.rating ?? 0
        updateStarButtons()
        
        // Verdict
        if let verdict = merchant.note.verdict {
            switch verdict {
            case .recommended:
                verdictSegmentedControl.selectedSegmentIndex = 0
            case .neutral:
                verdictSegmentedControl.selectedSegmentIndex = 1
            case .avoid:
                verdictSegmentedControl.selectedSegmentIndex = 2
            }
        }
        
        // Text content
        prosTextView.text = merchant.note.pros.joined(separator: "\n")
        consTextView.text = merchant.note.cons.joined(separator: "\n")
        tipsTextView.text = merchant.note.tips.joined(separator: "\n")
        rawNotesTextView.text = merchant.note.raw ?? ""
        categoryTextField.text = merchant.note.category ?? ""
        
        updatePlaceholderVisibility()
    }
    
    private func updateStarButtons() {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = (index + 1) <= currentRating
        }
    }
    
    private func updatePlaceholderVisibility() {
        prosPlaceholderLabel.isHidden = !prosTextView.text.isEmpty
        consPlaceholderLabel.isHidden = !consTextView.text.isEmpty
        tipsPlaceholderLabel.isHidden = !tipsTextView.text.isEmpty
        rawNotesPlaceholderLabel.isHidden = !rawNotesTextView.text.isEmpty
    }
    
    // MARK: - Actions
    @objc private func starButtonTapped(_ sender: UIButton) {
        currentRating = sender.tag
        updateStarButtons()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        saveButton.isEnabled = false
        loadingIndicator.startAnimating()
        
        var updatedNote = merchant.note
        updatedNote.rating = currentRating > 0 ? currentRating : nil
        
        // Verdict
        switch verdictSegmentedControl.selectedSegmentIndex {
        case 0:
            updatedNote.verdict = .recommended
        case 1:
            updatedNote.verdict = .neutral
        case 2:
            updatedNote.verdict = .avoid
        default:
            updatedNote.verdict = nil
        }
        
        // Text content
        updatedNote.pros = prosTextView.text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        updatedNote.cons = consTextView.text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        updatedNote.tips = tipsTextView.text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        updatedNote.raw = rawNotesTextView.text.isEmpty ? nil : rawNotesTextView.text
        updatedNote.category = (categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? categoryTextField.text
            : nil
        
        merchant.note = updatedNote
        merchant.updatedAt = Date()
        
        DataManager.shared.updateMerchant(merchant) { [weak self] result in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self?.delegate?.didUpdateMerchantRating(
                        self?.merchant ?? Merchant(userId: "", merchantKey: "", merchantDisplayName: "")
                    )
                    self?.showSuccessAlert()
                case .failure(let error):
                    self?.showErrorAlert("Failed to save review: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Saved",
            message: "Your review has been updated.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension MerchantRatingEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}
