import UIKit
import ProgressHUD
import Speech


protocol ToDoViewControllerProtocol: AnyObject {
    var presenter: ToDoViewPresenterProtocol? { get set }
    func showPrograssHud(shown: Bool)
    func updateTable()
}

class ToDoViewController: UIViewController & ToDoViewControllerProtocol {
    
    var presenter: ToDoViewPresenterProtocol?
    
    // MARK: - Private Properties
    private let speechManager = SpeechRecognition()
    private var isSpeechRecognitionActive = false
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ToDoTableViewCell.self, forCellReuseIdentifier: ToDoTableViewCell.reuseIdentifier)
        tableView.rowHeight = 106
        tableView.separatorInset.right = 20
        tableView.separatorInset.left = 20
        tableView.separatorColor = .rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchBar.layer.cornerRadius = 20
        searchBar.clipsToBounds = true
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.searchTextField.backgroundColor = .rgbColors(red: 39, green: 39, blue: 41, alpha: 1)
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)]
        )
        if let searchIcon = searchBar.searchTextField.leftView as? UIImageView {
            searchIcon.tintColor = UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
        }
        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(systemName: "mic.slash.fill"), for: .bookmark, state: .normal)
        searchBar.tintColor = .gray
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .rgbColors(red: 39, green: 39, blue: 41, alpha: 1)
        return view
    }()
    
    private lazy var taskCountLabel: UILabel = {
        let taskCountLabel = UILabel()
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        taskCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("tasksCount", comment: ""), 0 )
        taskCountLabel.textColor = .white
        taskCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return taskCountLabel
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "AddTaskButton"), for: .normal)
        button.tintColor = .yellow
        button.addTarget(self,
                         action: #selector(createButtonTapped),
                         for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var remainedArea: UIView = {
        let remainedArea = UIView()
        remainedArea.translatesAutoresizingMaskIntoConstraints = false
        remainedArea.backgroundColor = .rgbColors(red: 39, green: 39, blue: 41, alpha: 1)
        return remainedArea
    }()
    
    // MARK: - Initialization
    init(presenter: ToDoViewPresenterProtocol? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter ?? ToDoViewPresenter(view: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        presenter?.loadTrackers() // Use the injected presenter
        addSubviews()
        makeConstraints()
        speechManager.delegate = self
        updateTable()
    }
    
    // MARK: - Public Methods
    func showPrograssHud(shown: Bool) {
        shown ? ProgressHUD.show() : ProgressHUD.dismiss()
    }
    
    
    // MARK: - Private methods
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        view.addSubview(remainedArea)
        bottomView.addSubview(taskCountLabel)
        bottomView.addSubview(createButton)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 56),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            bottomView.heightAnchor.constraint(equalToConstant: 49),
            
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            
            createButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 68),
            createButton.heightAnchor.constraint(equalToConstant: 44),
            createButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -10),
            
            remainedArea.topAnchor.constraint(equalTo: bottomView.bottomAnchor),
            remainedArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            remainedArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remainedArea.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    @objc private func createButtonTapped(){
        guard let presenter else { return }
        present(presenter.displayController(task: nil), animated: true, completion: nil)
    }
}

// MARK: - Extension UI Search Bar Delegate
extension ToDoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            presenter?.updateSearchText(for: "")
        }
        presenter?.updateSearchText(for: (searchBar.text ?? "").lowercased())
    }
    
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if isSpeechRecognitionActive {
            speechManager.stopRecognition()
        } else {
            speechManager.startRecognition()
        }
        isSpeechRecognitionActive.toggle()

        var micIcon = isSpeechRecognitionActive ? UIImage(systemName: "mic.fill") : UIImage(systemName: "mic.slash.fill")
        micIcon = micIcon?.withTintColor(isSpeechRecognitionActive ? .red : .gray)
        searchBar.setImage(micIcon, for: .bookmark, state: .normal)
        }
}

// MARK: - Extension SpeechRecognitionDelegate
extension ToDoViewController: SpeechRecognitionDelegate {
    func didRecognizeSpeech(text: String) {
        searchBar.text = text
        presenter?.updateSearchText(for: (searchBar.text ?? "").lowercased())
    }
    
    func didFailWithError(error: Error) {
        let alert = UIAlertController(title: "Speech Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Extension UITableViewDelegate & UITableViewDataSource
extension ToDoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleEditAction(indexPath: indexPath)
    }
}

extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.getToDoListCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.reuseIdentifier, for: indexPath) as? ToDoTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        let task = presenter?.getToDoListObject(at: indexPath)
        guard let task = task else { return UITableViewCell() }
        cell.configure(with: task, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
}

// MARK: - Extension ToDoTableViewCellProtocol
extension ToDoViewController: ToDoTableViewCellProtocol{
    func updateTracker(id: UUID, toDo: ToDo) {
        presenter?.updateTracker(toDoId: id, with: toDo)
    }
    
    func updateTable() {
        self.taskCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("tasksCount", comment: ""), presenter?.getToDoListCount() ?? 0)
        self.tableView.reloadData()
    }
    
    func handleEditAction(indexPath: IndexPath) {
        let selectedTask = presenter?.getToDoListObject(at: indexPath)
        guard let presenter else { return }
        present(presenter.displayController(task: selectedTask), animated: true, completion: nil)
    }
    
    func handleShareAction(indexPath: IndexPath) {
        let task = presenter?.getToDoListObject(at: indexPath)
        guard let task else { return }
        let shareContent = "Task: \(task.title)\nDescription: \(task.description)"
        let activityController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func handleDeleteAction(indexPath: IndexPath) {
        presenter?.deleteAction(at: indexPath)
    }
}
