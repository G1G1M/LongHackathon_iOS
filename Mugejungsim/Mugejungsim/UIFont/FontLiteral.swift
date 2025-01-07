//
//  FontLiteral.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/23/24.
//

import UIKit

// Pretendard 폰트 이름을 관리하는 열거형
enum FontName: String {
    case pretendardBlack = "Pretendard-Black"
    case pretendardBold = "Pretendard-Bold"
    case pretendardExtraBold = "Pretendard-ExtraBold"
    case pretendardExtraLight = "Pretendard-ExtraLight"
    case pretendardLight = "Pretendard-Light"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardThin = "Pretendard-Thin"
}

extension UIFont {
    
    // 지정된 커스텀 폰트 스타일과 크기로 UIFont를 반환합니다.
    // - Parameters:
    //   - style: FontName 열거형에 정의된 커스텀 폰트 스타일
    //   - size: 폰트 크기
    // - Returns: 지정된 스타일과 크기로 생성된 UIFont, 실패 시 시스템 기본 폰트를 반환
    static func font(_ style: FontName, ofSize size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
    
    // MARK: - 자주 사용하는 스타일 정의

    // Pretendard-SemiBold 18
    @nonobjc class var h1: UIFont {
        return UIFont.font(.pretendardSemiBold, ofSize: 18)
    }
    
    // Pretendard-ExtraBold 30
    @nonobjc class var h2: UIFont {
        return UIFont.font(.pretendardExtraBold, ofSize: 30)
    }
    
    // Pretendard-Bold 16
    @nonobjc class var body: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 16)
    }
    
    // Pretendard-Regular 14
    @nonobjc class var caption: UIFont {
        return UIFont.font(.pretendardRegular, ofSize: 14)
    }
    
    // Pretendard-Light 12
    @nonobjc class var small: UIFont {
        return UIFont.font(.pretendardLight, ofSize: 12)
    }
    
    // Pretendard-Thin 10
    @nonobjc class var tiny: UIFont {
        return UIFont.font(.pretendardThin, ofSize: 10)
    }
    
    // Pretendard-medium 10
    @nonobjc class var medium: UIFont {
        return UIFont.font(.pretendardMedium, ofSize: 16)
    }
}
