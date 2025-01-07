//
//  ObjeCreationViewController.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/24/24.
//

import UIKit

class ObjeCreationViewController: UIViewController {
    
    var recordID : String = ""
    var travelRecord : TravelRecord?
    
    private let items: [(value: String, title: String)] = [
        ("value1", "🥰 마치 사랑에 빠진 것처럼 설레던 여행"),
        ("value2", "🫧 눈앞에 펼쳐진 모든 것이 꿈같았던 여행"),
        ("value3", "🎉 웃음소리가 바람을 타고 퍼져 나갔던 여행"),
        ("value4", "✨ 모든 순간이 별빛처럼 반짝이는 여행"),
        ("value5", "️️💐 들꽃 같은 소소한 행복을 발견한 여행"),
        ("value6", "️🎞️ 매 순간 영화처럼 선명하게 새겨진 여행"),
        ("value7", "🪄 모퉁이마다 새로운 세계가 열리던 여행"),
        ("value8", "📚 평범했던 하루가 한 편의 이야기가 된 여행"),
        ("value9", "🥹 가슴 벅찬 아름다움과 진심이 머문 여행"),
        ("value10", "🍃 고요한 순간들이 나를 감싸 안은 여행")
    ]
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 여행은 당신에게\n어떤 의미인가요?"
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 서브텍스트 라벨
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 2개까지 선택할 수 있어요. (0 / 2)"
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 선택된 항목
    private var selectedItems: [String] = [] {
        didSet {
            updateCreateButtonState()
            subtitleLabel.text = "최대 2개까지 선택할 수 있어요. (\(selectedItems.count) / 2)"
        }
    }
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("유리병 편지 만들기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#242424")
        button.layer.cornerRadius = 8
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 8).cgPath
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        button.layer.masksToBounds = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCustomNavigationBar()
        setupUI()
        setupConstraints() // 제약조건 함수 호출
        
        // createButton 초기 상태 설정
            createButton.isEnabled = false
            createButton.setTitleColor(UIColor(hex: "#242424"), for: .normal)
            createButton.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
            createButton.backgroundColor = UIColor(hex: "#E9E9E9")
            createButton.layer.sublayers?.forEach {
                if $0 is CAGradientLayer {
                    $0.removeFromSuperlayer()
                }
            }
        
        // creatButton에 초기 그림자 고정
        DispatchQueue.main.async {
            self.createButton.layer.shadowPath = UIBezierPath(roundedRect: self.createButton.bounds, cornerRadius: 8).cgPath
        }
    }
    
    // MARK: - 네비게이션 바
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        // closeButton -> 취소 확인 모달창으로 이동 필요
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "X_Button"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navBar)
        navBar.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 40),
            
            closeButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func didTapCloseButton() {
        let stopSelectingVC = StopSelectingViewController()
        stopSelectingVC.modalTransitionStyle = .crossDissolve
        stopSelectingVC.modalPresentationStyle = .overFullScreen
        self.present(stopSelectingVC, animated: true, completion: nil)
    }
    
    // MARK: - Set UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(stackView)
        
        for (value, title) in items {
            let button = createItemButton(value: value, title: title)
            stackView.addArrangedSubview(button)
        }
    
        view.addSubview(createButton)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 23),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: - 항목 버튼 생성 : 항목에 대한 버튼 구현 위한 함수, 버튼 탭 함수
    private func createItemButton(value: String, title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 15)
        button.accessibilityIdentifier = value
        button.setTitleColor(UIColor(hex: "#555558"), for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1).cgColor
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(didTapItemButton(_:)), for: .touchUpInside)

        return button
    }
    
    @objc private func didTapItemButton(_ sender: UIButton) {
        guard let value = sender.accessibilityIdentifier else { return }
        
        if selectedItems.contains(value) {
            // 선택 해제
            selectedItems.removeAll { $0 == value }
            sender.backgroundColor = .white
            sender.layer.borderColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1).cgColor
            sender.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 15) // Regular 폰트로 변경
        } else {
            // 최대 선택 개수 초과 방지
            guard selectedItems.count < 2 else { return }
            selectedItems.append(value)
            sender.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
            sender.layer.borderColor = UIColor(red: 0.43, green: 0.43, blue: 0.87, alpha: 1).cgColor
            sender.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 15)
        }
    }
    
    private func updateCreateButtonState() {
        if selectedItems.count >= 1 {
            createButton.isEnabled = true
            createButton.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
            createButton.setTitleColor(.white, for: .normal)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor(red: 0.44, green: 0.43, blue: 0.7, alpha: 1).cgColor,
                UIColor(red: 0.78, green: 0.55, blue: 0.75, alpha: 1).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.frame = createButton.bounds
            gradientLayer.cornerRadius = 8
            createButton.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            createButton.isEnabled = false
            createButton.setTitleColor(UIColor(hex: "#242424"), for: .normal) // 변경된 부분
            createButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
            // Layer 제거
            createButton.layer.sublayers?.forEach {
                if $0 is CAGradientLayer {
                    $0.removeFromSuperlayer()
                }
            }
            createButton.backgroundColor = UIColor(hex: "#E9E9E9")
        }
        // subtitleLabel 텍스트 색상 변경
        subtitleLabel.textColor = selectedItems.isEmpty
            ? UIColor(hex: "#AAAAAA") // 아무것도 선택하지 않았을 때
            : UIColor(hex: "#7573C3") // 선택했을 때

        createButton.layer.shadowPath = UIBezierPath(roundedRect: createButton.bounds, cornerRadius: 8).cgPath
        createButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        createButton.layer.shadowOpacity = 1
        createButton.layer.shadowRadius = 1
        createButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        createButton.layer.masksToBounds = false
    }
    
    @objc private func didTapCreateButton() {
        print("선택된 값: \(selectedItems)")
        let objeNum: String = selectedItems[0]

        // userId 확인 및 범위 검증
        guard let userId = TravelRecordManager.shared.userId else {
            print("유효하지 않은 사용자 ID")
            return
        }

        // 중도 진행 여부 확인
        if let travelRecord = travelRecord, travelRecord.id != 0 {
            TravelRecordManager.shared.postId = travelRecord.id
            print("===============\(travelRecord.id)=================")
            print("===============\(TravelRecordManager.shared.postId ?? -1)=================")
            print("===============\(travelRecord.title)=================")
        } else {
            print("travelRecord가 nil이거나 ID가 0입니다.")
        }

        // getUserPosts 호출
        APIService.shared.getUserPosts(userId: userId) { [weak self] result in
            switch result {
            case .success(let records):
                print("불러온 게시물 개수: \(records.count)")
                
                var temp: TravelRecord? // `temp` 변수를 함수 범위에서 선언

                if let targetRecordID = self?.travelRecord?.id,
                   let matchedRecord = records.first(where: { $0.id == targetRecordID }) {
                    // 중도 참여용: targetRecordID와 매칭되는 레코드를 찾은 경우
                    print("업데이트할 레코드를 찾았습니다: \(matchedRecord)")
                    temp = matchedRecord
                    TravelRecordManager.shared.postId = temp?.id
                }else if let postId = TravelRecordManager.shared.postId,
                         let matchedByPostId = records.first(where: { $0.id == postId }) {
                   print("postId를 기준으로 레코드를 찾았습니다: \(matchedByPostId)")
                   temp = matchedByPostId
                } else {    // records가 비어 있는 경우 처리
                    print("레코드가 없습니다.")
                }

                guard let postId = TravelRecordManager.shared.postId else {
                    print("유효하지 않은 postId")
                    return
                }
                // `temp`가 설정된 경우 업데이트 로직 수행
                if var temp = temp {
                    temp.bottle = objeNum
                    TravelRecordManager.shared.temporaryOneline = objeNum
                    TravelRecordManager.shared.TemporaryCount = records.count
                    print("         Title : \(temp.title)")
                    print("         Bottle : \(temp.bottle)")
                    print("         records Count: \(records.count)")
                    print("         Temp Bottle : \(temp.bottle)")
                    print("         Temp records Count: \(records.count)")
                    
                    TravelRecordManager.shared.updateRecordOnServer(postId: postId, record: temp) { result in // 여기서 POST
                        switch result {
                        case .success(let response):
                            print("Successfully updated record: \(response)")
                        case .failure(let error):
                            print("Failed to update record: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("데이터 가져오기 실패: \(error.localizedDescription)")
            }
        }
        goToNextPage()
    }
    
    
    private func goToNextPage() {
        let loadingVC = LoadingViewController() // 이동할 ViewController 인스턴스 생성
        if let travelRecord = travelRecord, travelRecord.id != 0 {
            recordID = "0"
            print("===============\(travelRecord.id)=================")
            print("===============\(TravelRecordManager.shared.postId ?? -1)=================")
        } else {
            print("travelRecord가 nil이거나 ID가 0입니다.")
        }

        loadingVC.recordID = recordID
        print("recordID: \(recordID)")
        loadingVC.modalTransitionStyle = .crossDissolve // 화면 전환 스타일 설정 (페이드 효과)
        loadingVC.modalPresentationStyle = .fullScreen
        self.present(loadingVC, animated: true, completion: nil)
        print("loadingVC로 이동 성공")
    }
}
