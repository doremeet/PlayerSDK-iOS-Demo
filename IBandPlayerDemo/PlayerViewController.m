//
//  ViewController.m
//  IBand.live
//
//  Created by Yogev Barber on 15/08/2017.
//  Copyright © 2017 Yogev Barber. All rights reserved.
//

#import <IBandPlayerSDK/IBandPlayerSDK.h>
#import "PlayerViewController.h"
#import "Entity.h"
#import "Masonry.h"
#import "DGActivityIndicatorView.h"
#import "UIColor+Hex.h"
#import "YBPlayerSlider.h"
#import "QualityCell.h"

#define STREAM_ID @"5994219bbc454f6edf961315"

@interface PlayerViewController () <IBandPlayerDelegate, IBandStreamDelegate, YBSliderDelegate, QualityCellDelegate>
@property (nonatomic, strong) IBandSDK *ibandSDK;
@property (nonatomic, strong) IBandPlayer *player;
@property (nonatomic, strong) IBandStream *stream;
@property (nonatomic, strong) IBandPlayerView *playerView;
@property (nonatomic, assign) NSInteger currentStreamIndex;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
- (IBAction)btnSettingsPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *liveIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnVr;
- (IBAction)btnVrPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIStackView *qualitiesStackViewWrapper;
@property (weak, nonatomic) IBOutlet UIStackView *qualitiesStackView;

@property (nonatomic, strong) UIViewController *cameraNotAvailable;
@property (nonatomic, strong) DGActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
- (IBAction)playPausePressed:(UIButton *)sender;
@property (nonatomic, strong) NSTimer* updateSliderTimer;
@property (weak, nonatomic) IBOutlet YBSlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentPosition;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (nonatomic, strong) NSArray<IBandPlayerVariant> *variants;
@property (nonatomic, strong) NSTimer *angleTimer;
@property (weak, nonatomic) IBOutlet UIView *angleView;
@property (weak, nonatomic) IBOutlet UIView *angleCenterView;
@property (weak, nonatomic) IBOutlet UIImageView *anglePointer;
@property (weak, nonatomic) IBOutlet UIView *angleViewRotation;
@property (nonatomic, assign) BOOL isMenuOpen;
@property (nonatomic, strong) NSTimer *menuTimer;
@property (weak, nonatomic) IBOutlet UIButton *btnScale;
- (IBAction)btnScalePressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *iconLogo;
@property (weak, nonatomic) IBOutlet UIView *shadowMenuView;
@property (nonatomic, assign) BOOL forcePause;
@property (nonatomic, assign) BOOL isScrubbing;
@end

@implementation PlayerViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc{
    [self stopTimer];
    [self stopMenuTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.ibandSDK = [[IBandSDK alloc] init];

    IBandStream *stream = [self.ibandSDK createStream:STREAM_ID];

    stream.delegate = self;
    self.stream = stream;
    self.currentStreamIndex = 0;
    
    [self setupPlayer];
    [self setupView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTimer];
    [self stopMenuTimer];
    [self.stream releaseStream];
    [self.player releasePlayer];
    self.player = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)setupView{
    self.slider.delegate = self;
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [self.view addGestureRecognizer:tapOnScreen];
    
    [self setupCameraNotAvailable];
    [self setupGradiantShadowView];
    [self setupActivityIndecator];
    [self setup360AnglePointer];
    [self closeMenu];
}

-(void)setupCameraNotAvailable{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.cameraNotAvailable = [storyBoard instantiateViewControllerWithIdentifier:@"cameraNotAvailable"];
    [self.view insertSubview:self.cameraNotAvailable.view atIndex:1];
    [self.cameraNotAvailable.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.cameraNotAvailable.view.hidden = true;
}

-(void)setupActivityIndecator{
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallPulseSync tintColor:[UIColor colorFromHexCode:@"50E3C2"] size:40.0f];
    
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    [self startLoadingAnimation];
}

-(void)setup360AnglePointer{
    self.angleView.layer.borderWidth = 2;
    self.angleView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.angleView.layer.cornerRadius = self.angleView.frame.size.height / 2;
    self.angleView.layer.masksToBounds = true;
    UITapGestureRecognizer *tapToCenter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnCenterPressed:)];
    [self.angleView addGestureRecognizer:tapToCenter];
    
    self.angleView.hidden = true;
    self.angleCenterView.hidden = true;
}

