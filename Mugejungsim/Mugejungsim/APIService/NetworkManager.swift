import Alamofire
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = URLService.shared.baseURL
    
    private init() {}
    
    // MARK: - 일반 네트워크 요청 메서드
    func request<T: Codable>(
        _ endpoint: String,
        method: HTTPMethod,
        parameters: [String: String]? = nil,
        body: Codable? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let url = baseURL + endpoint
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let encoding: ParameterEncoding = (method == .get || method == .delete) ? URLEncoding.default : JSONEncoding.default
        var bodyParameters: [String: Any]? = nil
                
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let data = try encoder.encode(body)
                bodyParameters = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            } catch {
                print("Encoding Error: \(error)")
                completion(.failure(error))
                return
            }
        }
        
        // Print request details
        print("=== Request ===")
        print("URL: \(url)")
        print("Method: \(method.rawValue)")
        print("Headers: \(headers)")
        print("Parameters: \(parameters ?? [:])")
        if let bodyParameters = bodyParameters {
            print("Body: \(bodyParameters)")
        }
        print("===============")
        
        AF.request(
            url,
            method: method,
            parameters: bodyParameters ?? parameters,
            encoding: encoding,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            // Print response details
            print("=== Response ===")
            print("URL: \(response.request?.url?.absoluteString ?? "No URL")")
            print("Status Code: \(response.response?.statusCode ?? 0)")
            if let data = response.data {
                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
            }
            switch response.result {
            case .success(let result):
                print("Decoded Response: \(result)")
                completion(.success(result))
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            print("================")
        }
    }
    
    // MARK: - 단순 문자열/데이터 요청 메서드
        func requestRawResponse(
            _ endpoint: String,
            method: HTTPMethod,
            parameters: [String: String]? = nil,
            body: Codable? = nil,
            completion: @escaping (Result<String, Error>) -> Void
        ) {
            let url = baseURL + endpoint
            let headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            
            let encoding: ParameterEncoding = (method == .get || method == .delete) ? URLEncoding.default : JSONEncoding.default
            var bodyParameters: [String: Any]? = nil
            
            if let body = body {
                do {
                    let encoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .convertToSnakeCase
                    let data = try encoder.encode(body)
                    bodyParameters = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                } catch {
                    print("Encoding Error: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            
            AF.request(
                url,
                method: method,
                parameters: bodyParameters ?? parameters,
                encoding: encoding,
                headers: headers
            )
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let rawString = String(data: data, encoding: .utf8) {
                        completion(.success(rawString))
                    } else {
                        completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode response."])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func resizeImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        let size = image.size
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let scaleRatio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
