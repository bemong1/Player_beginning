
//  PlayerViewController.m
//  Player-0610
//
//  Created by kwk on 2016. 6. 10..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "RepeatIntervalController.h"

#import "CALayer+AddMethod.h"
#import "NSString+AddMethod.h"


@interface VideoPlayerViewController ()

@property (nonatomic) RepeatIntervalController *repeatIntervalController;

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

@implementation VideoPlayerViewController

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
    
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.durationTime];
    
    _seekBarSlider.floatValue = 0.0f;
    _volumeBarSlider.floatValue = 1.0f;
}

- (void)dealloc {
    NSLog(@"VideoPlayerViewController destroy!!");
}

- (void)dismissController:(id)sender {
    [super dismissController:sender];
    [self stopMediaFile];
}

- (void)setNotifications:(id)videoPlayerController {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerPlaybackStateDidChangeNotification) name:PlayerControllerPlaybackStateDidChangeNotification object:videoPlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerLoadStateDidChangeNotification) name:PlayerControllerLoadStateDidChangeNotification object:videoPlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerPlaybackDidPlayToEndTimeNotification) name:PlayerControllerPlaybackDidPlayToEndTimeNotification object:videoPlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerControllerRateDidPlayToEndTimeNotification) name:PlayerControllerRateDidChangeNotification object:videoPlayerController];
}