-(void)setupGradiantShadowView{
    // Create the colors
    UIColor *topColor = [UIColor clearColor];
    UIColor *bottomColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    // Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = self.shadowMenuView.bounds;
    
    //Add gradient to view
    [self.shadowMenuView.layer.sublayers[0] removeFromSuperlayer];
    [self.shadowMenuView.layer insertSublayer:theViewGradient atIndex:0];
    
    self.shadowMenuView.hidden = true;
}

-(void)setupPlayer{
    self.player = [self.ibandSDK createPlayer];
    self.player.delegate = self;
    self.playerView = [[IBandPlayerView alloc] init];
    [self setupPlayerView];
    [self.player setView:self.playerView];
    [self.player setStream:self.stream];
}

-(void)setupPlayerView{
    [self.view insertSubview:self.playerView.view atIndex:0];
    [self.playerView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)updateView{
    [self showMenu];
}

#pragma mark - IBandPlayerDelegate

-(void)onPlayerStateChanged:(IBandPlayer *)player state:(IBandPlayerState)state oldState:(IBandPlayerState)oldState{
    switch (state) {
        case IBandPlayerStateReady:
            [self stopLoadingAnimation];
            self.lblDuration.text = [self getTimeInForamt:[self.player getDuration]];
            [self startTimer];
            break;
        case IBandPlayerStateBuffer:
        case IBandPlayerStateUninitialize:
            [self startLoadingAnimation];
            break;
        case IBandPlayerStateError:
        case IBandPlayerStateInitialize:
            break;
    }
}

-(void) onPlayerPlayableChanged:(IBandPlayer*) player isPlayable:(BOOL) isPlayable{
    if (!self.forcePause && [self.player getState]) {
        self.btnPlayPause.selected = isPlayable;
    }
}

-(void) onPlayerReachEnd:(IBandPlayer*) player{
    self.btnPlayPause.selected = false;
    [self.player setPlayWhenReady:false];
    [self stopTimer];
}

-(void) onPlayerVariantsCreated:(IBandPlayer*) player variants:(NSArray<IBandPlayerVariant>*) variants{
    self.variants = variants;
    [self setupQualities];
}

-(void) onPlayerCurrentVariantChanged:(IBandPlayer*)player variantIndex:(NSUInteger)variantIndex oldVariantIndex:(NSUInteger)oldVariantIndex{
    
    [self setQualitiesUnactive];
    
    NSArray<QualityCell*> *cells = (NSArray<QualityCell *> *)[[self.qualitiesStackView.subviews reverseObjectEnumerator] allObjects];
    if (variantIndex <= cells.count) {
        QualityCell *cell = cells[variantIndex + 1];
        [cell setActive:true];
    }
}

-(void) onPlayerError:(IBandPlayer*) player error:(IBandError*) error{
    [self showErrorMessage:error];
}

-(void)onPlayerCurrentPositionUpdate:(IBandPlayer *)player currentPosition:(NSTimeInterval)currentPosition{
    if (self.isScrubbing) {
        return;
    }
    
    [self.slider setCurrentPosition:currentPosition/[self.player getDuration]];
    self.lblCurrentPosition.text = [self getTimeInForamt:currentPosition];
}

-(void)onPlayerBufferPositionUpdate:(IBandPlayer *)player bufferPosition:(NSTimeInterval)bufferPosition{
    [self.slider setBufferPosition:bufferPosition / [self.player getDuration]];
}

#pragma mark - IBandStreamDelegate
-(void) onStreamStateChanged:(IBandStream*)stream state:(IBandStreamState)state oldState:(IBandStreamState)oldState{
    [self updateView];
    if ([[stream getId] isEqualToString:[self.stream getId]] &&  state == IBandStreamStateClosed) {
        [self stopLoadingAnimation];
        self.btnPlayPause.hidden = true;
    }
}
-(void) onStreamError:(IBandStream*)stream error:(IBandError*)error{
    [self showErrorMessage:error];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    if (self.btnVr.selected) {
        self.btnVr.selected = !self.btnVr.selected;
        [self switchVrMode];
        return;
    }
    [self.player setPlayWhenReady:false];
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)btnSettingsPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.isSelected) {
        self.qualitiesStackViewWrapper.hidden = false;
    }else{
        self.qualitiesStackViewWrapper.hidden = true;
    }
}
- (IBAction)btnVrPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self switchVrMode];
}

