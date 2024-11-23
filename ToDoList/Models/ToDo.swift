import UIKit

enum ToDoServiceError: Error {
    case invalidUrlRequest
    case jsonDecoding
    case requestCancelled
}

struct TodoItem: Codable {
    let id: Int
    let todo: String
    var completed: Bool
    let userId: Int
    
    var uuid: UUID {
        UUID(uuidString: "\(id)") ?? UUID()
    }
}

struct TodoListResponse: Codable {
    let total: Int
    let skip: Int
    let limit: Int
    let todos: [TodoItem]
}

struct ToDo {
    let createdAt: Date
    let description: String
    let id: UUID
    var isCompleted: Bool
    let title: String
}

