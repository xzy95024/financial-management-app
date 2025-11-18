import UIKit

class CategoryManagementViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private var categories: [Category] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadCategories()
        
        // Listen for category update notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesUpdated),
            name: .categoriesUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Category Management"
        view.backgroundColor = UIColor.systemBackground
        
        // Add navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCategoryTapped)
        )
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryManagementCell.self, forCellReuseIdentifier: "CategoryManagementCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.systemBackground
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadCategories() {
        DataManager.shared.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories.sorted { $0.name < $1.name }
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showErrorAlert("Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let alertController = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Category Name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alertController.textFields?.first?.text,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self?.showErrorAlert("Please enter a category name")
                return
            }
            
            self?.addCategory(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func addCategory(name: String) {
        // Check if a category with the same name already exists
        if categories.contains(where: { $0.name == name }) {
            showErrorAlert("Category name already exists")
            return
        }
        
        // Create a new category with a random color and default icon
        let colors = ["#FF9800", "#2196F3", "#E91E63", "#9C27B0", "#F44336", "#3F51B5", "#795548", "#4CAF50", "#8BC34A", "#CDDC39", "#FFC107", "#00BCD4", "#FF5722", "#607D8B"]
        let icons = ["📦", "🏷️", "⭐", "🔖", "📌", "🎯", "💡", "🎨", "🔧", "⚡"]
        
        let randomColor = colors.randomElement() ?? "#607D8B"
        let randomIcon = icons.randomElement() ?? "📦"
        
        let newCategory = Category(
            name: name,
            icon: randomIcon,
            color: randomColor,
            isDefault: false
        )
        
        DataManager.shared.addCategory(newCategory) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showSuccessAlert("Category added successfully")
                case .failure(let error):
                    self?.showErrorAlert("Failed to add category: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        // Default categories cannot be deleted
        if category.isDefault {
            showErrorAlert("Default categories cannot be deleted")
            return
        }
        
        let alertController = UIAlertController(
            title: "Delete Category",
            message: "Are you sure you want to delete \"\(category.name)\"?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let categoryId = category.id else { return }
            
            DataManager.shared.deleteCategory(id: categoryId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showSuccessAlert("Category deleted successfully")
                    case .failure(let error):
                        self?.showErrorAlert("Failed to delete category: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func categoriesUpdated() {
        loadCategories()
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func showSuccessAlert(_ message: String) {
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryManagementCell", for: indexPath) as! CategoryManagementCell
        let category = categories[indexPath.row]
        cell.configure(with: category)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.row]
        
        // Default categories cannot be deleted
        if category.isDefault {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteCategory(at: indexPath)
            completion(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - CategoryManagementCell
class CategoryManagementCell: UITableViewCell {
    
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let typeLabel = UILabel()
    private let colorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Icon label
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor.label
        
        // Type label
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        typeLabel.textColor = UIColor.secondaryLabel
        
        // Color view
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Icon
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            // Name
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: colorView.leadingAnchor, constant: -12),
            
            // Type
            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typeLabel.trailingAnchor.constraint(lessThanOrEqualTo: colorView.leadingAnchor, constant: -12),
            
            // Color View
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 16),
            colorView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with category: Category) {
        iconLabel.text = category.icon
        nameLabel.text = category.name
        typeLabel.text = category.isDefault ? "Default Category" : "Custom Category"
        
        // Set color
        if let color = UIColor(hex: category.color) {
            colorView.backgroundColor = color
        } else {
            colorView.backgroundColor = UIColor.systemGray
        }
    }
}
