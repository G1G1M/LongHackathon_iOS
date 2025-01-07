//
//  ObjectModal.swift
//  Mugejungsim
//
//  Created by KIM JIWON on 12/28/24.
//

import UIKit

class ObjectModal: UIViewController {
    var travelRecord: TravelRecord? // 전달받을 여행 기록 데이터
    
    private let overlayView: UIView = { // 모달창 배경
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = { // 스크롤 가능한 뷰
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layer.cornerRadius = 12 // 모서리를 둥글게 설정
        scrollView.clipsToBounds = true   // 콘텐츠가 모서리를 넘지 않도록 설정
        scrollView.showsVerticalScrollIndicator = false   // 세로 스크롤바 숨김
        return scrollView
    }()
    
    private let contentView: UIView = { // 스크롤뷰 안에 들어갈 컨텐츠 뷰
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentLabel: UILabel = { // 제목 레이블
        let label = UILabel()
        label.text = "당신의 여행 컬러는\n\"바바 마젠타입니다.\""
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 1)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 1 // 한 줄로 제한
        label.translatesAutoresizingMaskIntoConstraints = false // AutoLayout 활성화
        return label
    }()
    
    private let glassButton: UIButton = { // 상단 버튼으로 변경
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "moments"), for: .normal) // 기본 이미지 설정
        button.imageView?.contentMode = .scaleAspectFit // 이미지 뷰의 콘텐츠 모드 설정
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(openUSDZPreviewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "X_Button"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "moments"), for: .normal) // 기본 이미지 설정
        button.imageView?.contentMode = .scaleAspectFit // 이미지 뷰의 콘텐츠 모드 설정
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let letterImage: UIImageView = { // 중앙 이미지
        let imageView = UIImageView()
        imageView.image = UIImage(named: "yellow")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let record = travelRecord {
            print("TravelRecord exists: \(record)")
            titleLabel.text = record.title ?? "제목 없음"
        } else {
            print("TravelRecord is nil")
            titleLabel.text = "제목 없음"
        }
        
        setupUI()
        updateLabelText()
        updateImages()

    }
    
    private func setupUI() {
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(separatorLine)
        contentView.addSubview(contentLabel)
        contentView.addSubview(glassButton)
        contentView.addSubview(letterImage)
        contentView.addSubview(backButton)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // Overlay
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -29),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 900),
            
            // Separator Line
            separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 88),
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.3),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36), // 위 여백 36
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24), // 좌측 여백 24
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24), // 우측 여백 -24
            titleLabel.heightAnchor.constraint(equalToConstant: 48), // 고정 높이 25
            
            // Glass Button
            glassButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20), // 텍스트 아래 20
            glassButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            glassButton.widthAnchor.constraint(equalToConstant: 145), // 너비 145
            glassButton.heightAnchor.constraint(equalToConstant: 145), // 높이 145
                
            // Letter Image
            letterImage.topAnchor.constraint(equalTo: glassButton.bottomAnchor, constant: 24), // 이미지 아래 20
            letterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            letterImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            letterImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -37),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
        ])
        contentLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 28).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
    }
    
    private func updateImages() {
        guard let record = travelRecord else { return }
           
        switch record.bottle {
        case "value1":
            glassButton.setImage(UIImage(named: "Dreamy Pink"), for: .normal)
            letterImage.image = UIImage(named: "pink")
        case "value2":
            glassButton.setImage(UIImage(named: "Cloud Whisper"), for: .normal)
            letterImage.image = UIImage(named: "whisper")
        case "value3":
            glassButton.setImage(UIImage(named: "Sunburst Yellow"), for: .normal)
            letterImage.image = UIImage(named: "yellow")
        case "value4":
            glassButton.setImage(UIImage(named: "Radiant Orange"), for: .normal)
            letterImage.image = UIImage(named: "orange")
        case "value5":
            glassButton.setImage(UIImage(named: "Serene Sky"), for: .normal)
            letterImage.image = UIImage(named: "serene_sky")
        case "value6":
            glassButton.setImage(UIImage(named: "Midnight Depth"), for: .normal)
            letterImage.image = UIImage(named: "midnight_depth")
        case "value7":
            glassButton.setImage(UIImage(named: "Wanderer's Flame"), for: .normal)
            letterImage.image = UIImage(named: "wandarer")
        case "value8":
            glassButton.setImage(UIImage(named: "Storybook Brown"), for: .normal)
            letterImage.image = UIImage(named: "brown")
        case "value9":
            glassButton.setImage(UIImage(named: "Ember Red"), for: .normal)
            letterImage.image = UIImage(named: "red")
        case "value10":
            glassButton.setImage(UIImage(named: "Meadow Green"), for: .normal)
            letterImage.image = UIImage(named: "green")
        default:
            glassButton.setImage(UIImage(named: "Storybook Brown"), for: .normal)
            letterImage.image = UIImage(named: "brown")
        }
    }
       
    private func updateLabelText() {
        guard let record = travelRecord else { return }
        let labelText: String
           
        switch record.bottle {
        case "value1":
            labelText = "당신의 여행 컬러는\n\"Dreamy Pink\"입니다."
        case "value2":
            labelText = "당신의 여행 컬러는\n\"Cloud Whisper\"입니다."
        case "value3":
            labelText = "당신의 여행 컬러는\n\"Sunburst Yellow\"입니다."
        case "value4":
            labelText = "당신의 여행 컬러는\n\"Radiant Orange\"입니다."
        case "value5":
            labelText = "당신의 여행 컬러는\n\"Serene Sky\"입니다."
        case "value6":
            labelText = "당신의 여행 컬러는\n\"Midnight Depth\"입니다."
        case "value7":
            labelText = "당신의 여행 컬러는\n\"Wanderer’s Flame\"입니다."
        case "value8":
            labelText = "당신의 여행 컬러는\n\"Storybook Brown\"입니다."
        case "value9":
            labelText = "당신의 여행 컬러는\n\"Ember Red\"입니다."
        case "value10":
            labelText = "당신의 여행 컬러는\n\"Meadow Green\"입니다."
        default:
            labelText = "당신의 여행 컬러는\n\"알 수 없음\"입니다."
        }
        contentLabel.text = labelText
    }
    
    @objc private func goBack() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func openUSDZPreviewController() {
        guard let record = travelRecord else { return }
        let USDZPreviewVC = USDZPreviewViewController()
        USDZPreviewVC.bottleType = record.bottle
        USDZPreviewVC.modalPresentationStyle = .fullScreen
        present(USDZPreviewVC, animated: false, completion: nil)
    }
}
