//
//  ViewController.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/22/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // UILabel 초기화
            let label = UILabel(frame: CGRect(x: 20, y: 100, width: 200, height: 50))
            label.text = "Hello, World!"
            
            // 커스텀 폰트 설정
            if let customFont = UIFont(name: "Pretendard-Black", size: 16) {
                label.font = customFont
            } else {
                print("Pretendard-Black 폰트를 찾을 수 없습니다.")
            }
            
        
        // 배경 색상 설정
        view.backgroundColor = UIColor.systemBlue
        
        // 중앙 텍스트 추가
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to Snowball App!"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        welcomeLabel.textColor = UIColor.white
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        // 텍스트 레이아웃 설정
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

