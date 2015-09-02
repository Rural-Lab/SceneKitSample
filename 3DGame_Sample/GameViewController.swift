import UIKit
import QuartzCore
import SceneKit

import CoreMotion
import CoreLocation
import AVFoundation

class GameViewController: UIViewController ,CLLocationManagerDelegate, SCNSceneRendererDelegate {
    
    var tmpint=0
    
    var lm: CLLocationManager! = nil
    
    // create instance of MotionManager
    let motionManager: CMMotionManager = CMMotionManager()

    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    
    var degree = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラからVideoInputを取得.
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as! AVCaptureDeviceInput
        
        // セッションに追加.
        mySession.addInput(videoInput)
        
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(mySession) as! AVCaptureVideoPreviewLayer
//        myVideoLayer.frame = self.view.bounds
        myVideoLayer.frame = CGRectMake(0, 0, self.view.frame.width/2, self.view.frame.height/2)
        myVideoLayer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
//        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        
        // シーンオブジェクトを作成。これ以降シーンオブジェクトのルートノードに
        // 子ノードを追加していくことでシーンにオブジェクトを追加していく。
        // ここではdaeファイル(3Dデータ)の読み込みを行っている。
        let scene = SCNScene(named: "art.scnassets/ship.dae")
        
        // シーンオブジェクトを撮影するためのノードを作成
        let cameraNode = SCNNode()
        // カメラノードにカメラオブジェクトを追加
        cameraNode.camera = SCNCamera()
        // シーンのルートノードにカメラノードを追加
        scene!.rootNode.addChildNode(cameraNode)
        
        // カメラの位置を設定する。
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        // シーンに光を与える為のノードを作成
        let lightNode = SCNNode()
        // ライトノードに光を表すライトオブジェクトを追加
        lightNode.light = SCNLight()
        // ライトオブジェクトの光属性を全方位への光を表す属性とする
        lightNode.light!.type = SCNLightTypeOmni
        // ライトオブジェクトの位置を設定する
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        // シーンのルートノードにライトノードを追加
        scene!.rootNode.addChildNode(lightNode)
        
        // シーンに環境光を与える為に環境光ノードを作成
        let ambientLightNode = SCNNode()
        // 環境光ノードにライトオブジェクトを追加
        ambientLightNode.light = SCNLight()
        // ライトオブジェクトの光属性を環境光を表す属性とする
        ambientLightNode.light!.type = SCNLightTypeAmbient
        // 環境光の色を設定する
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        // シーンのルートノードに環境光ノードを追加
        scene!.rootNode.addChildNode(ambientLightNode)
        
        // ノード名を指定してshipのノードをシーンから取得する
        let ship = scene!.rootNode.childNodeWithName("ship", recursively: true)!
        // shipに対してアニメーションを設定する。ここではy軸を中心とした永続的な回転を設定している。
        
//        let aPlaneNode = SCNNode()
//        // キューブ型の形状（Geometry）を生成
//        let aPlaneGeometry = SCNPlane(width: self.view.frame.width/32, height: self.view.frame.height/32)
//        let PlaneMaterial = SCNMaterial()
////        PlaneMaterial.diffuse.contents = myVideoLayer
////        // 上記ノードの形状（Geometry）をキューブにする
////        aPlaneGeometry.materials = [PlaneMaterial]
//        aPlaneNode.geometry = aPlaneGeometry
//        
//        scene!.rootNode.addChildNode(aPlaneNode)
        
//        let name = "Hello sonoda"
//        let text = SCNText(string: name, extrusionDepth: 0.5)
//        let textNode = SCNNode(geometry: text)
//        textNode.position = SCNVector3(x: 0.0, y: 0.0, z: 40.0)
//        textNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2)*2, 1.0, 0.0, 0.0)
//        let const = SCNLookAtConstraint(target: cameraNode)
//        const.gimbalLockEnabled = true
//        textNode.constraints = [const]
//        scene!.rootNode.addChildNode(textNode)
        
        // シーンを表示するためのビューへの参照を取得
        let scnView = self.view as! SCNView
        
//        scnView.layer.addSublayer(myVideoLayer)
        // ビューのシーンに今までオブジェクトを追加してきたシーンを代入
        scnView.scene = scene
        
        // シーンに追加されたカメラを単純に操作できるようにする
        scnView.allowsCameraControl = true
        
        // ビューのフレーム数等のパフォーマンスに関わる統計情報をビューの下部に表示
        scnView.showsStatistics = true
        
        // ビューの背景色を黒に指定
        scnView.backgroundColor = UIColor.greenColor()
        
        lm = CLLocationManager()
        // 位置情報を取るよう設定
        
        // ※ 初回は確認ダイアログ表示
        lm.requestAlwaysAuthorization()
        lm.delegate = self
        lm.distanceFilter = 1.0 // 1m毎にGPS情報取得
        lm.desiredAccuracy = kCLLocationAccuracyBest // 最高精度でGPS取得
        lm.startUpdatingLocation() // 位置情報更新機能起動
        lm.startUpdatingHeading() // コンパス更新機能起動
        
        // Initialize MotionManager
        motionManager.deviceMotionUpdateInterval = 0.05 // 20Hz
        
        // Start motion data acquisition
        motionManager.startDeviceMotionUpdatesToQueue( NSOperationQueue.currentQueue(), withHandler:{
            deviceManager, error in
            
            var attitude: CMAttitude = deviceManager.attitude
            
            var quaternion: CMQuaternion = attitude.quaternion
            
            cameraNode.rotation = SCNQuaternion(x: Float32(quaternion.x), y: Float32(quaternion.y), z: Float32(quaternion.z), w: Float32(quaternion.w))

            let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
            let gq2 = GLKQuaternionMake(Float(quaternion.x), Float(quaternion.y), Float(self.degree), Float(quaternion.w))
            let qp = GLKQuaternionMultiply(gq1, gq2)
            let rq = SCNVector4Make(qp.x, qp.y, qp.z, qp.w)
            
            cameraNode.orientation = rq
        })
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    // コンパスの値を受信
    func locationManager(manager:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        degree = (newHeading.magneticHeading/180)-1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
