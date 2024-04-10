//
//  SwiftUIView.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/8/24.
//
import AgoraRtcKit
import SwiftUI
import AVFoundation


class VideoCall: NSObject, AgoraRtcKit.AgoraRtcEngineDelegate {
    
    // The Agora App ID for the session.
    public let appId: String = "cbff64d10072461b87c54f225512efcb"
    // The client's role in the session.
    public var role: AgoraClientRole = .audience {
        didSet { agoraEngine.setClientRole(role) }
    }
    
    var label: String = ""
    
    // The set of all users in the channel.
    @Published public var allUsers: Set<UInt> = []
    
    // Integer ID of the local user.
    @Published public var localUserId: UInt = 0
    
    private var engine: AgoraRtcEngineKit?
    
    // The Agora RTC Engine Kit for the session.
    public var agoraEngine: AgoraRtcEngineKit {
        if let engine { return engine }
        let engine = setupEngine()
        self.engine = engine
        return engine
    }
    
    open func setupEngine() -> AgoraRtcEngineKit {
        let eng = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
//        if DocsAppConfig.shared.product != .voice {
            eng.enableVideo()
//        } else { eng.enableAudio() }
        eng.setClientRole(role)
        return eng
    }
    
    
    static func checkForPermissions() async -> Bool {
        var hasPermissions = await self.avAuthorization(mediaType: .video)
        // Break out, because camera permissions have been denied or restricted.
        if !hasPermissions { return false }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }
    
    static func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default: return false
        }
    }
    
    @MainActor
    func updateLabel(key: String, comment: String = "") {
        self.label = NSLocalizedString(key, comment: comment)
    }
    
    func joinVideoCall(
        _ channel: String, token: String? = nil, uid: UInt = 0
    ) async -> Int32 {
        /// See ``AgoraManager/checkForPermissions()``, or Apple's docs for details of this method.
        if await !VideoCall.checkForPermissions() {
            await self.updateLabel(key: "invalid-permissions")
            return -3
        }
        
        let opt = AgoraRtcChannelMediaOptions()
        opt.channelProfile = .communication
        
        return self.agoraEngine.joinChannel(
            byToken: token, channelId: channel,
            uid: uid, mediaOptions: opt
        )
    }
}

struct VideoView: UIViewRepresentable {
    let videoView: UIView
    
    func makeUIView(context: Context) -> UIView {
        return videoView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}


struct VideoCalling: View {
    @State var videoCall: VideoCall;
    //    @Binding var token: String
    //    @Binding var channelId: String
    //    @Binding var ownUid: String
    //    @Binding var remoteUid: String
    var token: String = ""
    var channelId: String = ""
    @State var showAlert: Bool = false;
    @State var message: String = "";
    @State var inaVideoCall: Bool = false;
    let localVideo = UIView()
    let remoteVideo = UIView()
    init(channelId: String, token: String) {
        self.videoCall = VideoCall();
        self.channelId = channelId;
        self.token = token;
        let isMainUser = (token == "007eJxTYNDcfsT7TKDboj2POj8VtviwXhD4lqcel2GiuWayq3Nf5z4FhuSktDQzkxRDAwNzIxMzwyQL82RTkzQjI1NTQ6PUtOSk1fNF0xoCGRnCyzxZGBkgEMRnZkhMSmZgAAAdlR4m");
        
        
        videoCall.agoraEngine.enableVideo();
        videoCall.agoraEngine.setClientRole(AgoraClientRole.broadcaster)
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = isMainUser ? 201 : 200
        videoCanvas.view = localVideo
        
        videoCall.agoraEngine.setupLocalVideo(videoCanvas)
        
        let videoCanvas2 = AgoraRtcVideoCanvas()
        videoCanvas2.uid = isMainUser ? 200 : 201;
        videoCanvas2.view = remoteVideo
        print("fsdhjbfshdjbfhsdj", videoCall.agoraEngine.setupRemoteVideo(videoCanvas2))
        
        let result = videoCall.agoraEngine.joinChannel(byToken: token, channelId: channelId, info: "", uid: isMainUser ? 201 : 200)
        message = errorMessage(for: result)
        print("fsdjkgnjksdg")
        if(result < 0) {
            print("fsdjkgnjksdg 2")
            showAlert = true
        }
    }
    //    init(channelId: String, token: String, isActive: Bool = true) {
    //
    //        if(isActive) {
    //            print("ThisO ", channelId, token)
    //
    //            videoCall = VideoCall();
    //    //        Task {
    //    //            await VideoCall.checkForPermissions()
    //    //        }
    ////            Mutable capture of 'inout' parameter 'self' is not allowed in concurrently-executing code
    //        } else {
    //            videoCall = nil
    //        }
    //
    //    }
    var body: some View {
        VStack {
            Button(action: {
                // Action to perform when the button is tapped
                print("Leave Call")
                videoCall.agoraEngine.stopPreview()
                videoCall.agoraEngine.leaveChannel()
            }) {
                Text("Leave")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            VideoView(videoView: remoteVideo)
            VideoView(videoView: localVideo)
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Failed to connect !"), message: Text(message), dismissButton: .default(Text("OK"), action: {
                showAlert = false;
                message = ""
            }))
        }
    }
    // Method to return user-readable error message based on error code
    private func errorMessage(for errorCode: Int32?) -> String {
        guard let errorCode = errorCode else {
            return "Error code is nil."
        }
        switch errorCode {
        case 0:
            return "Success"
        case -2:
            return "The parameter is invalid. Please check your inputs and try again."
        case -3:
            return "Failed to initialize the AgoraRtcEngineKit object. Please reinitialize the object."
        case -7:
            return "The AgoraRtcEngineKit object has not been initialized. Please initialize the object before calling this method."
        case -8:
            return "The internal state of the AgoraRtcEngineKit object is wrong. Please check the state and try again."
        case -17:
            return "The request to join the channel is rejected. Please ensure the user is not already in the channel."
        case -102:
            return "The channel name is invalid. Please provide a valid channel name and try again."
        case -121:
            return "The user ID is invalid. Please provide a valid user ID and try again."
        default:
            return "Unknown error occurred. Please try again later."
        }
    }
}
//}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
////        VideoCalling(token: "", channelId: "")
//    }
//}
