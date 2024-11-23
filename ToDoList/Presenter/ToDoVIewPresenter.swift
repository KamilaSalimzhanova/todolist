import UIKit

protocol ToDoViewPresenterProtocol: AnyObject {
    var view: ToDoViewControllerProtocol? { get set }
    func loadTrackers()
    func getToDoListCount() -> Int
    func getToDoListObject(at index: IndexPath) -> ToDo
    func updateSearchText(for text: String)
    func deleteAction(at: IndexPath)
    func displayController(task: ToDo?) -> UIViewController
    func updateTracker(toDoId id: UUID, with toDo: ToDo)
}

final class ToDoViewPresenter: ToDoViewPresenterProtocol {
    
    //MARK: - Delegate
    weak var view: ToDoViewControllerProtocol?
    
    //MARK: - Private properties
    private var toDoList: [ToDo]
    private var toDoStore: ToDoStore
    private var networkClient: NetworkClient = NetworkClient.shared
    private let editViewController = EditViewController()
    
    private var searchText: String = ""
    
    // MARK: - Initialization
    init(view: ToDoViewControllerProtocol? = nil, toDoList: [ToDo] = [], toDoStore: ToDoStore = ToDoStore(searchText: "")) {
        self.view = view
        self.toDoStore = toDoStore
        if toDoList.isEmpty {
            self.toDoList = toDoStore.fetchAllTasks()
        } else {
            self.toDoList = toDoList
        }
        toDoStore.delegate = self
        editViewController.delegate = self
    }
    
    //MARK: - Public properties
    func loadTrackers() {
        print("isCoreDataEmpty: \(toDoStore.isCoreDataEmpty())")
        print("todolist: \(toDoList)")
        if toDoStore.isCoreDataEmpty() {
            view?.showPrograssHud(shown: true)
            networkClient.fetchTasks { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.view?.showPrograssHud(shown: false)
                    switch result {
                    case .success(let response):
                        response.todos.forEach {self.toDoStore.addNewTracker(ToDo(createdAt: Date(), description: $0.todo, id: UUID(uuidString: "\($0.id)") ?? UUID(), isCompleted: $0.completed, title: $0.todo))}
                        self.toDoList = response.todos.map({ToDo(createdAt: Date(), description: $0.todo, id: UUID(uuidString: "\($0.id)") ?? UUID(), isCompleted: $0.completed, title: $0.todo)})
                        self.view?.updateTable()
                    case .failure(let error):
                        print("Error fetching tasks: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func getToDoListCount() -> Int {
        print("todo: \(self.toDoList)")
        return toDoList.count
    }
    
    func getToDoListObject(at index: IndexPath) -> ToDo {
        toDoList[index.row]
    }
    
    func updateSearchText(for text: String) {
        searchText = text
        toDoStore.updateSearchText(for: text)
        toDoList = toDoStore.fetchAllTasks()
        view?.updateTable()
    }
    
    func deleteAction(at: IndexPath) {
        let task = getToDoListObject(at: at)
        toDoStore.deleteTracker(toDoId: task.id)
        updateSearchText(for: searchText)
    }
    
    func displayController(task: ToDo? = nil) -> UIViewController {
        editViewController.task = task
        let navigationController = UINavigationController(rootViewController: editViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        return navigationController
        
    }
    
    func updateTracker(toDoId id: UUID, with toDo: ToDo) {
        toDoStore.updateTracker(toDoId: id, with: toDo)
        updateSearchText(for: searchText)
    }
}

// MARK: - Extension EditViewControllerProtocol
extension ToDoViewPresenter: EditViewControllerProtocol {
    func editTracker(todo: ToDo) {
        toDoStore.editToDo(with: todo)
        updateSearchText(for: searchText)
    }
    
    func createTracker(todo: ToDo) {
        toDoStore.addNewTracker(todo)
        updateSearchText(for: searchText)
    }
}
