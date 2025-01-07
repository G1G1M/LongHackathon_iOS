//
//  ShareViewController.swift
//  Mugejungsim
//
//  Created by KIM JIWON on 12/28/24.
//

import UIKit


class ShareViewController: UIViewController {
    
    var recordID: String = ""
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let ButtontContentView = UIView()
    
    private let mode : String = ""
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "당신의 여행 컬러는\n\"바바 마젠타입니다.\""
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let glassImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "moments")
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//
//        return imageView
//    }()
    
    let openPreviewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Storybook Brown"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let letterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "yellow")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("홈으로 돌아가기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        button.setTitleColor(.white, for: .normal) // 폰트 색상을 흰색으로 설정
        button.backgroundColor = UIColor(red: 0.46, green: 0.45, blue: 0.76, alpha: 1)
        button.layer.cornerRadius = 8
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 8).cgPath
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("공유하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        button.setTitleColor(.white, for: .normal) // 폰트 색상을 흰색으로 설정
        button.backgroundColor = UIColor(red: 0.46, green: 0.45, blue: 0.76, alpha: 1)
        button.layer.cornerRadius = 8
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 8).cgPath
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationManager.shared.requestNotificationAuthorization()
        view.backgroundColor = .white
        updateImages()
        updateLabelText()
        setupUI()
        
        openPreviewButton.addTarget(self, action: #selector(openUSDZPreviewController), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        scrollView.backgroundColor = .white
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1070)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(contentLabel)
        contentView.addSubview(openPreviewButton)
        contentView.addSubview(letterImage)
        
        view.addSubview(homeButton)
        view.addSubview(shareButton)
        view.addSubview(openPreviewButton)
        
        setupConstraints()
        setupCustomNavigationBar()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            openPreviewButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            openPreviewButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            openPreviewButton.widthAnchor.constraint(equalToConstant: 200),
            openPreviewButton.heightAnchor.constraint(equalToConstant: 200),

            letterImage.topAnchor.constraint(equalTo: openPreviewButton.bottomAnchor, constant: 20),
            letterImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            letterImage.widthAnchor.constraint(equalToConstant: 328),
            letterImage.heightAnchor.constraint(equalToConstant: 610),
            
            homeButton.topAnchor.constraint(equalTo: letterImage.bottomAnchor, constant: 20),
            homeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            homeButton.heightAnchor.constraint(equalToConstant: 52),
            
            shareButton.topAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: 10),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    // MARK: - 네비게이션 바
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "out"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(navBar)
        navBar.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 20),
        ])
    }
    
    @objc private func didTapCloseButton() {
        let stopSelectingVC = StopSelectingViewController()
        stopSelectingVC.modalTransitionStyle = .crossDissolve
        stopSelectingVC.modalPresentationStyle = .overFullScreen
        self.present(stopSelectingVC, animated: true, completion: nil)
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func homeButtonTapped() {
        print("Home button frame: \(homeButton.frame)")
        print("Home button isHidden: \(homeButton.isHidden)")
        print("Home button isUserInteractionEnabled: \(homeButton.isUserInteractionEnabled)")
        
        print("알림 예약 시작")
        NotificationManager.shared.scheduleNotificationAfter(seconds: 10, navigateTo: "LoginViewController")

        let myRecordsVC = MyRecordsViewController()
        myRecordsVC.modalPresentationStyle = .fullScreen
        present(myRecordsVC, animated: true, completion: nil)
    }
    
    @objc private func shareButtonTapped() {
        guard let image = letterImage.image else {
            print("이미지를 찾을 수 없습니다.")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateImages() {
//        print(TravelRecordManager.shared.temporaryOneline!)
        
        switch TravelRecordManager.shared.temporaryOneline! {
        case "value1":
            openPreviewButton.setImage(UIImage(named: "Dreamy Pink"), for: .normal)
            letterImage.image = UIImage(named: "pink")
        case "value2":
            openPreviewButton.setImage(UIImage(named: "Cloud Whisper"), for: .normal)
            letterImage.image = UIImage(named: "whisper")
        case "value3":
            openPreviewButton.setImage(UIImage(named: "Sunburst Yellow"), for: .normal)
            letterImage.image = UIImage(named: "yellow")
        case "value4":
            openPreviewButton.setImage(UIImage(named: "Radiant Orange"), for: .normal)
            letterImage.image = UIImage(named: "orange")
        case "value5":
            openPreviewButton.setImage(UIImage(named: "Serene Sky"), for: .normal)
            letterImage.image = UIImage(named: "serene_sky")
        case "value6":
            openPreviewButton.setImage(UIImage(named: "Midnight Depth"), for: .normal)
            letterImage.image = UIImage(named: "midnight_depth")
        case "value7":
            openPreviewButton.setImage(UIImage(named: "Wanderer's Flame"), for: .normal)
            letterImage.image = UIImage(named: "wandarer")
        case "value8":
            openPreviewButton.setImage(UIImage(named: "Storybook Brown"), for: .normal)
            letterImage.image = UIImage(named: "brown")
        case "value9":
            openPreviewButton.setImage(UIImage(named: "Ember Red"), for: .normal)
            letterImage.image = UIImage(named: "red")
        case "value10":
            openPreviewButton.setImage(UIImage(named: "Meadow Green"), for: .normal)
            letterImage.image = UIImage(named: "green")
        default:
            openPreviewButton.setImage(UIImage(named: "Storybook Brown"), for: .normal)
            letterImage.image = UIImage(named: "brown")
        }
    }
    
    private func updateLabelText() {
        // oneLine1 값을 확인하고 contentLabel 업데이트
        let labelText: String
        switch TravelRecordManager.shared.temporaryOneline! {
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
    
    @objc func openUSDZPreviewController() {
        let USDZPreviewVC = USDZPreviewViewController()
        USDZPreviewVC.bottleType = TravelRecordManager.shared.temporaryOneline!
        USDZPreviewVC.modalPresentationStyle = .fullScreen
        present(USDZPreviewVC, animated: false, completion: nil)
    }

}
