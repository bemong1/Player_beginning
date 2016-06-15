//
//  PlayerViewController.m
//  Player-0610
//
//  Created by kwk on 2016. 6. 10..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "PlayerViewController.h"
#import "URLList.h"

#import "CALayer+AddMethod.h"
#import "NSString+AddMethod.h"


@interface PlayerViewController ()

@property (strong) IBOutlet NSView *topView;
@property (strong) IBOutlet NSView *bottomView;
@property (strong) IBOutlet NSView *repeatIntervalView;

@property (strong) NSTimer *timer;

#pragma mark Playback Controller Button

@property (strong) IBOutlet NSButton *playOrPauseButton;
@property (strong) IBOutlet NSButton *stopButton;

@property (strong) IBOutlet NSButton *increasePlaybackRateButton;
@property (strong) IBOutlet NSButton *restorePlaybackRateButton;
@property (strong) IBOutlet NSButton *decreasePlaybackRateButton;

@property (strong) IBOutlet NSButton *stepBackwardButton;
@property (strong) IBOutlet NSButton *stepForwardButton;

@property (strong) IBOutlet NSButton *previousButton;
@property (strong) IBOutlet NSButton *nextButton;

@property (strong) IBOutlet NSButton *toggleRepeatModeButton;
@property (strong) IBOutlet NSButton *toggleMuteModeButton;
@property (strong) IBOutlet NSButton *toggleShuffleModeButton;

@property (strong) IBOutlet NSButton *changeVideoGravityButton;

@property (strong) IBOutlet NSSlider *seekBarSlider;
@property (strong) IBOutlet NSSlider *volumeBarSlider;

@property (strong) IBOutlet NSButton *currentTimeViewButton;
@property (strong) IBOutlet NSButton *durationTimeViewButton;

@property (strong) IBOutlet NSButton *repeatIntervalButton;
@property (strong) IBOutlet NSButton *setRepeatIntervalStartButton;
@property (strong) IBOutlet NSButton *setRepeatIntervalEndButton;

@property (strong) IBOutlet NSProgressIndicator *loadStateProgressIndicator;

- (IBAction)playOrPauseAction:(id)sender;
- (IBAction)stopAction:(id)sender;

- (IBAction)increasePlaybackRateAction:(id)sender;
- (IBAction)restorePlaybackRateAction:(id)sender;
- (IBAction)decreasePlaybackRateAction:(id)sender;

- (IBAction)stepBackwardAction:(id)sender;
- (IBAction)stepForwardAction:(id)sender;

- (IBAction)toggleRepeatModeAction:(id)sender;
- (IBAction)toggleMuteModeAction:(id)sender;
- (IBAction)toggleShuffleModeAction:(id)sender;
- (IBAction)changeVideoGravityAction:(id)sender;

- (IBAction)seekBarAction:(id)sender;
- (IBAction)volumeBarAction:(id)sender;

- (IBAction)currentTimeViewAction:(id)sender;

- (IBAction)repeatIntervalAction:(id)sender;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setWantsLayer:YES];
    [self.view.layer backgroundColorRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    
    [_topView setWantsLayer:YES];
    [_topView.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    
    [_bottomView setWantsLayer:YES];
    [_bottomView.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    
    [self setButtonTitle];
//    [self setEnabledSubControllers:YES];
    
    _loadStateProgressIndicator.hidden = YES;
    
    [_seekBarSlider sendActionOn:NSLeftMouseUpMask|NSLeftMouseDraggedMask];
    [_volumeBarSlider sendActionOn:NSLeftMouseUpMask|NSLeftMouseDraggedMask];
    
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:[self durationTime]];
    
    _seekBarSlider.floatValue = 0.0f;
    _volumeBarSlider.floatValue = 1.0f;
    _currentRate = 1.0f;
    _currentVolume = 1.0f;
    
    _minRate = 0.5f;
    _maxRate = 2.0f;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)dismissController:(id)sender {
    [super dismissController:sender];
    [self stopMediaFile];
}

- (void)setNotifications:(id)playerController {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerPlaybackStateDidChangeNotification) name:PlayerControllerPlaybackStateDidChangeNotification object:playerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerLoadStateDidChangeNotification) name:PlayerControllerLoadStateDidChangeNotification object:playerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerPlaybackDidPlayToEndTimeNotification) name:PlayerControllerPlaybackDidPlayToEndTimeNotification object:playerController];
}

