//
//  NotificationManager.swift
//  Mugejungsim
//
//  Created by 도현학 on 1/2/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 알림 권한 요청
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            } else if granted {
                print("알림 권한이 허용되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    
    // 10초 뒤 알림 예약
    func scheduleNotificationAfter(seconds: TimeInterval, navigateTo page: String) {
        let content = UNMutableNotificationContent()
        content.title = "띵동! 편지가 도착했습니다 💌"
        content.body = "여행 기록을 살펴보세요!"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.userInfo = ["page": page] // 알림에 데이터 추가
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: "secondsNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 에러: \(error.localizedDescription)")
            } else {
                print("알림이 \(seconds)초 후에 예약되었습니다.")
            }
        }
    }
    
    // 3일 뒤 알림 예약
    func scheduleNotificationAfter(days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "띵동! 편지가 도착했습니다 💌"
        content.body = "여행 기록을 살펴보세요!"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        var dateComponents = DateComponents()
        if let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) {
            dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: futureDate)
        }
        dateComponents.hour = 9 // 오전 9시 설정
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "daysNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 에러: \(error.localizedDescription)")
            } else {
                print("알림이 \(days)일 후 오전 9시에 예약되었습니다.")
            }
        }
    }
}
