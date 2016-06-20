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

@property (strong) NSTimer *showPlaybackTimer;
@property (strong) NSTimer *repeatIntervalTimer;

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
@property (strong) IBOutlet NSButton *changeVideoResizeButton;

@property (strong) IBOutlet NSSlider *seekBarSlider;
@property (strong) IBOutlet NSSlider *volumeBarSlider;

@property (strong) IBOutlet NSButton *currentTimeViewButton;
@property (strong) IBOutlet NSButton *durationTimeViewButton;

@property (strong) IBOutlet NSButton *repeatIntervalButton;
@property (strong) IBOutlet NSButton *repeatIntervalStartButton;
@property (strong) IBOutlet NSButton *repeatIntervalEndButton;

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
- (IBAction)changeVideoResizeButton:(id)sender;

- (IBAction)seekBarAction:(id)sender;
- (IBAction)volumeBarAction:(id)sender;

- (IBAction)repeatIntervalViewAction:(id)sender;
- (IBAction)repeatIntervalStartAction:(id)sender;
- (IBAction)repeatIntervalEndAction:(id)sender;

@end

@implementation PlayerViewController

void *StateRepeatIntervalContext = &StateRepeatIntervalContext;
void *StateRateContext = &StateRateContext;


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setWantsLayer:YES];
    [self.view.layer backgroundColorRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    
    [_topView setWantsLayer:YES];
    [_topView.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    
    [_bottomView setWantsLayer:YES];
    [_bottomView.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    
    [_repeatIntervalView setWantsLayer:YES];
    [_repeatIntervalView setHidden:YES];
    
    [self setButtonTitle];
    _loadStateProgressIndicator.hidden = YES;
    
    [_seekBarSlider sendActionOn:NSLeftMouseDownMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask];
    [_volumeBarSlider sendActionOn:NSLeftMouseDownMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask];
    
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.durationTime];
    
    _seekBarSlider.floatValue = 0.0f;
    _volumeBarSlider.floatValue = 1.0f;

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
    
    [self addObserver:self forKeyPath:@"stateRepeatInterval" options:0 context:StateRepeatIntervalContext];
    [_playerController addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:StateRateContext];
}

- (void)removeNotifications:(id)playerController {
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if(context == StateRepeatIntervalContext) {
        if(_stateRepeatInterval == YES) {
            [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:21]];
            if(_repeatIntervalTimer == nil) {
                _repeatIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(onRepeatIntervalTime:) userInfo:nil  repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:_repeatIntervalTimer forMode:NSRunLoopCommonModes];
            }
            
        } else {
            [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor redColor] font:[NSFont fontWithName:@"Feather" size:21]];
            if([_repeatIntervalTimer isValid]) {
                [_repeatIntervalTimer invalidate];
                _repeatIntervalTimer = nil;
            }
        } 
        NSLog(@"change");
    } else if(context == StateRateContext) {
        if(change[NSKeyValueChangeNewKey] != change[NSKeyValueChangeOldKey]) {
            NSLog(@"Rate!");
        }
    }
    
}

