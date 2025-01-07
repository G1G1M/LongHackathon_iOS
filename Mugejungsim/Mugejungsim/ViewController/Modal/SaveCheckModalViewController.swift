//
//  SaveCheckModalViewController.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/30/24.
//

import UIKit

class SaveCheckModalViewController: UIViewController {

    // MARK: - UI Elements
    var recordID : String = ""
    
    private let overlayView: UIView = { // 모달창 배경을 위한 변수
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Drop Shadow 설정
        view.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        view.layer.shadowOpacity = 0.25 // 그림자 투명도 (25%)
        view.layer.shadowRadius = 4 // 그림자 블러 반경
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // X, Y 위치
        
        return view
    }()
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "유리병 편지가\n컬렉션에 저장되었습니다."
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.font(.pretendardBold, ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        
        // overlayView에 애니메이션 추가
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.3) { // 0.3초 동안 페이드 인
            self.overlayView.alpha = 1
        }
        
        // 2초 후에 다음 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.navigateToCheckObjeImageVC()
        }
    }
    
    private func navigateToCheckObjeImageVC() {
        let CheckObjeImageVC = CheckObjeImageViewController()
        CheckObjeImageVC.recordID = recordID
        CheckObjeImageVC.modalTransitionStyle = .crossDissolve // 오픈 모션
        CheckObjeImageVC.modalPresentationStyle = .fullScreen
        self.present(CheckObjeImageVC, animated: true, completion: nil)
    }
    
    // MARK: - UI Setup
    
    private func setUI() {
        view.addSubview(overlayView)
        view.addSubview(containerView)
        
        containerView.addSubview(promptLabel)
        containerView.addSubview(checkImageView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Constraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 297),
            containerView.heightAnchor.constraint(equalToConstant: 278),
            
            // Prompt label
            promptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 23),
            promptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -23),
            promptLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -95),
            
            // Check image view
            checkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            checkImageView.bottomAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: -54),
            checkImageView.widthAnchor.constraint(equalToConstant: 34),
            checkImageView.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    
}
