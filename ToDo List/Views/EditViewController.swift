import UIKit

protocol EditViewControllerProtocol: AnyObject {
    func editTracker(todo: ToDo)
    func createTracker(todo: ToDo)
}

final class EditViewController: UIViewController {
    
    weak var delegate: EditViewControllerProtocol?
    
    var task: ToDo? {
        didSet {
            updateView()
        }
    }
    
    private lazy var nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        let placeholderText = "Введите название"
        nameTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        nameTextField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        nameTextField.textColor = .white
        nameTextField.backgroundColor = .none
        nameTextField.addTarget(self,
                                action: #selector(inputText(_ :)),
                                for: .allEditingEvents)
        nameTextField.delegate = self
        return nameTextField
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
        dateLabel.text = Date().dateTimeString
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return dateLabel
    }()
    
    private lazy var descriptionLabel: UITextView = {
        let descriptionLabel = UITextView()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.isScrollEnabled = true
        descriptionLabel.text = "Введите описание"
        descriptionLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        return descriptionLabel
    }()
    
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        addNavigationController()
        addSubviews()
        makeConstraints()
        updateView()
    }
    
    
    private func addNavigationController(){
        navigationItem.title = ""
        let leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "BackButton"), for: .normal)
        leftButton.setTitle("Назад", for: .normal)
        leftButton.setTitleColor(.yellow, for: .normal)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        leftButton.sizeToFit()
        leftButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
    }
    
    private func addSubviews() {
        [nameTextField,
         dateLabel,
         descriptionLabel
        ].forEach { view.addSubview($0) }
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 41),
            
            dateLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateView() {
        guard isViewLoaded, let task = task else { return }
        nameTextField.text = task.title
        dateLabel.text = task.createdAt.dateTimeString
        descriptionLabel.text = task.description
    }
    
    @objc private func backButtonTapped() {
        if let updatedTitle = nameTextField.text,
           let updatedDescription = descriptionLabel.text,
           let task = task
        {
            
            if !updatedTitle.isEmpty && !updatedDescription.isEmpty {
                let updatedTask = ToDo(createdAt: Date(),
                                       description: updatedDescription,
                                       id: task.id,
                                       isCompleted: task.isCompleted,
                                       title: updatedTitle)
                
                print("updatedTask \(updatedTask)")
                delegate?.editTracker(todo: updatedTask)
            }
            dismiss(animated: true, completion: nil)
        } else {
            guard let title = nameTextField.text, let description = descriptionLabel.text else { return }
            if !title.isEmpty && description != "Введите описание" && !description.isEmpty {
                let createdTask = ToDo(createdAt: Date(),
                                       description: description,
                                       id: UUID(),
                                       isCompleted: false,
                                       title: title)
                
                delegate?.createTracker(todo: createdTask)
            }

            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func inputText(_ textField: UITextField) {}
}


extension EditViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            let attributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            textField.attributedPlaceholder = NSAttributedString(string: "Введите название", attributes: attributes)
        }
    }
}