- (void)onPlayerControllerPlaybackStateDidChangeNotification {
    if(_playerController.playbackState == PlaybackStatePlaying) {
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if(_showPlaybackTimer == nil) {
            _showPlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(onShowPlaybackTime:) userInfo:nil  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_showPlaybackTimer forMode:NSRunLoopCommonModes];
        }
    } else if(_playerController.playbackState == PlaybackStatePaused) {
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if([_showPlaybackTimer isValid]) {
            [_showPlaybackTimer invalidate];
            _showPlaybackTimer = nil;
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
        
        [self setAttributeButton:_repeatIntervalStartButton title:[NSString changeTimeFloatToNSString:0.0f] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
        [_repeatIntervalStartButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self setAttributeButton:_repeatIntervalEndButton title:[NSString changeTimeFloatToNSString:_playerController.durationTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
        [_repeatIntervalEndButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        _endTime = _playerController.durationTime;
        
        [_loadStateProgressIndicator stopAnimation:nil];
        _loadStateProgressIndicator.hidden = YES;

        [self setMute:_mute];
        
        _seekBarSlider.floatValue = 0.0f;
        _seekBarSlider.maxValue = _playerController.durationTime;
        _volumeBarSlider.maxValue = 1.0f;
        
        _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
        _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.durationTime];
        
        [_playerController setRate:1.0f];
        [self playOrPause];
    } else if(_playerController.loadState == LoadStateFailed) {
        [self setEnabledSubControllers:NO];
    }
}

- (void)onPlayerControllerPlaybackDidPlayToEndTimeNotification {
    if(_repeat == YES) {
        [_playerController setCurrentTime:0.0f];
        [_playerController play];
    }
    if(_stateRepeatInterval == YES) {
        [_playerController setCurrentTime:_startTime];
        [_playerController play];
    }
}

- (void)onShowPlaybackTime:(NSTimer*)timer {
    _seekBarSlider.floatValue = _playerController.currentTime;
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_playerController.durationTime];
}

- (void)onRepeatIntervalTime:(NSTimer*)timer {
    if(_startTime - 0.01f > _seekBarSlider.floatValue) {
        _playerController.currentTime = _startTime;
        _seekBarSlider.floatValue = _startTime;
    }
    if(_endTime < _seekBarSlider.floatValue) {
        _playerController.currentTime = _startTime;
        _seekBarSlider.floatValue = _startTime;
    }
    NSLog(@"start:%f, current:%f, end:%f", _startTime, _seekBarSlider.floatValue, _endTime);
}


#pragma mark Playback Controller (getter/setter)

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


#pragma mark API

- (void)setViewFrameScale:(float)scale {
    [self.view willRemoveSubview:_playerController];
    
    _playerController.autoresizingMask = NSViewNotSizable;
    
    [_playerController setFrameSize:NSMakeSize(_playerController.originalSize.width * scale, _playerController.originalSize.height * scale)];
    [_playerController setFrame:NSMakeRect((self.view.window.frame.size.width - _playerController.frame.size.width) * (1/2.),
                                           (self.view.window.frame.size.height - _playerController.frame.size.height) * (1/2.),
                                           _playerController.frame.size.width,
                                           _playerController.frame.size.height)];
    
    _playerController.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;

    NSLog(@"%f, %f", _playerController.frame.origin.x, _playerController.frame.origin.y);
}

- (void)loadMediaFile:(NSURL*)url {
    _playerController = [[PlayerController alloc]initWithMediaFileURL:url andRect:self.view.bounds];
    [self.view addSubview:_playerController];
    [self.view.window setContentSize:[_playerController originalSize]];

    [self setNotifications:_playerController];
    
    
}

- (void)stopMediaFile {
    [self removeNotifications:_playerController];
    [_playerController pause];
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
    [_playerController setRate:_playerController.rate + 0.1f];
    if(_playerController.rate > (_maxRate - 0.05f)) {
        _playerController.rate = _maxRate;
    }
}

- (void)restorePlaybackRate {
    [_playerController setRate:1.0f];
}

- (void)decreasePlaybackRate {
    [_playerController setRate:_playerController.rate - 0.1f];
    if(_playerController.rate < (_minRate + 0.05f)) {
        _playerController.rate = _minRate;
    }
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

- (void)changeVideoResize {
    static int scale;
    scale ++;
    scale = scale % 4;
    [self setViewFrameScale:(float)scale + 1.0f];
}

- (void)stepBackward {
    [_playerController setCurrentTime:_playerController.currentTime - 5.0f];
}

- (void)stepForward {
    [_playerController setCurrentTime:_playerController.currentTime + 5.0f];
}


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
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _playerController.rate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
}

- (IBAction)restorePlaybackRateAction:(id)sender {
    [self restorePlaybackRate];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _playerController.rate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
}

- (IBAction)decreasePlaybackRateAction:(id)sender {
    [self decreasePlaybackRate];
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _playerController.rate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
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

- (IBAction)changeVideoGravityAction:(id)sender {
    [self changeVideoGravity];
}

- (IBAction)changeVideoResizeButton:(id)sender {
    [self changeVideoResize];
}

- (IBAction)repeatIntervalViewAction:(id)sender {
    if(_repeatIntervalView.isHidden == YES){
        [_repeatIntervalView setHidden:NO];
    } else {
        [_repeatIntervalView setHidden:YES];
    }
}

- (IBAction)repeatIntervalStartAction:(id)sender {
    if(_startTime != 0.0f) {
        [_repeatIntervalStartButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self setStartTime:0.0f];
    } else {
        if(_seekBarSlider.floatValue == 0.0f) {
            return;
        }
        [_repeatIntervalStartButton.layer backgroundColorRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
        [self setStartTime:_seekBarSlider.floatValue];
    }
    [self setAttributeButton:_repeatIntervalStartButton title:[NSString changeTimeFloatToNSString:_startTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
}

- (IBAction)repeatIntervalEndAction:(id)sender {
    if(_endTime != _playerController.durationTime) {
        [_repeatIntervalEndButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self setEndTime:_playerController.durationTime];
    } else {
        if(_seekBarSlider.floatValue == _playerController.durationTime) {
            return;
        }
        [_repeatIntervalEndButton.layer backgroundColorRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
        [self setEndTime:_seekBarSlider.floatValue];
    }
    [self setAttributeButton:_repeatIntervalEndButton title:[NSString changeTimeFloatToNSString:_endTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
}

- (void)setStartTime:(float)startTime {
    _startTime = startTime;
    if(_startTime != 0.0f || _endTime != _playerController.durationTime) {
        [self setStateRepeatInterval:YES];
    } else {
        [self setStateRepeatInterval:NO];
    }
}
- (void)setEndTime:(float)endTime {
    _endTime = endTime;
    if(_startTime != 0.0f || _endTime != _playerController.durationTime) {
        [self setStateRepeatInterval:YES];
    } else {
        [self setStateRepeatInterval:NO];
    }
}

- (void)setStateRepeatInterval:(BOOL)stateRepeatInterval {
    _stateRepeatInterval = stateRepeatInterval;
}


#pragma mark Mouse event

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];

    static BOOL flag;
    if(flag == NO) {
        [_topView animator].hidden = YES;
        [_bottomView animator].hidden = YES;
        [_repeatIntervalView animator].hidden = YES;
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
    [self setAttributeButton:_changeVideoResizeButton title:@"" color:[NSColor blueColor] font:font];
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
