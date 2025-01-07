//
//  TravelRecordManager.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/28/24.
//

import Alamofire
import UIKit


struct TravelRecord: Codable {
    var id: Int                 // 기록물 id
    var pid: String
    var title: String           // 기록물 제목 : 여행 제목
    var startDate: String       // 여행 시작 날짜
    var endDate: String         // 여행 종료 날짜
    var location: String        // 여행지
    var companion : String      // 동행자
    var bottle : String         // 유리병
    var stories: [PhotoData]    // `PhotoData` 사용
    var oneLine1: String?        // local
    var oneLine2: String?        // local

    init(id: Int, pid: String, title: String, startDate: String, endDate: String, location: String, companion: String, bottle: String, stories: [PhotoData] = [], oneLine1: String, oneLine2: String) {
        self.id = id
        self.pid = pid
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.companion = companion
        self.bottle = bottle
        self.stories = stories
        self.oneLine1 = oneLine1
        self.oneLine2 = oneLine2
    }
}

class TravelRecordManager {
    static let shared = TravelRecordManager()
    var travelRecords: [TravelRecord] = []
    var userId: Int?
    var postId: Int?
    var temporaryOneline: String?
    var TemporaryCount: Int?
    
    private init() {
        travelRecords = DataManager.shared.loadTravelRecords()
    }

    // MARK: - 데이터 저장
    private func saveData() {
        DataManager.shared.saveTravelRecords(travelRecords)
    }

    // MARK: - 모든 기록 가져오기
    func getAllRecords() -> [TravelRecord] {
        return travelRecords
    }

    // MARK: - 기록 추가
    func addRecord(_ record: TravelRecord) {
        travelRecords.append(record)
        saveData()
    }

    // MARK: - 사진 추가
    func addPhoto(to recordID: Int, image: UIImage, text: String, categories: String) -> Bool {
        guard var record = getRecord(by: recordID) else { return false }

        // 사진 수 제한 체크
        if record.stories.count >= 25 {
            print("사진 추가 실패: 최대 25개 제한")
            return false
        }

        // `DataManager`를 사용하여 이미지 저장
        if let imageName = DataManager.shared.saveImage(image) {
            let newPhoto = PhotoData(id: 0, pid: "", imagePath: imageName, content: text, categories: [categories])
            record.stories.append(newPhoto)
            // 업데이트된 기록 저장
            updateRecord(record)
            return true
        }
        return false
    }

    // MARK: - 사진 삭제
    func deletePhoto(from recordID: Int, at index: Int) -> Bool {
        guard var record = getRecord(by: recordID), index < record.stories.count else { return false }

        // `DataManager`를 사용하여 이미지 삭제
        let photoToDelete = record.stories[index]
//        DataManager.shared.deleteData(photoData: photoToDelete)
        // 사진 목록 업데이트
        record.stories.remove(at: index)
        updateRecord(record)
        return true
    }

    // MARK: - 기록 업데이트
    func updateRecord(_ updatedRecord: TravelRecord) {
        if let index = travelRecords.firstIndex(where: { $0.id == updatedRecord.id }) {
            travelRecords[index] = updatedRecord
            saveData()
        }
    }

    // MARK: - 특정 기록 불러오기
    func getRecord(by id: Int) -> TravelRecord? {
        return travelRecords.first { $0.id == id }
    }
    
}

extension TravelRecordManager {
    // 서버로 기록 전송
    func sendRecordToServer(_ record: TravelRecord, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "userId가 설정되지 않았습니다."])))
            print("Error: userId가 설정되지 않았습니다.")
            return
        }
        let serverURL = "\(URLService.shared.baseURL)/api/posts?userId=\(userId)"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let parameters: [String: Any] = [
            "pid": record.id,
            "userId": userId,
            "title": record.title,
            "startDate": record.startDate,
            "endDate": record.endDate,
            "location": record.location,
            "companion": record.companion,
            "bottle": record.bottle
        ]

        AF.request(
            serverURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    print("Server Response JSON: \(json)")
                    completion(.success(json))
                } else {
                    print("Invalid response format: \(value)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            case .failure(let error):
                print("Error sending record to server: \(error.localizedDescription)")
                if let data = response.data {
                    print("Server Error Response: \(String(data: data, encoding: .utf8) ?? "No Data")")
                }
                completion(.failure(error))
            }
        }
    }
    
    func updateRecordOnServer(postId: Int, record: TravelRecord, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "userId가 설정되지 않았습니다."])))
            print("Error: userId가 설정되지 않았습니다.")
            return
        }
        
        print("===== Update Record Debugging =====")
        print("Post ID: \(postId)")
        print("Record ID: \(record.id)")
        print("User ID: \(userId)")
        print("Title: \(record.title)")
        print("Start Date: \(record.startDate)")
        print("End Date: \(record.endDate)")
        print("Location: \(record.location)")
        print("Companion: \(record.companion)")
        print("Bottle: \(record.bottle)")
        print("Stories Count: \(record.stories.count)")
        record.stories.enumerated().forEach { index, story in
                print("Story \(index + 1): \(story)")
        }
        print("One Line 1: \(record.oneLine1 ?? "nil")")
        print("One Line 2: \(record.oneLine2 ?? "nil")")
        print("===================================")
        
        let serverURL = "\(URLService.shared.baseURL)/api/posts/\(postId)/finalize"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        // `stories`를 JSON 배열로 변환
        let storiesData = record.stories.map { story in
            return [
                "pid": story.pid,
                "imagePath": story.imagePath,
                "content": story.content,
                "categories": story.categories
            ]
        }
          
        
        let parameters: [String: Any] = [
            "pid": record.id,
            "userId": userId,
            "title": record.title,
            "startDate": record.startDate,
            "endDate": record.endDate,
            "location": record.location,
            "companion": record.companion,
            "bottle": record.bottle,
            "stories": storiesData
        ]

        AF.request(
            serverURL,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    print("Server Response JSON: \(json)")
                    completion(.success(json))
                } else {
                    print("Invalid response format: \(value)")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            case .failure(let error):
                print("Error updating record on server: \(error.localizedDescription)")
                if let data = response.data {
                    print("Server Error Response: \(String(data: data, encoding: .utf8) ?? "No Data")")
                }
                completion(.failure(error))
            }
        }
    }
}
