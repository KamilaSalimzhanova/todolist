import UIKit
import CoreData

final class ToDoStore: NSObject {
    // MARK: - Delegate
    weak var delegate: ToDoViewController?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var searchText: String
    
    private lazy var fetchResultController: NSFetchedResultsController<ToDoCoreData> = {
        let searchText = (self.searchText).lowercased()
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        if !searchText.isEmpty{
            fetchResultController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(ToDoCoreData.title), searchText)
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(ToDoCoreData.createdAt), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchResultedController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchResultedController.delegate = self
        return fetchResultedController
    }()
    
    // MARK: - Initializers
    convenience init(delegate: ToDoViewController, searchText: String){
        let context = DataStore.shared.getContext()
        self.init(context: context, delegate: delegate, searchText: searchText)
    }
    
    init(context: NSManagedObjectContext, delegate: ToDoViewController, searchText: String) {
        self.context = context
        self.delegate = delegate
        self.searchText = searchText
    }
    
    // MARK: - Public Methods
    func fetchAllTasks() -> [ToDoCoreData] {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchTrackerCoreData() -> [ToDoCoreData] {
        let fetchRequest = NSFetchRequest<ToDoCoreData>(entityName: "ToDoCoreData")
        do{
            let toDoCoreData = try context.fetch(fetchRequest)
            return toDoCoreData
        } catch let error as NSError {
            print("Could not fetch records. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func addNewTracker(_ toDoItem: ToDo) -> ToDoCoreData? {
        let toDoCoreData = ToDoCoreData(context: context)
        updateExistingToDo(toDoCoreData, with: toDoItem)
        saveContext()
        return toDoCoreData
    }
    
    func editToDo(with toDo: ToDo) {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", toDo.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let toDoCoreData = results.first {
                updateExistingToDo(toDoCoreData, with: toDo)
                try context.save()
                print("Successfully updated ToDo with ID: \(toDo.id)")
            } else {
                print("No ToDo found with ID: \(toDo.id)")
            }
        } catch let error as NSError {
            print("Failed to edit ToDo. \(error), \(error.userInfo)")
        }
    }

    func deleteTracker(toDoId: UUID) {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        do {
            let toDoCoreData = try context.fetch(fetchRequest)
            if let index = toDoCoreData.firstIndex(where: {$0.id == toDoId}) {
                context.delete(toDoCoreData[index])
                try context.save()
            }
        }  catch {
            print("Failed to fetch or save tracker: \(error.localizedDescription)")
        }
    }
    
    func deleteAllTrackersIteratively() {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Failed to delete all items. \(error), \(error.userInfo)")
        }
    }

    func updateTracker(toDoId: UUID, with updatedToDo: ToDo) {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", toDoId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let toDoCoreData = results.first {
                updateExistingToDo(toDoCoreData, with: updatedToDo)
                try context.save()
                let remainingItems = try context.fetch(fetchRequest)
                printList()
            } else {
                print("No ToDo found with ID: \(toDoId)")
            }
        } catch let error as NSError {
            print("Failed to update ToDo. \(error), \(error.userInfo)")
        }
    }

    func updateSearchText(for searchedText: String) {
        if searchedText != "" {
            fetchResultController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(ToDoCoreData.title), searchedText)
        } else {
            fetchResultController.fetchRequest.predicate = nil
        }
        try? fetchResultController.performFetch()
    }
    
    func isCoreDataEmpty() -> Bool {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        fetchRequest.resultType = .countResultType
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Error checking Core Data: \(error.localizedDescription)")
            return true
        }
    }
    
    func getCount() -> Int {
        try? fetchResultController.performFetch()
        return fetchResultController.fetchedObjects?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        do {
            try fetchResultController.performFetch()
            print(fetchResultController.fetchedObjects ?? [])
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
        return fetchResultController.fetchedObjects?.count ?? 0
    }
    
    
    func object(at indexPath: IndexPath) -> ToDo {
        let toDoCoreData = fetchResultController.object(at: indexPath)
        let toDo = ToDo(createdAt: toDoCoreData.createdAt ?? Date(), description: toDoCoreData.descript ?? "", id: toDoCoreData.id ?? UUID(), isCompleted: toDoCoreData.isCompleted, title: toDoCoreData.title ?? "")
        return toDo
    }
    
    // MARK: - Private Methods
    private func printList() {
        let fetchRequest: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        
        do {
            let todos = try context.fetch(fetchRequest)
            
            if todos.isEmpty {
                print("No todos found in Core Data.")
            } else {
                print("Todos in Core Data:")
                for todo in todos {
                    print("Todo ID: \(String(describing: todo.id))")
                    print("Title: \(todo.title ?? "No Title")")
                    print("Description: \(todo.descript ?? "No description")")
                    print("CreatedAt: \(String(describing: todo.createdAt))")
                    print("IsCompleted: \(todo.isCompleted)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch trackers. \(error), \(error.userInfo)")
        }
    }
    
    private func updateExistingToDo(_ toDoCoreData: ToDoCoreData, with toDoItem: ToDo) {
        toDoCoreData.id = toDoItem.id
        toDoCoreData.createdAt = toDoItem.createdAt
        toDoCoreData.descript = toDoItem.description
        toDoCoreData.isCompleted = toDoItem.isCompleted
        toDoCoreData.title = toDoItem.title 
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Ошибка сохранения")
        }
    }
}

extension ToDoStore: NSFetchedResultsControllerDelegate {}