-(void)switchVrMode{
    [self closeMenu];
    if ([self.stream getStructure] == IBandStreamStructureEquirectangular) {
        [self.playerView setVRMode:self.btnVr.selected];
    }

    if (self.btnVr.selected) {
        self.angleCenterView.hidden = true;
        self.angleView.hidden = true;
        self.iconLogo.hidden = true;
        self.backButton.hidden = false;
    }else{
        self.angleCenterView.hidden = false;
        self.angleView.hidden = false;
        self.iconLogo.hidden = false;
        self.backButton.hidden = true;
    }
}

- (void)btnCenterPressed:(UIGestureRecognizer *)sender {
    [self.playerView resetDisplayPosition];
}
- (IBAction)playPausePressed:(UIButton *)sender {
    
    if (fabs([self.player getDuration] - [self.player getCurrentPosition]) < 0.200 && !sender.selected) {
        if ([self.player isPlayable]) {
            [self.player seekTo:0];
        }
    }
    sender.selected = !sender.selected;
    if (!sender.selected) {
        self.forcePause = true;
    }else{
         self.forcePause = false;
    }
    [self showMenu];
    [self.player setPlayWhenReady:sender.selected];
}

#pragma mark - PlayerSliderViewDelegate
-(void)sliderDragBegin:(YBSlider *)slider value:(float)value{
    self.isScrubbing = true;
}

-(void)sliderDragMove:(YBSlider *)slider value:(float)value{
    self.lblCurrentPosition.text = [self getTimeInForamt:value * [self.player getDuration]];
}

-(void)sliderDragEnd:(YBSlider *)slider value:(float)value{
    self.isScrubbing = false;
    if ([self.player isPlayable]) {
        [self.player seekTo:value*[self.player getDuration]];
    }
    
}

-(void)sliderValueChange:(YBSlider*)slider value:(float)value{
    
}

-(void)sliderValueWillChange:(YBSlider*)slider{
    
}

#pragma mark - Slider
- (void) updateSlider:(NSTimer *)timer
{
    [self.slider setCurrentPosition:[self.player getCurrentPosition]/[self.player getDuration]];
    self.lblCurrentPosition.text = [self getTimeInForamt:[self.player getCurrentPosition]];
    [self.slider setBufferPosition:[self.player getBufferPosition] / [self.player getDuration]];
}

- (NSString*)getTimeInForamt:(NSTimeInterval) value{
    if(value <= 0){
        return @"00:00";
    }
    int time = (int)floor(value);
    int minutes = (int)(floor(time / 60));
    int seconds = (int)(round(time - floor(time / 60) * 60));
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - Angle marker
-(void) startTimer{
    [self stopTimer];
    if ([self.stream getStructure] == IBandStreamStructureEquirectangular) {
        self.angleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getPanoramaPositionAngle) userInfo:nil repeats:true];
    }
}

-(void) stopTimer{
    [self.angleTimer invalidate];
}


#pragma mark - qualities
-(void)setupQualities{
    for (UIView *view in self.qualitiesStackView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray<IBandPlayerVariant> *variants = (NSArray<IBandPlayerVariant> *)[[self.variants reverseObjectEnumerator] allObjects];
    for (id<IBandPlayerVariant> variant in variants) {
        QualityCell *quality = [[[NSBundle mainBundle] loadNibNamed:@"QualityCell" owner:self options:nil] objectAtIndex:0];
        quality.delegate = self;
        [quality setVariant:variant];
        [self.qualitiesStackView addArrangedSubview:quality];
    }
    
    QualityCell *autoQuality = [[[NSBundle mainBundle] loadNibNamed:@"QualityCell" owner:self options:nil] objectAtIndex:0];
    autoQuality.delegate = self;
    [autoQuality setVariant:nil];
    [autoQuality setSelected:true];
    [self.qualitiesStackView addArrangedSubview:autoQuality];
    
}

-(void)setQualitiesUnactive{
    for (QualityCell *cell in self.qualitiesStackView.subviews) {
        [cell setActive:false];
    }
}

-(void)setQualitiesUnselected{
    for (QualityCell *cell in self.qualitiesStackView.subviews) {
        [cell setSelected:false];
    }
}
#pragma mark - QualityCellDelegate
-(void)qualitySelected:(QualityCell*)quality variant:(id<IBandPlayerVariant>)variant{
    NSLog(@"%dp", (int)[variant getHeight]);
    
    [self setQualitiesUnselected];
    
    if (!variant) {
        [self.player setAutoVariant];
        return;
    }
    
    NSArray<QualityCell*> *cells = (NSArray<QualityCell *> *)[[self.qualitiesStackView.subviews reverseObjectEnumerator] allObjects];
    NSInteger variantIndex = [cells indexOfObject:quality] - 1;
    [self.player setCurrentVariant:variantIndex];    
}

#pragma mark - 360 view
-(void)getPanoramaPositionAngle{
    [self.angleViewRotation setTransform:CGAffineTransformMakeRotation([self.playerView getPanoramaPositionAngle] + M_PI)];
//    NSLog(@"%f", [self.playerView getPanoramaPositionAngle]);
}

#pragma mark - menu

-(void)startMenuTimer{
    [self stopMenuTimer];
    self.menuTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(closeMenu) userInfo:nil repeats:false];
}

