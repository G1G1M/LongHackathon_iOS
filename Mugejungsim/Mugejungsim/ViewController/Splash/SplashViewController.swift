import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경 이미지 추가
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "moments") // moments 이미지 사용
        backgroundImageView.contentMode = .scaleAspectFill // 이미지가 화면에 맞도록 설정
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // 배경 이미지 제약조건 설정
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 2초 후 메인 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let mainVC = OBViewController1()
//            let mainVC = MainViewController()
            let mainVC = LoginViewController() 
//            let mainVC = ObjeCreationViewController()
//            let mainVC = LoadingViewController()
//            let mainVC = ResultViewController()
//            let mainVC = UploadViewController()
//            let mainVC = MyRecordsViewController()
//            let mainVC = CreateViewController()
//            let mainVC = SavedPhotosViewController()
//            let mainVC = EmailViewController()
//            let mainVC = NameViewController()
//            let mainVC = StoryEditorViewController()
//            let mainVC = SaveAndEditViewController()
//            let mainVC = StopWritingViewController()
//            let mainVC = CheckObjeImageViewController()
//            let mainVC = DraftViewController()
//            let mainVC = USDZPreviewViewController()
//            let mainVC = ShareViewController()
//            let mainVC = SaveCheckModalViewController()
            
            mainVC.modalTransitionStyle = .crossDissolve
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        }
    }
}

