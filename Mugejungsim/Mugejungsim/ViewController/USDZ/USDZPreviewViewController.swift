import UIKit
import RealityKit

class USDZPreviewViewController: UIViewController {

    var bottleType: String? // 보틀 타입
    var arView: ARView!
    var usdzEntity: ModelEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupARView() // ARView 초기화
        setupBackButton() // 백 버튼 추가
        loadUSDZModel() // USDZ 파일 로드 및 제스처 추가

        // 한 손가락 제스처 추가 (회전)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        arView.addGestureRecognizer(panGesture)

        // 두 손가락 제스처 추가 (줌)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }

    func setupARView() {
        // ARView 초기화
        arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false // AR 비활성화
        arView.translatesAutoresizingMaskIntoConstraints = false
        // 배경 색 설정
        arView.environment.background = .color(UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1))
        view.addSubview(arView)

        // ARView 레이아웃 설정
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupBackButton() {
        // 백 버튼 생성
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "X_Button"), for: .normal) // "X_Button" 이미지 사용
        backButton.tintColor = .white // 이미지 색상을 흰색으로 설정
        backButton.backgroundColor = .clear
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)

        // 버튼을 뷰에 추가
        view.addSubview(backButton)

        // 버튼 위치 설정 (ARView 위에 오버레이)
        NSLayoutConstraint.activate([
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            backButton.widthAnchor.constraint(equalToConstant: 14),
            backButton.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // page 닫기
    @objc func dismissModal() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let entity = usdzEntity else { return }

        // 화면의 크기 기반으로 회전 강도를 조절
        let viewWidth = arView.bounds.width
        let viewHeight = arView.bounds.height

        // 제스처의 이동량 가져오기
        let translation = gesture.translation(in: arView)

        if gesture.state == .changed {
            // 회전 각도 계산
            let angleY = Float(translation.x / viewWidth) * .pi // 좌우 드래그로 Y축 회전
            let angleX = Float(translation.y / viewHeight) * .pi // 위아래 드래그로 X축 회전 (부호 반전 제거)

            // 현재 회전에 새로운 회전 적용
            let rotationY = simd_quatf(angle: angleY, axis: [0, 1, 0]) // Y축 회전
            let rotationX = simd_quatf(angle: angleX, axis: [1, 0, 0]) // X축 회전
            entity.transform.rotation = rotationY * entity.transform.rotation * rotationX

            // 제스처 이동 초기화
            gesture.setTranslation(.zero, in: arView)
        }
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = usdzEntity else { return }

        if gesture.state == .changed {
            // 현재 크기 가져오기
            let currentScale = entity.scale

            // 새로운 스케일 계산
            let pinchScale = Float(gesture.scale)
            let newScale = currentScale * pinchScale

            // 크기 제한 (최소 0.05, 최대 2.0)
            entity.scale = [max(0.05, min(newScale.x, 2.0)),
                            max(0.05, min(newScale.y, 2.0)),
                            max(0.05, min(newScale.z, 2.0))]

            // 제스처 스케일 초기화
            gesture.scale = 1.0
        }
    }
    
    func loadUSDZModel() {
         guard let bottleType = bottleType else {
             print("Bottle type not provided.")
             return
         }

         // 파일 경로 결정
         let fileName: String
         switch bottleType {
         case "value1": fileName = "bottle_pink"
         case "value2": fileName = "bottle_blue"
         case "value3": fileName = "bottle_yellow"
         case "value4": fileName = "bottle_orange"
         case "value5": fileName = "bottle_sky"
         case "value6": fileName = "bottle_navy"
         case "value7": fileName = "bottle_purple"
         case "value8": fileName = "bottle_brown"
         case "value9": fileName = "bottle_red"
         case "value10": fileName = "bottle_green"
             
         default:
             print("Invalid bottle type.")
             return
         }

         guard let usdzURL = Bundle.main.url(forResource: fileName, withExtension: "usdz") else {
             print("USDZ file not found for bottle type: \(bottleType)")
             return
         }

         do {
             let entity = try ModelEntity.loadModel(contentsOf: usdzURL)
             usdzEntity = entity
             usdzEntity?.generateCollisionShapes(recursive: true)
             usdzEntity?.scale = [0.2, 0.2, 0.2]

             let anchor = AnchorEntity(world: [0, -0.6, -0.5])
             anchor.addChild(entity)
             arView.scene.addAnchor(anchor)

             print("Loaded USDZ model: \(fileName)")
         } catch {
             print("Failed to load USDZ file: \(error)")
         }
     }
    
}