- (void)removeNotifications:(id)playerController {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onPlayerControllerPlaybackStateDidChangeNotification {
    if(_playerController.playbackState == PlaybackStatePlaying) {
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if(_timer == nil) {
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(showPlaybackTime:) userInfo:nil  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

            
        }
    } else if(_playerController.playbackState == PlaybackStatePaused) {
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)onPlayerControllerLoadStateDidChangeNotification {
    if(_playerController.loadState == LoadStateLoading) {
        [self setEnabledSubControllers:NO];
        
        _loadStateProgressIndicator.hidden = NO;
        [_loadStateProgressIndicator startAnimation:nil];
    } else if(_playerController.loadState == LoadStateLoaded) {
        [self setEnabledSubControllers:YES];
        
        [_loadStateProgressIndicator stopAnimation:nil];
        _loadStateProgressIndicator.hidden = YES;
        
        [_playerController setRate:_currentRate];
        [self setMute:_mute];
        
        _seekBarSlider.floatValue = 0.0f;
        _seekBarSlider.maxValue = _playerController.durationTime;
        _volumeBarSlider.maxValue = 1.0f;
        
        _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
        _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:[self durationTime]];
    } else if(_playerController.loadState == LoadStateFailed) {
        [self setEnabledSubControllers:NO];

    }
}

- (void)onPlayerControllerPlaybackDidPlayToEndTimeNotification {
    if(_repeat == YES) {
        [_playerController setCurrentTime:0.0f];
        [_playerController play];
    } else {

    }
}

- (void)showPlaybackTime:(NSTimer*)timer {
    _seekBarSlider.floatValue = _playerController.currentTime;
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:[self durationTime]];
}


#pragma mark Playback Controller (getter/setter)

- (void)setCurrentRate:(float)currentRate {
    if(_currentRate < currentRate) {
        if(_currentRate < (_maxRate - 0.05f)) {
            _currentRate = currentRate;
        } else {
            _currentRate = _maxRate;
        }
    } else {
        if(_currentRate > (_minRate + 0.05f)) {
            _currentRate = currentRate;
        } else {
            _currentRate = _minRate;
        }
    }
    
    if(_playerController.playbackState == PlaybackStatePlaying) {
        [_playerController setRate:_currentRate];
    }
}

- (float)remainingTime {
    return _playerController.durationTime - _playerController.currentTime;
}

- (float)durationTime {
    return _playerController.durationTime;
}

- (void)setCurrentVolume:(float)currentVolume {
    [_playerController setVolume:_currentVolume];
    _currentVolume = currentVolume;
}

- (void)setMute:(BOOL)mute {
    if(mute == NO) {
        [_playerController setVolume:_currentVolume];
    } else {
        [_playerController setVolume:0.0f];
    }
    _mute = mute;
}


- (void)loadMediaFile:(NSURL*)url {    
    _playerController = [[PlayerController alloc]initWithMediaFileURL:url andRect:self.view.bounds];
    [self.view addSubview:_playerController];
    [self setNotifications:_playerController];
}

- (void)stopMediaFile {
    [_playerController pause];
    [self removeNotifications:_playerController];
    [_playerController removeFromSuperviewWithoutNeedingDisplay];
    _playerController = nil;
}

- (void)playOrPause {
    if(_playerController.playbackState == PlaybackStatePlaying) {
        [_playerController pause];
    } else if(_playerController.playbackState == PlaybackStatePaused) {
        [_playerController play];
    }
}

- (void)increasePlaybackRate {
    [self setCurrentRate: _currentRate + 0.1f];
}

- (void)restorePlaybackRate {
    [self setCurrentRate:1.0f];
}

- (void)decreasePlaybackRate {
    [self setCurrentRate: _currentRate - 0.1f];
}

- (void)changeVideoGravity {
    switch(_playerController.videoGravity) {
        case VideoGravityResize:
            _playerController.videoGravity = VideoGravityResizeAspectFill;
            break;
        case VideoGravityResizeAspect:
            _playerController.videoGravity = VideoGravityResize;
            break;
        case VideoGravityResizeAspectFill:
            _playerController.videoGravity = VideoGravityResizeAspect;
            break;
    }
}

- (void)stepBackward {
    [_playerController setCurrentTime:_playerController.currentTime - 5.0f];
}

- (void)stepForward {
    [_playerController setCurrentTime:_playerController.currentTime + 5.0f];
}

//- (void)previous {
//    if(_shuffle == NO) {
//        [_urlList movingCursorToPreviousLocation];
//    } else {
//        [_urlList movingCursorToRandomLocation];
//    }
//    [self stopMediaFile];
//    [self loadMediaFile:[_urlList getURLFromCurrentCursor]];
//}
//
//- (void)next {
//    if(_shuffle == NO) {
//        [_urlList movingCursorToNextLocation];
//    } else {
//        [_urlList movingCursorToRandomLocation];
//    }
//    [self stopMediaFile];
//    [self loadMediaFile:[_urlList getURLFromCurrentCursor]];
//}


#pragma mark Playback Controller Button

