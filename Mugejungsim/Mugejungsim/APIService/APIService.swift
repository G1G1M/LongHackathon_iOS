import Alamofire
import UIKit

struct APIResponse: Codable {
    let success: Bool
    let message: String? // 추가적으로 서버의 메시지를 포함할 수 있도록 설정
}

class APIService {
    static let shared = APIService()
    
    private let networkManager = NetworkManager.shared
    private init() {}
    
    // MARK: - 사용자별 게시물 조회
    func getUserPosts(userId: Int, completion: @escaping (Result<[TravelRecord], Error>) -> Void) {
            let endpoint = "/api/posts/user/\(userId)"
            networkManager.request( endpoint, method: .get, completion: completion)
    }
    

    func deletePost(postId: Int, userId: Int, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        let endpoint = "/api/posts/\(postId)?userId=\(userId)"
        
        NetworkManager.shared.requestRawResponse(endpoint, method: .delete) { result in
            switch result {
            case .success(let rawResponse):
                print("Raw Response: \(rawResponse)")
                if rawResponse.contains("success") {
                    let response = APIResponse(success: true, message: rawResponse)
                    completion(.success(response))
                } else {
                    let response = APIResponse(success: false, message: rawResponse)
                    completion(.success(response))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 다중 이미지 업로드
    func uploadImages(
            endpoint: String,
            images: [UIImage],
            metadata: [[String: Any]], // 각 이미지와 연결된 JSON 데이터
            completion: @escaping (Result<Any, Error>) -> Void
        ) {
            let url = URLService.shared.baseURL + endpoint
            let headers: HTTPHeaders = [
                "Content-Type": "multipart/form-data"
            ]

            AF.upload(
                multipartFormData: { multipartFormData in
                    // 이미지 파일 추가
                    for (index, image) in images.enumerated() {
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            multipartFormData.append(
                                imageData,
                                withName: "photos",
                                fileName: "image\(index + 1).jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                    }

                    // JSON 데이터 추가
                    if let jsonData = try? JSONSerialization.data(withJSONObject: metadata, options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        multipartFormData.append(
                            Data(jsonString.utf8),
                            withName: "data"
                        )
                    }
                },
                to: url,
                headers: headers
            )
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Upload successful: \(value)")
                    completion(.success(value))
                case .failure(let error):
                    print("Upload failed: \(error.localizedDescription)")
                    if let data = response.data {
                        print("Server Response: \(String(data: data, encoding: .utf8) ?? "No response body")")
                    }
                    completion(.failure(error))
                }
            }
        }
    
    // MARK: - 업로드된 이미지 조회
    func getUploadedImages(postId: Int, completion: @escaping (Result<[PhotoData], Error>) -> Void) {
        let endpoint = "/stories/\(postId)/stories" // 서버에서 이미지를 제공하는 엔드포인트
        networkManager.request(
            endpoint,
            method: .get,
            completion: { (result: Result<[PhotoData], Error>) in
                switch result {
                case .success(let photoData):
                    // 서버에서 받은 데이터 처리 (예: 이미지 URL, 카테고리 등)
                    completion(.success(photoData))
                case .failure(let error):
                    // 에러 처리
                    completion(.failure(error))
                }
            }
        )
    }
    
}

// MARK: - Codable 데이터 변환 헬퍼 메서드
extension Data {
    func toDictionary() -> [String: Any]? {
        try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
    }
}
