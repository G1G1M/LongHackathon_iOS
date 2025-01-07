import Foundation
import UIKit

class DataManager {
    static let shared = DataManager()
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let dataFile: URL
    private let travelDataFile: URL
    private var photoDataList: [PhotoData] = []

    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        dataFile = documentsDirectory.appendingPathComponent("photoData.json")
        travelDataFile = documentsDirectory.appendingPathComponent("travelRecords.json")
    }

    // MARK: - Swagger API 호출
    func uploadPhotoData(_ photoData: [[String: Any]], completion: @escaping (Result<String, Error>) -> Void) {
        // API URL 설정 (실제 엔드포인트로 변경 필요)
        
        guard let url = URL(string: "https://mugejunsim.store") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        // URLRequest 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JSON 데이터 변환
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: photoData, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        // URLSession을 사용한 네트워크 요청
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                return
            }

            completion(.success(responseString))
        }
        task.resume()
    }

    // MARK: - 데이터 저장
    func saveData(photoData: [PhotoData]) {
        if let jsonData = try? JSONEncoder().encode(photoData) {
            try? jsonData.write(to: dataFile)
        }
    }

    // MARK: - 데이터 불러오기
    func loadData() -> [PhotoData] {
        guard let jsonData = try? Data(contentsOf: dataFile),
              let photoData = try? JSONDecoder().decode([PhotoData].self, from: jsonData) else {
            return []
        }
        return photoData
    }

    // MARK: - 이미지 저장
    func saveImage(_ image: UIImage) -> String? {
        let imageName = "image_\(UUID().uuidString).jpg"
        let imagePath = documentsDirectory.appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
            return imageName
        }
        return nil
    }

    // MARK: - 이미지 불러오기
    func loadImage(from imageName: String) -> UIImage? {
        let imagePath = documentsDirectory.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: imagePath.path)
    }

    func addNewData(photoData: [PhotoData]) {
        var existingData = loadData() // 기존 데이터를 불러옴
        existingData.append(contentsOf: photoData) // 새 데이터를 추가
        if let jsonData = try? JSONEncoder().encode(existingData) {
            try? jsonData.write(to: dataFile)
        }
    }

    // MARK: - TravelRecord 저장
    func saveTravelRecords(_ records: [TravelRecord]) {
        if let jsonData = try? JSONEncoder().encode(records) {
            try? jsonData.write(to: travelDataFile)
        }
    }

    // MARK: - TravelRecord 불러오기
    func loadTravelRecords() -> [TravelRecord] {
        guard let jsonData = try? Data(contentsOf: travelDataFile),
              let records = try? JSONDecoder().decode([TravelRecord].self, from: jsonData) else {
            return []
        }
        return records
    }
}
