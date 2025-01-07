import UIKit

class CheckObjeImageViewController: UIViewController {
    
    var recordID: String = ""
    private let gradientLayer = CAGradientLayer()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 이야기를 담은\n유리병 편지가 완성되었어요!"
        label.numberOfLines = 2
        label.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 1)
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let touchLabel: UILabel = {
        let label = UILabel()
        label.text = "유리병 속 편지를 확인해보세요!"
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.46, green: 0.45, blue: 0.76, alpha: 1)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bottleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Storybook Brown") // 기본 이미지 설정
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let readButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("편지 읽기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = false // 그림자가 잘리지 않도록 false로 설정
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor(red: 0.46, green: 0.45, blue: 0.76, alpha: 1)
//        // 그림자 설정
//        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        button.layer.shadowOpacity = 1
//        button.layer.shadowRadius = 4 // 더 강하게 강조
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    
//    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // UI 요소 추가
        view.addSubview(textLabel)
        view.addSubview(touchLabel)
        view.addSubview(bottleImageView)
        view.addSubview(readButton)
        
        // 버튼 액션 연결
        readButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        setConstraints()
        
        guard let recordID = Int(recordID) else {
            print("유효하지 않은 recordID: \(recordID)")
            return
        }
            
        if let record = TravelRecordManager.shared.getRecord(by: recordID) {
            print("CheckObjeImageViewController에서 데이터 확인:")
            print("Record ID: \(record.id)")
            print("Title: \(record.title)")
//            print("oneLine1: \(record.oneLine1)")
//            print("oneLine2: \(record.oneLine2)")
        } else {
            print("recordID에 해당하는 기록을 찾을 수 없습니다.")
        }
        updateImages()
        setupGradientLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradientLayer()
        setupShadowForReadButton()
        updateImages()
    }
    
    // MARK: - Constraints Setup
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // textLabel 위치
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: touchLabel.topAnchor, constant: -37),
            
            touchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            touchLabel.bottomAnchor.constraint(equalTo: bottleImageView.topAnchor, constant: -37),
            
            // bottleImageView 위치
            bottleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottleImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            bottleImageView.widthAnchor.constraint(equalToConstant: 200),
            bottleImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // readButton 위치
            readButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            readButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupGradientLayer() { 
        gradientLayer.colors = [
            UIColor(red: 0.44, green: 0.43, blue: 0.7, alpha: 1).cgColor,
            UIColor(red: 0.78, green: 0.55, blue: 0.75, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = readButton.bounds
        gradientLayer.cornerRadius = 8

        if gradientLayer.superlayer == nil {
            readButton.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    // MARK: - Button Actions
    @objc func saveButtonTapped() {
        print("성공!")
        let ShareVC = ShareViewController()
        ShareVC.recordID = recordID
        ShareVC.modalPresentationStyle = .fullScreen
        self.present(ShareVC, animated: true, completion: nil)
    }
    
    
    private func updateImages() {
        switch TravelRecordManager.shared.temporaryOneline! {
        case "value1":
            bottleImageView.image = UIImage(named: "Dreamy Pink")
        case "value2":
            bottleImageView.image = UIImage(named: "Cloud Whisper")
        case "value3":
            bottleImageView.image = UIImage(named: "Sunburst Yellow")
        case "value4":
            bottleImageView.image = UIImage(named: "Radiant Orange")
        case "value5":
            bottleImageView.image = UIImage(named: "Serene Sky")
        case "value6":
            bottleImageView.image = UIImage(named: "Midnight Depth")
        case "value7":
            bottleImageView.image = UIImage(named: "Wanderer's Flame")
        case "value8":
            bottleImageView.image = UIImage(named: "Storybook Brown")
        case "value9":
            bottleImageView.image = UIImage(named: "Ember Red")
        case "value10":
            bottleImageView.image = UIImage(named: "Meadow Green")
        default:
            bottleImageView.image = UIImage(named: "Storybook Brown")
        }
    }
    
    // MARK: - Gradient Layer Setup

//    private func setupGradientLayer() {
//        gradientLayer.colors = [
//            UIColor(red: 0.44, green: 0.43, blue: 0.7, alpha: 1).cgColor,
//            UIColor(red: 0.78, green: 0.55, blue: 0.75, alpha: 1).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//        gradientLayer.frame = readButton.bounds
//        gradientLayer.cornerRadius = 8
//
//        if gradientLayer.superlayer == nil {
//            readButton.layer.insertSublayer(gradientLayer, at: 0)
//        }
//    }
    
    // MARK: - Shadow Setup

    private func setupShadowForReadButton() {
        readButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        readButton.layer.shadowOpacity = 1
        readButton.layer.shadowRadius = 6
        readButton.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
