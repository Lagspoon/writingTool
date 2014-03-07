//
//  MIViewController.m
//  microphone
//
//  Created by Olivier Delecueillerie on 28/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "MIViewController.h"

@interface MIViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *controlStop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *controlPlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *controlRecord;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;

@end

@implementation MIViewController


- (NSURL *) outputFileURL {
    if (!_outputFileURL) {
        // Set the audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"MyAudioMemo.m4a",
                                   nil];
        _outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    }
    return _outputFileURL;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Disable Stop/Play button when application launches
    [self.controlStop setEnabled:NO];
    [self.controlPlay setEnabled:NO];


    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES ];

}



- (void)levelTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    float peak = [self.recorder peakPowerForChannel:0];
    float value = pow(10, (peak/10));
    [self.progressView setProgress:(value*10) animated:YES];
   }


- (IBAction)controlStop:(id)sender {
    [self.recorder stop];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];

}


- (IBAction)controlPlay:(id)sender {
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}

- (IBAction)controlRecord:(id)sender {
    // Stop the audio player before recording
    if (self.player.playing) {
        [self.player stop];
    }

    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        // Start recording for 3 seconds
        [self.recorder recordForDuration:180];
        self.controlRecord.image = [UIImage imageNamed:@"6.png"];

    } else {

        // Pause recording
        [self.recorder pause];
        self.controlRecord.image = [UIImage imageNamed:@"9.png"];

    }
    [self.controlStop setEnabled:YES];
    [self.controlPlay setEnabled:NO];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    self.controlRecord.image = [UIImage imageNamed:@"9.png"];

    [self.controlStop setEnabled:NO];
    [self.controlPlay setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
