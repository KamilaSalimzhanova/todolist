import XCTest
@testable import ToDoList

final class ToDo_ListTests: XCTestCase {
    
    func testViewControllerRequestsTrackers() {
        // Given
        let presenterSpy = ToDoViewPresenterSpy()
        let viewController = ToDoViewController(presenter: presenterSpy)
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.loadTrackersCalled, "The presenter should load trackers when the view is loaded.")
    }
    
    func testPresenterFetchesToDoList() {
        // Given
        let presenter = ToDoViewPresenter(view: nil, toDoList: mockToDoList())
        
        // When
        let count = presenter.getToDoListCount()
        
        // Then
        XCTAssertEqual(count, 3, "The presenter should return the correct number of ToDos.")
    }
    
    func testViewControllerUpdatesTable() {
        let viewControllerSpy = ToDoViewControllerSpy()
        let presenter = ToDoViewPresenter(view: viewControllerSpy, toDoList: mockToDoList())
        viewControllerSpy.presenter = presenter
        
        // When
        presenter.updateSearchText(for: "")
        
        // Then
        XCTAssertTrue(viewControllerSpy.updateTableCalled, "The view controller should update the table when the presenter updates data.")
    }
}

final class ToDoViewPresenterSpy: ToDoViewPresenterProtocol {
    weak var view: ToDoViewControllerProtocol?
    var loadTrackersCalled = false
    var toDoList: [ToDo] = []
    
    
    func loadTrackers() {
        loadTrackersCalled = true
    }
    
    func getToDoListCount() -> Int { return toDoList.count }
    func getToDoListObject(at index: IndexPath) -> ToDo { return toDoList[index.row] }
    func updateSearchText(for text: String) {}
    func deleteAction(at: IndexPath) {}
    func displayController(task: ToDo?) -> UIViewController { return UIViewController() }
    func updateTracker(toDoId id: UUID, with toDo: ToDo) {}
}

final class ToDoViewControllerSpy: ToDoViewControllerProtocol {
    var presenter: ToDoViewPresenterProtocol?
    var showPrograssHudCalled = false
    var updateTableCalled = false
    
    func showPrograssHud(shown: Bool) {
        showPrograssHudCalled = shown
    }
    
    func updateTable() {
        updateTableCalled = true
    }
}

private func mockToDoList() -> [ToDo] {
    return [
        ToDo(createdAt: Date(), description: "Task 1", id: UUID(), isCompleted: false, title: "Task 1"),
        ToDo(createdAt: Date(), description: "Task 2", id: UUID(), isCompleted: false, title: "Task 2"),
        ToDo(createdAt: Date(), description: "Task 3", id: UUID(), isCompleted: false, title: "Task 3")
    ]
}
