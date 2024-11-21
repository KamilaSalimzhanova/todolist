import Foundation

final class NetworkClient {
    let session = URLSession.shared
    
    static let shared = NetworkClient()
    private init() {}
    
    func fetchTasks(completion: @escaping (Result<TodoListResponse, Error>) -> Void){
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("[Fetch tasks]: Error in URL request")
            completion(.failure(ToDoServiceError.invalidUrlRequest))
            return
        }
        var request = URLRequest(url: url)
        let task = session.objectTask(for: request)  { [weak self] (result: Result<TodoListResponse, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let toDoList):
                completion(.success(toDoList))
            case .failure(let failure):
                print("[fetchTasks]: Error fetching tasks - \(failure)")
                completion(.failure(ToDoServiceError.requestCancelled))
            }
        }
        task.resume()
    }
}
