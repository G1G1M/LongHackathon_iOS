import Foundation
import Alamofire

struct StoryEditor: Codable {
    var pid: Int
    var content: String
    var categories: [String]
    var imagePath: String
    var orderIndex: Int
    
    init(pid: Int, content: String, categories: [String], imagePath: String, orderIndex: Int) {
        self.pid = pid
        self.content = content
        self.categories = categories
        self.imagePath = imagePath
        self.orderIndex = orderIndex
    }
}

class StoryManager {
    static let shared = StoryManager()
    private var stories: [StoryEditor] = [] // JSON 형식으로 저장될 데이터

    private init() {}

    // MARK: - 스토리 추가
    func addStory(pid: Int, content: String, categories: [String], imagePath: String, orderIndex: Int) {
        let story = StoryEditor(pid: pid, content: content, categories: categories, imagePath: imagePath, orderIndex: orderIndex)
        stories.append(story)
    }

    // MARK: - 서버로 스토리 데이터 전송
    func uploadStories(to url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !stories.isEmpty else {
            completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "스토리 데이터가 없습니다."])))
            return
        }
        // 서버 요구 사항에 맞는 JSON 데이터 생성
        let payload: [String: Any] = [
            "data": [
                "photos": stories.map { story in
                    [
                        "pid": story.pid,
                        "content": story.content,
                        "categories": story.categories,
                        "orderIndex": story.orderIndex,
                        "imagePath": story.imagePath
                    ]
                }
            ]
        ]

        // JSON 디버깅용 출력
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON Payload:\n\(jsonString)")
        }

        // Alamofire 요청
        AF.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default,
            headers: ["Content-Type": "application/json"]
        )
        .validate()
        .response { response in
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(NSError(domain: "NoResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "서버로부터 응답을 받을 수 없습니다."])))
                return
            }

            switch response.result {
            case .success:
                if statusCode == 200 || statusCode == 201 {
                    completion(.success("스토리 데이터가 성공적으로 업로드되었습니다. 상태 코드: \(statusCode)"))
                } else {
                    let errorMessage = "서버 응답 오류. 상태 코드: \(statusCode)"
                    completion(.failure(NSError(domain: "ServerError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 스토리 초기화
    func clearStories() {
        stories.removeAll()
    }
}
