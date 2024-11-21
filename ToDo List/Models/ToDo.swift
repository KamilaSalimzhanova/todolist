import Foundation

enum ToDoServiceError: Error {
    case invalidUrlRequest
    case jsonDecoding
    case requestCancelled
}

struct TodoItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TodoListResponse: Codable {
    let total: Int
    let skip: Int
    let limit: Int
    let todos: [TodoItem]
}
