//
//  ChatInputContainerView.swift
//  ChatBoxApp
//
//  Created by Abhishek Jaiswal on 29/04/18.
//  Copyright © 2018 Abhishek Jaiswal. All rights reserved.
//

import Foundation
import Speech

import UIKit



class ChatInputContainerView: UIView, UITextFieldDelegate,SFSpeechRecognizerDelegate {
    
    
    
  var appinstace = UIApplication.shared.delegate as! AppDelegate
    
     var nameField: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    weak var chatLogController: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
            
            speechToText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btntouched)))
            
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    
    lazy var speechtextfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Speech here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        
        return textField
    }()
    
    
  
    //speech CONVERSION Microphone
    
    let speechToText:UIButton = {
        let speechToText = UIButton()
        speechToText.isUserInteractionEnabled = true
       // speechToText.image = UIImage(named: "microphone2")
        speechToText.setBackgroundImage(#imageLiteral(resourceName: "microphone2"), for: .normal)
      speechToText.translatesAutoresizingMaskIntoConstraints = false
        return speechToText
    }()
    
    
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        //backgroundColor = .blue
        
    
     // speech Recognition MIcrophone buttton section
     //   addSubview(speechToText)
       
        
        // upload image section
        addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        //uploadImageView.rightAnchor.constraint(equalTo: speechToText.leftAnchor, constant: 8).isActive = true
        
       addSubview(speechToText)
      //  speechToText.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
      //  speechToText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      //  speechToText.heightAnchor.constraint(equalToConstant: 44).isActive = true
      //  speechToText.rightAnchor.constraint(equalTo: inputTextField.leftAnchor, constant: 8).isActive = true
       
      speechToText.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        speechToText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      speechToText.widthAnchor.constraint(equalToConstant: 30).isActive = true
     speechToText.heightAnchor.constraint(equalToConstant: 30).isActive = true
      
         addSubview(sendButton)
   //send button section
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
     
       
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
   
    // text field section place to enter message
        addSubview(self.inputTextField)
        //x,y,w,h
       // self.inputTextField.leftAnchor.contraint(equa)
        self.inputTextField.leftAnchor.constraint(equalTo: speechToText.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //speech text fieldconstraint
     /*   self.speechtextfield.leftAnchor.constraint(equalTo: speechToText.rightAnchor, constant: 8).isActive = true
        self.speechtextfield.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.speechtextfield.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.speechtextfield.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
      */
        
      
    // separator betwen colection view and input Container view
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    


func btntouched()
{
    self.getallthefunc()
    print("clicked")
    
   // self.democheck()
    if audioEngine.isRunning
    {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        speechToText.isEnabled = false
        speechToText.backgroundColor = UIColor.red
        //speechToText.setTitle("Start Recording", for: .normal)
    }
    else
    {
        startRecording()
         speechToText.backgroundColor = UIColor.green
        
       // speechToText.setTitle("Stop Recording", for: .normal)
    }
    
}
    
    
    func getallthefunc()
    {
        speechToText.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.speechToText.isEnabled = isButtonEnabled
            }
        }
    }

    
    
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        do {
            //{
            print("data is there ")
            
        }  //4
        
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.speechtextfield.text = (result?.bestTranscription.formattedString)!
               //9
                isFinal = (result?.isFinal)!
                print("the recogonized data = \(self.speechtextfield.text)")//
                //self.appinstace.speechdata = self.speechtextfield.text
                self.inputTextField.text = self.speechtextfield.text
                
                
               // self.chatLogController?.handleSend2()
                
             
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.speechToText.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)  //11
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        speechtextfield.text = "Say something, I'm listening!"
        print("the said = \(speechtextfield.text)")
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechToText.isEnabled = true
        } else {
            speechToText.isEnabled = false
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        chatLogController?.handleSend()
        
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
//    func tetxfield()
//    {
//        //var usernameTextField: UITextField?
//
//
//        // 2.
//        let alertController = UIAlertController(
//            title: "Well Come",
//            message: "Speech Something I'm here",
//            preferredStyle: UIAlertControllerStyle.alert)
//
//        // 3.
//        let loginAction = UIAlertAction(
//            title: "Ok", style: UIAlertActionStyle.default)
//        {
//            (action) -> Void in
//
//            if let username = self.nameField?.text
//            {
//                print(" Username = \(username)")
//                //self.timelabel.text = username
//               // self.entrytime = username
//
//            }
//            else
//            {
//                print("No Username entered")
//            }
//
//
//        }
//
//        // 4.
//        alertController.addTextField
//            {
//                (txtUsername) -> Void in
//                self.nameField = txtUsername
//                self.nameField!.placeholder = "Hello Say Something...!"
//        }
//
//
//
//        // 5.
//        alertController.addAction(loginAction)
//    //    self.present(alertController, animated: true, completion: nil)
//
//    }
    
    
}