- (IBAction)playOrPauseAction:(id)sender {
    [self playOrPause];
}

- (IBAction)stopAction:(id)sender {
    [self stopMediaFile];
    [self.view setHidden:YES];
}

- (IBAction)increasePlaybackRateAction:(id)sender {
    [self increasePlaybackRate];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _currentRate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
}

- (IBAction)restorePlaybackRateAction:(id)sender {
    [self restorePlaybackRate];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _currentRate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
}

- (IBAction)decreasePlaybackRateAction:(id)sender {
    [self decreasePlaybackRate];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _currentRate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
}

- (IBAction)stepForwardAction:(id)sender {
    [self stepForward];
}

- (IBAction)stepBackwardAction:(id)sender {
    [self stepBackward];
}

- (IBAction)seekBarAction:(id)sender {
    _playerController.currentTime = _seekBarSlider.floatValue;
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
}

- (IBAction)volumeBarAction:(id)sender {
    [self setCurrentVolume:_volumeBarSlider.floatValue];
    
    if(_currentVolume == 0.0f) {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
    } else {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
    }
}

- (IBAction)changeVideoGravityAction:(id)sender {
    [self changeVideoGravity];
}

- (IBAction)toggleRepeatModeAction:(id)sender {
    if(_repeat == NO) {
        [self setAttributeButton:_toggleRepeatModeButton  title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
    } else {
        [self setAttributeButton:_toggleRepeatModeButton  title:@"" color:[NSColor redColor]  font:[NSFont fontWithName:@"Feather" size:25]];
    }
    [self setRepeat:!_repeat];
}

- (IBAction)toggleShuffleModeAction:(id)sender {
    if(_shuffle == NO) {
        [self setAttributeButton:_toggleShuffleModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
    } else {
        [self setAttributeButton:_toggleShuffleModeButton title:@"" color:[NSColor redColor]  font:[NSFont fontWithName:@"Feather" size:25]];
    }
    [self setShuffle:!_shuffle];
}

- (IBAction)toggleMuteModeAction:(id)sender {
    if(_mute == NO) {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
        _volumeBarSlider.floatValue = 0.0f;
    } else {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
        _volumeBarSlider.floatValue = _currentVolume;
    }
    [self setMute:!_mute];
}

- (IBAction)currentTimeViewAction:(id)sender {
    
}

- (IBAction)repeatIntervalAction:(id)sender {
    
}

#pragma mark Mouse event

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];

    static BOOL flag;
    if(flag == NO) {
        [_topView animator].hidden = YES;
        [_bottomView animator].hidden = YES;
    } else {
        [_topView animator].hidden = NO;
        [_bottomView animator].hidden = NO;
    }
    flag = !flag;
}


#pragma mark Objects

- (void)setButtonTitle {
    NSFont* font = [NSFont fontWithName:@"Feather" size:25];
    
    [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_stopButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_stepForwardButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_stepBackwardButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_previousButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_nextButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_changeVideoGravityButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_toggleRepeatModeButton title:@"" color:[NSColor redColor] font:font];
    [self setAttributeButton:_toggleShuffleModeButton title:@"" color:[NSColor redColor] font:font];
    [self setAttributeButton:_increasePlaybackRateButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", 1.0f] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
    [self setAttributeButton:_decreasePlaybackRateButton title:@"" color:[NSColor blueColor] font:font];
    [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
    [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor redColor] font:[NSFont fontWithName:@"Feather" size:21]];
}

- (void)setEnabledSubControllers:(BOOL)flag {
    _playOrPauseButton.enabled = flag;
    _stepForwardButton.enabled = flag;
    _stepBackwardButton.enabled = flag;
    _changeVideoGravityButton.enabled = flag;
    _toggleRepeatModeButton.enabled = flag;
    _increasePlaybackRateButton.enabled = flag;
    _restorePlaybackRateButton.enabled = flag;
    _decreasePlaybackRateButton.enabled = flag;
    _seekBarSlider.enabled = flag;
    _volumeBarSlider.enabled = flag;
    _toggleMuteModeButton.enabled = flag;
    _toggleShuffleModeButton.enabled = flag;
    _currentTimeViewButton.enabled = flag;
    _durationTimeViewButton.enabled = flag;
}

- (void)setAttributeButton:(NSButton*) button
                     title:(NSString*) title
                     color:(NSColor*) color
                      font:(NSFont*) font {
    [button setFont:font];
    [button setTitle:title];
    
    NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc]
                                              initWithAttributedString:[button attributedTitle]];
    NSRange range = NSMakeRange(0, [buttonTitle length]);
    [buttonTitle addAttribute:NSForegroundColorAttributeName
                        value:color
                        range:range];
    [button setAttributedTitle:buttonTitle];
}


@end