-(void)stopMenuTimer{
    [self.menuTimer invalidate];
}

-(void)showMenu{
    
    if (self.btnVr.isSelected) {
        return;
    }
    
    self.isMenuOpen = true;
    
    if ([self.stream getStructure] == IBandStreamStructureEquirectangular) {
        self.btnVr.hidden = false;
        self.angleView.hidden = false;
        self.angleCenterView.hidden = false;
        self.btnScale.hidden = true;
    }else{
        self.btnVr.hidden = true;
        self.angleView.hidden = true;
        self.angleCenterView.hidden = true;
        self.btnScale.hidden = false;
    }
    
    if ([self.stream getType] == IBandStreamTypeLive) {
        self.liveIcon.hidden = false;
        self.lblDuration.hidden = true;
        self.lblCurrentPosition.hidden = true;
        self.slider.hidden = true;
    }else{
        self.liveIcon.hidden = true;
        self.lblDuration.hidden = false;
        self.lblCurrentPosition.hidden = false;
        self.slider.hidden = false;
    }
    
    if ([self.stream getState] == IBandStreamStateClosed) {
        [self stopLoadingAnimation];
        self.cameraNotAvailable.view.hidden = false;
        self.liveIcon.hidden = true;
        self.lblDuration.hidden = true;
        self.lblCurrentPosition.hidden = true;
        self.slider.hidden = true;
        self.btnPlayPause.hidden = true;
        self.btnSettings.hidden = true;
        self.btnVr.hidden = true;
        self.angleView.hidden = true;
        self.angleCenterView.hidden = true;
        self.btnScale.hidden = true;
    }else{
        self.cameraNotAvailable.view.hidden = true;
        self.btnSettings.hidden = false;
        
        if ([self.player getState] != IBandPlayerStateBuffer && [self.player getState] != IBandPlayerStateInitialize) {
            self.btnPlayPause.hidden = false;
        }else{
            self.btnPlayPause.hidden = true;
        }
    }
    
    self.qualitiesStackViewWrapper.hidden = true;
    self.angleCenterView.alpha = 1.0;
    self.angleView.alpha = 1.0;
    
    self.shadowMenuView.hidden = false;
    self.backButton.hidden = true;
    [self startMenuTimer];
}

-(void)closeMenu{
    
    if (self.forcePause) {
        return;
    }
    
    self.isMenuOpen = false;
    self.slider.hidden = true;
    self.lblDuration.hidden = true;
    self.lblCurrentPosition.hidden = true;
    self.btnSettings.hidden = true;
    self.qualitiesStackViewWrapper.hidden = true;
    self.backButton.hidden = true;
    self.btnPlayPause.hidden = true;
    self.btnVr.hidden = true;
    self.angleCenterView.alpha = 0.5;
    self.angleView.alpha = 0.5;
    self.btnScale.hidden = true;
    self.liveIcon.hidden = true;
    self.shadowMenuView.hidden = true;
    [self stopMenuTimer];
}

-(void)toggleMenu{
    if (self.isMenuOpen) {
        [self closeMenu];
    }else{
        [self showMenu];
    }
}
- (IBAction)btnScalePressed:(UIButton *)sender {
    [self.playerView setVideoScale:([self.playerView getVideoScale] + 1 ) % 3];
}

-(void)showErrorMessage:(IBandError*)error{
    [self stopLoadingAnimation];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:[error getErrorMessage]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action) {
                                    
                                }];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:true completion:nil];
}

-(void)startLoadingAnimation{
    [self.activityIndicatorView startAnimating];
    self.btnPlayPause.hidden = true;
}

-(void)stopLoadingAnimation{
    [self.activityIndicatorView stopAnimating];
    if (self.isMenuOpen) {
        self.btnPlayPause.hidden = false;
    }
}
@end