- (void)removeNotifications:(id)videoPlayerController {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onPlayerControllerPlaybackStateDidChangeNotification {
    if(_videoPlayerController.playbackState == PlaybackStatePlaying) {
        [_loadStateProgressIndicator stopAnimation:nil];
        _loadStateProgressIndicator.hidden = YES;
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if(_showPlaybackTimer == nil) {
            _showPlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:(0.3) target:self selector:@selector(onShowPlaybackTime:) userInfo:nil  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_showPlaybackTimer forMode:NSRunLoopCommonModes];
        }
    } else if(_videoPlayerController.playbackState == PlaybackStatePaused) {
        [self setAttributeButton:_playOrPauseButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
        
        if([_showPlaybackTimer isValid]) {
            [_showPlaybackTimer invalidate];
            _showPlaybackTimer = nil;
        }
    } else if(_videoPlayerController.playbackState == PlaybackStateBuffering) {
        _loadStateProgressIndicator.hidden = NO;
        [_loadStateProgressIndicator startAnimation:nil];
    } else if(_videoPlayerController.playbackState == PlaybackStatePlayable) {
        [_loadStateProgressIndicator startAnimation:nil];
        _loadStateProgressIndicator.hidden = YES;
    }
}

- (void)onPlayerControllerLoadStateDidChangeNotification {
    if(_videoPlayerController.loadState == LoadStateLoading) {
        [self setEnabledSubControllers:NO];
        
        _loadStateProgressIndicator.hidden = NO;
        [_loadStateProgressIndicator startAnimation:nil];
    } else if(_videoPlayerController.loadState == LoadStateLoaded) {
        [self setEnabledSubControllers:YES];
        
        [self.view.window setContentSize:[_videoPlayerController originalSize]];
        
        
        _repeatIntervalController = [[RepeatIntervalController alloc]initWithDurationTime:_videoPlayerController.durationTime];
        [self setAttributeButton:_repeatIntervalStartButton title:[NSString changeTimeFloatToNSString:0.0f] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
        [_repeatIntervalStartButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        [self setAttributeButton:_repeatIntervalEndButton title:[NSString changeTimeFloatToNSString:_videoPlayerController.durationTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
        [_repeatIntervalEndButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        
        
        [_loadStateProgressIndicator stopAnimation:nil];
        _loadStateProgressIndicator.hidden = YES;
        
        _seekBarSlider.floatValue = 0.0f;
        _seekBarSlider.maxValue = _videoPlayerController.durationTime;
        _volumeBarSlider.maxValue = 1.0f;
        
        _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.currentTime];
        _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.durationTime];
        

    } else if(_videoPlayerController.loadState == LoadStateFailed) {
        [self setEnabledSubControllers:NO];
        
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Cannot Open"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

- (void)onPlayerControllerPlaybackDidPlayToEndTimeNotification {
    [_videoPlayerController pause];
    
    if(_videoPlayerController.repeat == YES) {
        [_videoPlayerController setCurrentTime:0.0f];
        [_videoPlayerController play];
    }
}

- (void)onPlayerControllerRateDidPlayToEndTimeNotification {
    [self setAttributeButton:_restorePlaybackRateButton title:[NSString stringWithFormat:@"%.1fx", _videoPlayerController.rate] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:23]];
    NSLog(@"Rate!");
}

- (void)onShowPlaybackTime:(NSTimer*)timer {
    _seekBarSlider.floatValue = _videoPlayerController.currentTime;
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.currentTime];
    _durationTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.durationTime];
    
    if(_repeatIntervalController.stateRepeatInterval == YES) {
        if([_repeatIntervalController isCurrentTimeBetweenStartTimeAndEndTime:_videoPlayerController.currentTime] == NO) {
            _videoPlayerController.currentTime = _repeatIntervalController.startTime;
        }
    }
}

- (void)loadMediaFile:(NSURL*)url {
    _videoPlayerController = [[VideoPlayerController alloc]initWithMediaFileURL:url andRect:self.view.bounds];
    [self.view addSubview:_videoPlayerController];
    
    [self setNotifications:_videoPlayerController];
}

- (void)stopMediaFile {
    [_videoPlayerController pause];
    [self removeNotifications:_videoPlayerController];
    [_videoPlayerController invalidateTimer];
    
    [_videoPlayerController removeFromSuperviewWithoutNeedingDisplay];
    _videoPlayerController = nil;
    
    [self removePlayerViewController];
}

- (void)removePlayerViewController {
    if(_delegate) {
        if([_delegate respondsToSelector:@selector(removePlayerViewController)]) {
            [_delegate removePlayerViewController];
        }
    }    
}


#pragma mark Playback Controller Button

- (IBAction)playOrPauseAction:(id)sender {
    [_videoPlayerController playOrPause];
}

- (IBAction)stopAction:(id)sender {
    [self stopMediaFile];
    [self.view setHidden:YES];
}

- (IBAction)increasePlaybackRateAction:(id)sender {
    [_videoPlayerController increasePlaybackRate];
}

- (IBAction)restorePlaybackRateAction:(id)sender {
    [_videoPlayerController restorePlaybackRate];
}

- (IBAction)decreasePlaybackRateAction:(id)sender {
    [_videoPlayerController decreasePlaybackRate];
}

- (IBAction)stepForwardAction:(id)sender {
    [_videoPlayerController stepForward];
}

- (IBAction)stepBackwardAction:(id)sender {
    [_videoPlayerController stepBackward];
}

- (IBAction)seekBarAction:(id)sender {
    _videoPlayerController.currentTime = _seekBarSlider.floatValue;
    _currentTimeViewButton.title = [NSString changeTimeFloatToNSString:_videoPlayerController.currentTime];
}

- (IBAction)volumeBarAction:(id)sender {
    [_videoPlayerController setCurrentVolume:_volumeBarSlider.floatValue];
    
    if(_videoPlayerController.currentVolume == 0.0f) {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
    } else {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
    }
}

- (IBAction)toggleRepeatModeAction:(id)sender {
    if(_videoPlayerController.repeat == NO) {
        [self setAttributeButton:_toggleRepeatModeButton  title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
    } else {
        [self setAttributeButton:_toggleRepeatModeButton  title:@"" color:[NSColor redColor]  font:[NSFont fontWithName:@"Feather" size:25]];
    }
    [_videoPlayerController setRepeat:!_videoPlayerController.repeat];
}

- (IBAction)toggleShuffleModeAction:(id)sender {
    if(_videoPlayerController.shuffle == NO) {
        [self setAttributeButton:_toggleShuffleModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:25]];
    } else {
        [self setAttributeButton:_toggleShuffleModeButton title:@"" color:[NSColor redColor]  font:[NSFont fontWithName:@"Feather" size:25]];
    }
    [_videoPlayerController setShuffle:!_videoPlayerController.shuffle];
}

- (IBAction)toggleMuteModeAction:(id)sender {
    if(_videoPlayerController.mute == NO) {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
        _volumeBarSlider.floatValue = 0.0f;
    } else {
        [self setAttributeButton:_toggleMuteModeButton title:@"" color:[NSColor blueColor] font:[NSFont fontWithName:@"Pe-icon-7-stroke" size:30]];
        _volumeBarSlider.floatValue = _videoPlayerController.currentVolume;
    }
    [_videoPlayerController setMute:!_videoPlayerController.mute];
}

- (IBAction)changeVideoGravityAction:(id)sender {
    [_videoPlayerController changeVideoGravity];
}

- (IBAction)changeVideoResizeButton:(id)sender {
    static int scale;
    scale ++;
    scale = scale % 4;
    [_videoPlayerController changeVideoResize:(float)scale + 1.0f];
}

- (IBAction)repeatIntervalViewAction:(id)sender {
    if(_repeatIntervalView.isHidden == YES){
        [_repeatIntervalView setHidden:NO];
    } else {
        [_repeatIntervalView setHidden:YES];
    }
}

- (IBAction)repeatIntervalStartAction:(id)sender {
    [_repeatIntervalController setStartTime:_videoPlayerController.currentTime];
    [self setAttributeButton:_repeatIntervalStartButton title:[NSString changeTimeFloatToNSString:_repeatIntervalController.startTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
    
    if(_repeatIntervalController.isStartTime == YES) {
        [_repeatIntervalStartButton.layer backgroundColorRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
    } else {
        [_repeatIntervalStartButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    }
    
    if(_repeatIntervalController.stateRepeatInterval == YES) {
        [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:21]];
    } else {
        [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor redColor] font:[NSFont fontWithName:@"Feather" size:21]];
    }
}

- (IBAction)repeatIntervalEndAction:(id)sender {
    [_repeatIntervalController setEndTime:_videoPlayerController.currentTime];
    [self setAttributeButton:_repeatIntervalEndButton title:[NSString changeTimeFloatToNSString:_repeatIntervalController.endTime] color:[NSColor blackColor] font:[NSFont fontWithName:@"Feather" size:25]];
    
    if(_repeatIntervalController.isEndTime == YES) {
        [_repeatIntervalEndButton.layer backgroundColorRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
    } else {
        [_repeatIntervalEndButton.layer backgroundColorRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
    }
    
    if(_repeatIntervalController.stateRepeatInterval == YES) {
        [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor blueColor] font:[NSFont fontWithName:@"Feather" size:21]];
    } else {
        [self setAttributeButton:_repeatIntervalButton title:[NSString stringWithFormat:@"A⇄B"] color:[NSColor redColor] font:[NSFont fontWithName:@"Feather" size:21]];
    }
    
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
