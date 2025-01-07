import Foundation

struct PhotoData: Codable {
    var id: Int
    var pid: String
    var imagePath: String // 저장된 이미지의 경로
    var content: String      // 사진에 연결된 텍스트
    var categories: [String]  // 사진에 연결된 카테고리
}
