import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    WidgetStore.capture(connectionOptions.urlContexts, warm: false)
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    WidgetStore.capture(URLContexts, warm: true)
    super.scene(scene, openURLContexts: URLContexts)
  }
}
