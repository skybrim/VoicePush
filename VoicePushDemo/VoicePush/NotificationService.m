//
//  NotificationService.m
//  VoicePush
//
//  Created by Wiley on 2019/6/20.
//  Copyright © 2019 Wiley. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationService ()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@property (nonatomic, strong) AVSpeechSynthesisVoice *synthesisVoice;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    /*
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    self.contentHandler(self.bestAttemptContent);
     */
    
    //静止原来的音效
    self.bestAttemptContent.sound = nil;
    // 播报语音
    [self playVoiceWithContent: self.bestAttemptContent.body];

    //当同时推送了多条消息，需要多条消息一条一条的挨个播报
    //将此行代码注释，在语音播报结束的代码中执行
//    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

#pragma mark - 语音播报相关代码
- (void)playVoiceWithContent:(NSString *)content {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:content];
    utterance.rate = 0.5;
    utterance.voice = self.synthesisVoice;
    [self.synthesizer speakUtterance:utterance];
}

//在语音播报完成的代理函数中，我们添加下面的一行代码
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    self.contentHandler(self.bestAttemptContent);
}

- (AVSpeechSynthesisVoice *)synthesisVoice {
    if (!_synthesisVoice) {
        _synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    }
    return _synthesisVoice;
}

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

@end
