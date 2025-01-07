import UIKit

class LoadingViewController: UIViewController {
    
    var recordID : String = ""
    // "오브제 만드는 중" 라벨
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "여행의 추억을\n색으로 물들이는 중이에요!"
        label.numberOfLines = 2
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 로딩 중 이미지
    private let loadingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LOADING"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        guard let recordUUID = Int(recordID) else {
            print("유효하지 않은 recordID: \(recordID)")
            return
        }
            
        if let record = TravelRecordManager.shared.getRecord(by: recordUUID) {
            print("LoadingViewController에서 데이터 확인:")
            print("oneLine1: \(record.oneLine1!)")
        } else {
            print("recordID에 해당하는 기록을 찾을 수 없습니다.")
        }
        
        startLoading()
    }
    
    // UI 설정
    private func setupUI() {
        view.addSubview(loadingLabel)
        view.addSubview(loadingImageView)
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // 로딩 라벨 위치 (이미지 위)
            loadingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 177),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            loadingImageView.widthAnchor.constraint(equalToConstant: 220),
            loadingImageView.heightAnchor.constraint(equalToConstant: 150),

        ])
    }
    
    // 로딩 시작
    private func startLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.goToNextPage()
        }
    }
    
    // 다음 화면으로 이동
    private func goToNextPage() {
        // 다음 화면 이동 코드
        let resultVC = ResultViewController()
//        print(recordID)
        resultVC.recordID = recordID
        resultVC.modalTransitionStyle = .crossDissolve // 오픈 모션
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: true, completion: nil)
        print("recordID: \(recordID)")
        print("ResultVC로 이동 성공")
    }
}
