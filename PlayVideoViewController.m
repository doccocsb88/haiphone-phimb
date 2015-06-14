//
//  PlayVideoViewController.m
//  SlideMenu
//
//  Created by Apple on 5/30/15.
//  Copyright (c) 2015 Aryan Ghassemi. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "FBLoginDialogViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TabInfoView.h"
#import "TabRelateView.h"
#import "TabOverview.h"
#import "FilmInfoDetails.h"
#import "ColorSchemeHelper.h"
#import "Genre.h"
#import "RelateFilmViewController.h"
#import "EmployeeDbUtil.h"
#import "UserDataFilm.h"
#import "MONActivityIndicatorView.h"
#define BUTTON_PLAY_SIZE 40
#define NAVBAR_HEIGHT 64
NSString *const PlayMovieTabpped = @"PlayMovieTabpped";

const NSString *API_URL_WHATCH_FILM = @"http://www.phimb.net/json-api/movies.php?v=538c7f456122cca4d87bf6de9dd958b5%2F";

@interface PlayVideoViewController () <PlayMovieDelegate,UIGestureRecognizerDelegate,RelateFilmViewControllerDelegate,MONActivityIndicatorViewDelegate>
{
    NSArray *genraData;
    CGFloat viewWidth;
    CGFloat viewHeight;
    CGFloat marginTop;
    CGFloat infoMarginTop;
    CGFloat btnTabWidth;
    NSMutableData *receivedData;
    CGFloat keyboardHeight;
    CGFloat playerHeight;
    CGFloat movieRatio;
    BOOL allowRotation;
}
@property (nonatomic ,strong)     NSURL *movieURL;
//= [NSURL URLWithString:@"http://techslides.com/demos/sample-videos/small.mp4"];
@property (strong,nonatomic) FilmInfoDetails *infoDetail;
@property (nonatomic,assign) NSInteger mpCurrentState;
@property (strong, nonatomic)  UIView *ctrStyleView;
@property (strong,nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) MPMoviePlayerViewController *moviePlayerViewController;
@property (strong, nonatomic) MONActivityIndicatorView *movieIndicator;
@property (strong, nonatomic) TabInfoView *infoView;
@property (strong, nonatomic) TabRelateView *relateView;
@property (strong, nonatomic) TabOverview *overviewView;
@property (strong, nonatomic) TabCommentView *commentView;
@property (strong, nonatomic) UIView *tabViewHightLight;
@property (strong, nonatomic) UIView *bgHeadrView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic)  UIView *tabviewPanel;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic,assign) BOOL showPanel;
@property (nonatomic,assign) BOOL originSize;
@property (nonatomic,strong)EmployeeDbUtil *dbManager;
//@property (nonatomic, assign) nsin

@end

@implementation PlayVideoViewController
//@synthesize playvideoDelegate;
@synthesize filmInfo;
@synthesize movieURL,rightButton,originSize;

//@synthesize btnTabInfo;
//@synthesize btnTabRelative;
-(id)init{
    self = [super init];
    if(self){
        self.view.backgroundColor = [UIColor clearColor];
        self.mpCurrentState = MPMoviePlaybackStateStopped;
    }
    return self;
    
}
-(id)initWithInfo:(SearchResultItem *)info{
    self = [super init];
    if(self){

        self.view.backgroundColor = [UIColor clearColor];
        self.mpCurrentState = MPMoviePlaybackStateStopped;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    originSize = YES;
    self.dbManager = [[EmployeeDbUtil alloc] init];
    [self.dbManager initDatabase];
    [self setupGestures];
   
    NSLog(@"marginTop %f",marginTop);
    // Do any additional setup after loading the view.
  
//    [self callWebService];
    [self initViews];
}
-(void) initParams{
    _currentTab = TAB_INFO;
    viewHeight = self.view.frame.size.height;
    viewWidth  = self.view.frame.size.width;
    marginTop = 64;
    movieRatio = viewWidth/(viewHeight/4);
    infoMarginTop = marginTop + viewHeight/4;
    btnTabWidth = viewWidth/3;
    genraData = @[
                         [Genre itemWithTitle:@"Hành Động" withKey:@"hanh-dong"],
                         [Genre itemWithTitle:@"Phiêu Lưu" withKey:@"phieu-luu"],
                         [Genre itemWithTitle:@"Tình Cảm" withKey:@"tinh-cam"],
                         [Genre itemWithTitle:@"Tâm Lý" withKey:@"tam-ly"],
                         [Genre itemWithTitle:@"Võ Thuật" withKey:@"vo-thuat"],
                         [Genre itemWithTitle:@"Cổ trang" withKey:@"co-trang"],
                         [Genre itemWithTitle:@"Hài Hước" withKey:@"hai-huoc"],
                         [Genre itemWithTitle:@"Ca Nhạc" withKey:@"ca-nhac"],
                         [Genre itemWithTitle:@"Hài Kịch" withKey:@"hai-kich"],
                         [Genre itemWithTitle:@"Hình Sự" withKey:@"hinh-su"],
                         [Genre itemWithTitle:@"Chiến Tranh " withKey:@"chien-tranh"]];

}
-(void)initViews{
    [self initParams];
    [self styleNavBar];
    [self initMoviePlayerView];
    [self initMovieIndicator];
    
    [self initViewInfo];
    [self initTabView];

    [self initPreviewImage];
    //[self createControllStyleView];
    
    [self initPlayFilmController];
    [self initNotification];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [SlideNavigationController sharedInstance].lastControlelr = 2;

}
- (void)styleNavBar {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    

    _btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 45, 44)];
    [_btnCancel setTitle:@"Back" forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:16.f];
//    [_btnCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0,10)];
    [_btnCancel addTarget:self action:@selector(pressCancel:) forControlEvents:UIControlEventTouchUpInside];

    _bgHeadrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 64) ];
    [_bgHeadrView addSubview:_btnCancel];
    _bgHeadrView.backgroundColor = [ColorSchemeHelper     sharedNationHeaderColor];
    [self.view addSubview:_bgHeadrView];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, viewWidth-100, 44)];
    title.text = @"Movie Information";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font= [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    [_bgHeadrView addSubview:title];
//    [header addSubview:rightButton];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SlideNavigationController Methods -

//- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
//{
//    return NO;
//}
//
//- (BOOL)slideNavigationControllerShouldDisplayRightMenu
//{
//    return YES;
//}
//
#pragma Reister NOtification
-(void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
}

#pragma mark - InitView
-(void)initMovieIndicator{

    _movieIndicator= [[MONActivityIndicatorView alloc] init];
  
    _movieIndicator.delegate = self;
    _movieIndicator.numberOfCircles = 3;
    _movieIndicator.radius = 10;
    _movieIndicator.internalSpacing = 3;
    CGSize size = [_movieIndicator intrinsicContentSize];
    _movieIndicator.frame = CGRectMake((viewWidth-size.width)/2, marginTop + (playerHeight- size.height)/2, size.width, size.height);
    [_movieIndicator startAnimating];
    
    [self.view addSubview:_movieIndicator];
//    [self placeAtTheCenterWithView:_movieIndicator];
    
//    [NSTimer scheduledTimerWithTimeInterval:7 target:indicatorView selector:@selector(stopAnimating) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:9 target:_movieIndicator selector:@selector(startAnimating) userInfo:nil repeats:NO];
}


#pragma mark -
#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
//    CGFloat red   = (arc4random() % 256)/255.0;
//    CGFloat green = (arc4random() % 256)/255.0;
//    CGFloat blue  = (arc4random() % 256)/255.0;
//    CGFloat alpha = 1.0f;
    //return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return [ColorSchemeHelper sharedNationHeaderColor];
}

-(void)initMoviePlayerView{

//        CGFloat movieRatio  = 192.f/ 100.f;
//        playerHeight = viewHeight/4;
    [self caculatePlayerHeight];
    _moviePlayerController = [[MPMoviePlayerController alloc] init];
    _moviePlayerController.view.frame = CGRectMake(0, 64, viewWidth, playerHeight);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addMovieControl:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification
                                               object:_moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:_moviePlayerController];
    [self.view addSubview:_moviePlayerController.view];
    _moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
    
    _moviePlayerController.controlStyle = MPMovieControlStyleEmbedded;
//        self.moviePlayerController.view.transform = CGAffineTransformConcat(self.moviePlayerController.view.transform, CGAffineTransformMakeRotation(M_PI_2));
//        [self.moviePlayerController.view setFrame:self.view.frame];
        [_moviePlayerController prepareToPlay];
//       [self createControllStyleView];
        _moviePlayerController.fullscreen = YES;
//        [_moviePlayerController play];
}
-(void)initPlayFilmController{
 self.moviePlayerViewController = [[MPMoviePlayerViewController alloc] init];
//    [self.moviePlayerViewController .moviePlayer setContentURL:[NSURL URLWithString:@"http://phimb.net/videoplayback/aHR0cHM6Ly9waWNhc2F3ZWIuZ29vZ2xlLmNvbS8xMDM1NDUwODQxNTU3MzYwODIwNjMvTWF5MjkyMDE1P2F1dGhrZXk9R3Yxc1JnQ00zaWo5MlIwT09GOFFFIzYxNTQyOTIyODQ2MzExMzExNTQ=.mp4"] ];
    self.moviePlayerViewController .moviePlayer.shouldAutoplay = NO;
    self.moviePlayerViewController .moviePlayer.controlStyle  = MPMovieControlStyleEmbedded;
//    [self.moviePlayerViewController .moviePlayer prepareToPlay];
    self.moviePlayerViewController .moviePlayer.fullscreen = YES;
//    self.moviePlayerViewController = vc;
    self.moviePlayerViewController.view.transform = CGAffineTransformConcat(self.moviePlayerViewController.view.transform, CGAffineTransformMakeRotation(M_PI_2));
//    UILabel *lbTest= [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    lbTest.text = @"abc";
//    lbTest.textColor = [UIColor redColor];
//    [self.moviePlayerViewController.view addSubview:lbTest];
//    [self.moviePlayerViewController.view addSubview:self.ctrStyleView];
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"]];
    backImg.frame =CGRectMake(0, 0,30  , 30);
    
    _btnBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [_btnBack addTarget:self action:@selector(pressCloseMoviePlayerView:) forControlEvents:UIControlEventTouchUpInside];
    [_btnBack addSubview:backImg];
    _btnBack.backgroundColor = [UIColor redColor];
    [_moviePlayerViewController.view addSubview:_btnBack ];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(pressCloseMoviePlayerView:)
//                                                 name:MPMoviePlayerWillExitFullscreenNotification
//                                               object:nil];

}
-(void)initTabView{
    UIFont *font  = [UIFont systemFontOfSize:13.f];

    _tabviewPanel = [[UIView alloc]initWithFrame:CGRectMake(0, infoMarginTop+viewHeight/4, viewWidth, 30)];
    _tabviewPanel.backgroundColor = [UIColor whiteColor];
    CGFloat tabMargin = (btnTabWidth-100)/2;
    _btnTabInfo = [[UIButton alloc] initWithFrame:CGRectMake(tabMargin, 0, 100, 30)];
    [_btnTabInfo setTag:1];
    [_btnTabInfo setTitle:@"Overview" forState:UIControlStateNormal];
    _btnTabInfo.titleLabel.font = font;
    [_btnTabInfo setTintColor:[UIColor blackColor]];

    //[_btnTabInfo setTitleColor:[ColorSchemeHelper sharedTabTextColor] forState:UIControlStateNormal];
    [_btnTabInfo addTarget:self action:@selector(pressInfoTab:) forControlEvents:UIControlEventTouchUpInside];
    //
    _btnTabRelative = [[UIButton alloc] initWithFrame:CGRectMake(btnTabWidth +tabMargin, 0, 100, 30)];
    [_btnTabRelative setTag:2];
    _btnTabRelative.titleLabel.font = font;
    [_btnTabRelative setTintColor:[UIColor blackColor]];

    [_btnTabRelative setTitle:@"Episodes" forState:UIControlStateNormal];
    _btnTabRelative.backgroundColor = [UIColor whiteColor];
//    _btnTabRelative.alpha = 0.5f;
    //[_btnTabRelative setTitleColor:[ColorSchemeHelper sharedTabTextColor] forState:UIControlStateNormal];
    [_btnTabRelative addTarget:self action:@selector(pressRelateTab:) forControlEvents:UIControlEventTouchUpInside];
    //btnTabComment
    _btnTabComment = [[UIButton alloc] initWithFrame:CGRectMake(btnTabWidth*2+tabMargin, 0, 100, 30) ];
    [_btnTabComment setTag:3];
    [_btnTabComment setTitle:@"Comments" forState:UIControlStateNormal];
    //[_btnTabComment setTitleColor:[ColorSchemeHelper sharedTabTextColor] forState:UIControlStateNormal];
    _btnTabComment.backgroundColor = [UIColor whiteColor];
    _btnTabComment.titleLabel.font = font;
    [_btnTabComment addTarget:self action:@selector(pressedTab:) forControlEvents:UIControlEventTouchUpInside];

//addToMainView
    [_btnTabInfo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnTabRelative setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnTabComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [_tabviewPanel addSubview:_btnTabInfo];
    [_tabviewPanel addSubview:_btnTabRelative];
    [_tabviewPanel addSubview:_btnTabComment];
    _tabViewHightLight = [[UIView alloc] initWithFrame:CGRectMake(btnTabWidth/4, 28, btnTabWidth/2, 2)];
    _tabViewHightLight.backgroundColor = [ColorSchemeHelper sharedMovieInfoTitleColor];
    [_tabviewPanel addSubview:_tabViewHightLight];
    [_tabviewPanel.layer setCornerRadius:0];
    [_tabviewPanel.layer setShadowColor:[UIColor blackColor].CGColor];
    [_tabviewPanel.layer setShadowOpacity:0.3];
    [_tabviewPanel.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.view addSubview:_tabviewPanel];
}
-(void)initPreviewImage{
    CGFloat preImgHeight=viewHeight/4;
    _previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,marginTop, viewWidth, preImgHeight)];
    _previewImage.contentMode = UIViewContentModeScaleToFill;
    _previewImage.image = [UIImage imageNamed:@""];
//    _previewImage.autoresizingMask = ( UIViewAutoresizingFlexibleBottomMargin
//                                      | UIViewAutoresizingFlexibleHeight
//                                      | UIViewAutoresizingFlexibleLeftMargin
//                                      | UIViewAutoresizingFlexibleRightMargin
//                                      | UIViewAutoresizingFlexibleTopMargin
//                                      | UIViewAutoresizingFlexibleWidth );
//    [self.view addSubview:_previewImage];
    //
    _btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - BUTTON_PLAY_SIZE/2, marginTop + preImgHeight/2 - BUTTON_PLAY_SIZE/2, BUTTON_PLAY_SIZE, BUTTON_PLAY_SIZE)];
    UIImageView *playImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"]];
    playImg.frame =CGRectMake(0, 0, BUTTON_PLAY_SIZE, BUTTON_PLAY_SIZE);
    [_btnPlay setUserInteractionEnabled:NO];
    [_btnPlay addSubview:playImg];
    [_btnPlay addTarget:self action:@selector(pressPlay:) forControlEvents:UIControlEventTouchUpInside];
    [_btnPlay setHidden:YES];
    [self.view addSubview:_btnPlay];
    //init backButton
  
}
-(void)initViewInfo{
//    UIView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"TabViewInfo" owner:self options:nil] lastObject];
//    containerView.frame = CGRectMake(0, 350, self.view.frame.size.width, self.view.frame.size.height - 350);
//    [self.view addSubview:containerView];
    
    _infoView= [[TabInfoView alloc] initWithFrame: CGRectMake(0, infoMarginTop, self.view.frame.size.width, viewHeight/4)];
    _infoView.backgroundColor = [UIColor whiteColor];
//    _infoView.thumbnail.image = filmInfo.thumbnail;
//    _infoView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_infoView];
    //initscroll
    CGFloat scrollH =viewHeight - infoMarginTop - (viewHeight/4+30);
//    infoMarginTop+viewHeight/4
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, infoMarginTop + viewHeight/4+30, viewWidth*3, scrollH)];
    _scrollView.contentSize = CGSizeMake(viewWidth*2, scrollH);
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:_scrollView];
    //
    _relateView =[[TabRelateView alloc] initWithFrame: CGRectMake(viewWidth, 0, viewWidth, scrollH-20)];
    _relateView.backgroundColor = [UIColor whiteColor];
//    [_relateView setHidden:YES];
    _relateView.playvideoDelegate = self;
    _overviewView = [[TabOverview alloc] initWithInfo:@"kjdfkjdk" descriotion:@"kkjdkfjdkjf" frame:CGRectMake(0, 0, viewWidth, scrollH-20)];
    _overviewView.backgroundColor = [UIColor whiteColor];
    _commentView = [[TabCommentView alloc] initWithFrameX:CGRectMake(viewWidth*2, 0, viewWidth, viewHeight - infoMarginTop -  (viewHeight/4+30)) ];
    _commentView.backgroundColor = [UIColor whiteColor];
    _commentView.webDelegate = self;
//    _commentView = [[TabCommentView alloc] initWithFrameX:CGRectMake(0, 0, viewWidth, viewHeight) ];
//
    [_commentView requestFilmComment:filmInfo._id];
//    _commentView.backgroundColor = [UIColor blueColor];
    //
    _commentView.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:_commentView];
    [_scrollView addSubview:_overviewView];
    [_scrollView addSubview:_relateView];

    
}
-(void)createControllStyleView{
    CGFloat ctrStyleWidth=viewWidth  - 60;
    self.ctrStyleView= [[UIView alloc] initWithFrame:CGRectMake(  30, playerHeight - 35, ctrStyleWidth, 30)];
    self.ctrStyleView.backgroundColor = [UIColor colorWithRed:0.4f green:0.55f blue:0.66f alpha:0.5f];
    [self.moviePlayerController.view addSubview:self.ctrStyleView];
    UIButton *btnFullScreen = [[UIButton alloc] initWithFrame:CGRectMake(ctrStyleWidth - 40, 0, 40, 30)];
    [btnFullScreen setTitle:@"Full" forState:UIControlStateNormal];
    [btnFullScreen addTarget:self action:@selector(pressedFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.ctrStyleView addSubview:btnFullScreen];
//    return nil;
    
}
-(void)pressedFullScreen:(id)button{
    self.moviePlayerController.fullscreen = YES;
    [self.view bringSubviewToFront:self.ctrStyleView];
}
-(void)setupGestures {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTabPanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [self.view addGestureRecognizer:panRecognizer];
}

-(void)prepareFilmData : (SearchResultItem *)item{
    filmInfo = item;
   // _previewImage.image = [UIImage imageNamed:@""];
    //
    [_infoView setInfoThumbnail:filmInfo.thumbnail];
    if(filmInfo.hasData==NO){
        NSString *url =@"";
        if(filmInfo.imglanscape &&  ![filmInfo.imglanscape isEqualToString:@""]){
            url = filmInfo.imglanscape;
        }else{
            url = filmInfo.img;
        }
        NSLog(@"filmThumbanilURL %@ -%@ - %@ %d",url,filmInfo.img,filmInfo.imglanscape,filmInfo._id);
        NSURL *imageURL = [NSURL URLWithString:url];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                _previewImage.image = [UIImage imageWithData:imageData];

                NSLog(@"previewImageHeight %f",_previewImage.frame.size.height);
            });
        });
    }else{
        _previewImage.image = filmInfo.thumbnail;
    }
    [self callWebService];
}
#pragma Mark - TouchNotification

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded %d",originSize);
    if (!originSize) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:touches forKey:@"touchesKey"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playmovieTouch" object:nil userInfo:userInfo];
        for (UITouch *aTouch in touches) {
            if (aTouch.tapCount >= 2) {
                // The view responds to the tap
                NSLog(@"multiTouch");
            }else{
                NSLog(@"singleTouch");
            }
        }
    }
}
#pragma mark - Action

-(void)moveTabPanel:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    CGPoint currentlocation = [sender locationInView:self.view];

    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
       // UIView *childView = nil;
        
        if(velocity.x > 0) {
//            if (!_showingRightPanel) {
//                childView = [self getLeftView];
//            }
        } else {
//            if (!_showingLeftPanel) {
//                childView = [self getRightView];
//            }
            
        }
        // make sure the view we're working with is front and center
        //[self.view sendSubviewToBack:childView];
        //[[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
             NSLog(@"gesture went right");
        } else {
             NSLog(@"gesture went left");
        }
       
        if (!_showPanel) {
            [self moveTabPanelToOriginalPosition];
        } else {
            NSLog(@"TAB : MORE THAN HALF");

            if (_currentTab == TAB_INFO) {
                [self pressRelateTab:nil];
            }  else if (_currentTab == TAB_RELATIVE) {
                if(_preVelocity.x < 0){
                    [self pressCommentTab:nil];

                }else{
                    [self pressInfoTab:nil];
                }
                NSLog(@"direction :: %f",_preVelocity.x);
            }else if(_currentTab == TAB_COMMENT){
                [self pressRelateTab:nil];
            }
        }
        CGFloat curW = self.moviePlayerController.view.frame.size.width;
        if (curW > viewWidth/2 || self.moviePlayerController.view.frame.origin.y + (curW/movieRatio + 80) < viewHeight) {
            [self scaleViewToOriginalSize];
            
        }else{
            originSize = NO;
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        //_preVelocity = velocity;
        CGFloat infoPos = _infoView.frame.size.height + _infoView.frame.origin.y;
        if(currentlocation.y < infoPos){
            CGFloat delta = velocity.y - _preVelocity.y;
            if(abs(delta)>20 && velocity.y){
                if(velocity.y > 0){
                    NSLog(@"gesture went down: %f - %d",delta,abs(delta));
                }else{
                    NSLog(@"gesture went up: %f - %d",delta,abs(delta));
                    
                }
                [self scalePlayView:velocity];
                _preVelocity = velocity;
            }
            NSLog(@"deltaYYY%f",delta);
            
            
        }else  if(currentlocation.y>=infoMarginTop+viewHeight/4+30){
            
            
            if (_currentTab== TAB_COMMENT && velocity.x > 0) {
                
                _showPanel = abs(_commentView.center.x - self.view.frame.size.width/2) > self.view.frame.size.width/2;
                _overviewView.center = CGPointMake(_overviewView.center.x + translatedPoint.x, _overviewView.center.y);
                _relateView.center = CGPointMake(_relateView.center.x + translatedPoint.x, _relateView.center.y);
                _commentView.center = CGPointMake(_commentView.center.x + translatedPoint.x, _commentView.center.y);
                _tabViewHightLight.center =  CGPointMake(_tabViewHightLight.center.x - translatedPoint.x/3, _tabViewHightLight.center.y);
                NSLog(@"currentTabView 1 %d",_showPanel);
                
            }else if(_currentTab == TAB_INFO && velocity.x < 0){
                NSLog(@"currentTabView 2");
                
                _showPanel = abs(_overviewView.center.x - self.view.frame.size.width/2) > self.view.frame.size.width/2;
                _overviewView.center = CGPointMake(_overviewView.center.x + translatedPoint.x, _overviewView.center.y);
                _relateView.center = CGPointMake(_relateView.center.x + translatedPoint.x, _relateView.center.y);
                _commentView.center = CGPointMake(_commentView.center.x + translatedPoint.x, _commentView.center.y);
                
                _tabViewHightLight.center =  CGPointMake(_tabViewHightLight.center.x - translatedPoint.x/3, _tabViewHightLight.center.y);
                
            }else if(_currentTab == TAB_RELATIVE){
                NSLog(@"currentTabView 3");
                _showPanel = abs(_relateView.center.x - self.view.frame.size.width/2) > self.view.frame.size.width/2;
                _overviewView.center = CGPointMake(_overviewView.center.x + translatedPoint.x, _overviewView.center.y);
                _relateView.center = CGPointMake(_relateView.center.x + translatedPoint.x, _relateView.center.y);
                _commentView.center = CGPointMake(_commentView.center.x + translatedPoint.x, _commentView.center.y);
                
                _tabViewHightLight.center =  CGPointMake(_tabViewHightLight.center.x - translatedPoint.x/3, _tabViewHightLight.center.y);
            }else{
                NSLog(@"currentTabView 4");
                _showPanel = FALSE;
                
            }
            [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
            
            
        }
    }
}
-(void)scaleViewToOriginalSize{
    originSize = YES;

    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        [self.moviePlayerController.view setFrame:CGRectMake(0, 64, viewWidth, playerHeight)];
        [self.movieIndicator setFrame:CGRectMake(0, 64, viewWidth, playerHeight)];
        [self.bgHeadrView setFrame:CGRectMake(0, 0, viewWidth, 64)];
        [self.tabviewPanel setFrame:CGRectMake(0, infoMarginTop+viewHeight/4, viewWidth, 30)];
        CGFloat scrollH =viewHeight - infoMarginTop - (viewHeight/4+30);
        //    infoMarginTop+viewHeight/4
        [_infoView setFrame:CGRectMake(0, infoMarginTop, self.view.frame.size.width, viewHeight/4)];

        [self.scrollView setFrame:CGRectMake(0, infoMarginTop + viewHeight/4+30, viewWidth*3, scrollH)];
        [self.btnPlay setFrame:CGRectMake(viewWidth/2 - BUTTON_PLAY_SIZE/2, marginTop + viewHeight/8 - BUTTON_PLAY_SIZE/2, BUTTON_PLAY_SIZE, BUTTON_PLAY_SIZE)];
        self.btnPlay.center = self.moviePlayerController.view.center;
        CGSize size = [_movieIndicator intrinsicContentSize];
        _movieIndicator.frame = CGRectMake((viewWidth-size.width)/2, marginTop + (playerHeight - size.height)/2, size.width, size.height);
        _infoView.alpha = 1.f;
        _scrollView.alpha = 1.f;
        _tabviewPanel.alpha = 1.f;
        [self.bgHeadrView setAlpha:1.f];

    } completion:^(BOOL finished){
        

    }];
    
    
}
-(void)scalePlayView:(CGPoint)velectity{
    CGFloat ratio = viewWidth/viewHeight;
    CGRect preFrame = self.moviePlayerController.view.frame;
    CGFloat deltaX = 0;
    CGFloat deltaY = 0;
    CGFloat deltaH = 0;
    CGFloat deltaW = 0;
   
        deltaY = velectity.y/20;
    CGFloat pRatio = viewWidth/playerHeight;

    if(preFrame.size.width<=viewWidth && velectity.y > 0){
        deltaH = velectity.y/20;
        NSLog(@"----------------------");
    }else if(preFrame.size.width >=viewWidth/2 && velectity.y<0){
        deltaH = velectity.y/20;

    }
    deltaW = ratio*deltaH;
    deltaX = ratio*deltaY;
    CGFloat toY =  preFrame.origin.y + deltaY;
    CGFloat toX = preFrame.origin.x + deltaX;
    
    CGFloat newW = preFrame.size.width - deltaW;
    if (newW<viewWidth/2) {
        newW = viewWidth/2;
    }else if(newW>viewWidth){
        newW = viewWidth;
    }
    CGFloat newH = preFrame.size.height - deltaH;
    if (newH>viewHeight) {
        newH = viewHeight;
    }else if(newH< viewHeight - (newW/pRatio+10)){
        newH =  viewHeight - (newW/pRatio+10);
        
    }
    if(toY<64){
        toY = 64;
    }else if(toY>viewHeight-(newW/pRatio+10)){
        toY=viewHeight-(newW/pRatio+10);
    }
    deltaY = toY - preFrame.origin.y;
    if(toX>viewWidth/2){
        toX = viewWidth/2;
    }else if(toX<0){
        toX = 0;
    }
//    self.view.frame = CGRectMake(toX,toY, newW, newH);
    _moviePlayerController.view.frame =CGRectMake(toX,toY, newW, newW/pRatio);
    CGFloat alpha  = _bgHeadrView.alpha;
    if (velectity.y>0) {
        alpha=alpha-0.05f;
        alpha = alpha<0?0:alpha;
    }else{
        alpha=alpha+0.05f;
        alpha=alpha>1?1:alpha;
    }
    CGRect headerFrame = _bgHeadrView.frame;
    //        self.view.alpha = alpha;
//    CGRect movieFrame = _moviePlayerController.view.frame;
    CGRect infoFrame = _infoView.frame;
    CGRect scrollFrame = _scrollView.frame;
    CGRect tabFrame = _tabviewPanel.frame;
//    CGFloat movieY = movieFrame.origin.y ;//-deltaY;
//    if(preFrame.origin.y>=0 && preFrame.origin.y<=74){
//        movieY-=deltaY;
//    }
//    if(movieY<0){
//        movieY = 0;
//    }else if(movieY>64){
//        movieY = 64;
//    }
//    _moviePlayerController.view.frame = CGRectMake(movieFrame.origin.x+deltaX, movieFrame.origin.y+deltaY, newW,newW/pRatio);
    _bgHeadrView.frame = CGRectMake(headerFrame.origin.x+(toX-preFrame.origin.x), headerFrame.origin.y+(toY-preFrame.origin.y) , headerFrame.size.width, headerFrame.size.height);

    _infoView.frame = CGRectMake(infoFrame.origin.x+(toX-preFrame.origin.x), toY+newW/pRatio, infoFrame.size.width, infoFrame.size.height);
      _tabviewPanel.frame= CGRectMake(tabFrame.origin.x+(toX-preFrame.origin.x), toY+newW/pRatio+infoFrame.size.height, tabFrame.size.width, tabFrame.size.height);
    _scrollView.frame= CGRectMake(scrollFrame.origin.x+(toX-preFrame.origin.x), toY+newW/pRatio+infoFrame.size.height +tabFrame.size.height, scrollFrame.size.width, scrollFrame.size.height);
  
//    _movieIndicator.frame =CGRectMake(toX,toY, newW, newH);
    _btnPlay.center = _moviePlayerController.view.center;
    _btnPlay.transform = CGAffineTransformMakeScale(newW/viewWidth,newW/viewWidth);
    CGSize size = [_movieIndicator intrinsicContentSize];
    _movieIndicator.frame = CGRectMake(toX+(newW-size.width)/2, toY + (newW/pRatio - size.height)/2, size.width, size.height);
    //makeviewtransparent
    if(preFrame.origin.y>viewHeight/2){
        alpha = 0.f;
    }
    _bgHeadrView.alpha = alpha;
    _infoView.alpha = alpha;
    _scrollView.alpha = alpha;
    _tabviewPanel.alpha = alpha;
}
-(void)closeLoginView{
    [self.view bringSubviewToFront:_commentView];
    [_commentView setFrame:CGRectMake(10, infoMarginTop + viewHeight/4+30, viewWidth, viewHeight - infoMarginTop -210)];
    [_commentView.webview setFrame:(CGRectMake(5, 5, viewWidth-30, viewHeight-95))];
    NSLog(@"closeloginviewy");
}
-(void)showLoginView{
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, viewWidth-20, viewHeight-20) ];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://sukienmienbac.com.vn/phimbb.html"];
    NSURL *url = [NSURL URLWithString:fullURL];
    [web loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:web];
//    [self.view bringSubviewToFront:_commentView];
//    [_commentView setFrame:CGRectMake(10, 74, viewWidth-20, viewHeight-90)];
//    [_commentView.webview setFrame:(CGRectMake(5, 5, viewWidth-30, viewHeight-95))];
}
-(void)moveTabPanelToOriginalPosition{
    if(_currentTab == TAB_INFO){
        [self pressInfoTab:nil];
    }else if(_currentTab == TAB_RELATIVE){
        [self pressRelateTab:nil];
    }else{
        [self pressCommentTab:nil];
    }
}
-(void)pressedTab : (id)button{
    UIButton *btnTab = (UIButton *)button;
    NSInteger tag = btnTab.tag;
    if (tag==1) {
        [self pressInfoTab:button];
    }else if(tag==2){
        [self pressRelateTab:button];
    }else if(tag==3){
    
        [self pressCommentTab:button];
    }
  
}
-(void)pressCommentTab : (id)button{

    _currentTab = TAB_COMMENT;
    // _btnTabInfo.alpha = 1.0f;
    // _btnTabRelative.alpha = 0.5f;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect fr =  _commentView.frame;
        [_relateView setFrame:CGRectMake(-viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_overviewView setFrame:CGRectMake(-2*viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_commentView setFrame:CGRectMake(0, fr.origin.y, fr.size.width, fr.size.height)];
        [_tabViewHightLight setFrame:CGRectMake(btnTabWidth*2+btnTabWidth/4, 28, btnTabWidth/2, 2)];
        
    }];
}
-(void)pressInfoTab:(id)button{
    _currentTab = TAB_INFO;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect fr =  _overviewView.frame;
        [_relateView setFrame:CGRectMake(viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_overviewView setFrame:CGRectMake(0, fr.origin.y, fr.size.width, fr.size.height)];
        [_commentView setFrame:CGRectMake(2*viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_tabViewHightLight setFrame:CGRectMake(btnTabWidth/4, 28, btnTabWidth/2, 2)];
        
    }];
}
-(void)pressRelateTab:(id)button{
    
    _currentTab    = TAB_RELATIVE;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect fr =  _relateView.frame;
        [_relateView setFrame:CGRectMake(0, fr.origin.y, fr.size.width, fr.size.height)];
        [_overviewView setFrame:CGRectMake(-viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_commentView setFrame:CGRectMake(viewWidth, fr.origin.y, fr.size.width, fr.size.height)];
        [_tabViewHightLight setFrame:CGRectMake(btnTabWidth+btnTabWidth/4, 28, btnTabWidth/2, 2)];
    }];
}
-(void)pressCloseMoviePlayerView : (id)button{
//    [self ]
    [self.moviePlayerViewController.moviePlayer stop];
    [self.moviePlayerController stop];
    [self dismissMoviePlayerViewControllerAnimated];

}
-(void)pressPlay : (id)button{
    
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    
//    [self.view addSubview:_moviePlayerController.view];
//
//    [self.moviePlayerController setContentURL:movieURL];
//    [self.moviePlayerController prepareToPlay];
    [_btnPlay setHidden:YES];
    [self.moviePlayerController play];
//    [self.view addSubview: self.ctrStyleView];
/*
    self.moviePlayerViewController.moviePlayer.shouldAutoplay = YES;
    if(self.moviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused){
        [self.moviePlayerViewController.moviePlayer play];

    }
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
*/
 }
-(void)pressCancel:(id)button{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.moviePlayerController stop];
}


-(IBAction)btnMovePanelLeft:(id)sender {
    UIButton *button = sender;
    NSLog(@"PlayVideoBtnPanelLeft %d",button.tag);

    switch (button.tag) {
        case 0: {
            [_relateView setHidden:NO];
            [_commentView setHidden:NO];
            [_playDelegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_relateView setHidden:YES];
            [_commentView setHidden:YES];
            NSArray *cats = [self getListGenreKey:_infoDetail.cate];
            [_playDelegate movePanelLeft:[cats objectAtIndex:0]];
            break;
        }
            
        default:
            break;
    }
}
#pragma mark - Loading and play Video
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];

       player.fullscreen = NO;
//        [self.ctrStyleView removeFromSuperview];
        NSLog(@"PlayBackFinished");
    }
}
- (void) moviePlayBackStateChanged:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];

    if(player.playbackState == MPMoviePlaybackStateInterrupted){
        //[player.view removeFromSuperview];
        //[self.ctrStyleView removeFromSuperview];
    
    }else if(player.playbackState == MPMoviePlaybackStatePlaying){
        [_btnPlay setHidden:YES];
    }else if(player.playbackState == MPMoviePlaybackStatePaused){
        [_btnPlay setHidden:NO];
    }else if(player.playbackState == MPMoviePlaybackStateStopped){
        [_btnPlay setHidden:NO];
    }
    NSLog(@"stageChanged %d",player.playbackState);
}
-(void)addMovieControl:(NSNotification *)notificaton{
    [self.view bringSubviewToFront:self.ctrStyleView];
    NSLog(@"fullscreen_xxx");
}
-(void)moviePlayerLoadStateChanged:(NSNotification*)notification{
    NSLog(@"State changed to: %d\n", _moviePlayerController.loadState);
    if(_moviePlayerController.loadState == MPMovieLoadStatePlayable){
        [_movieIndicator stopAnimating];
        if(self.moviePlayerController.playbackState!=MPMoviePlaybackStatePlaying){
            [_btnPlay setHidden:NO];

        }
    }else if(_moviePlayerController.loadState == MPMovieLoadStateStalled){
       // [_movieIndicator setHidden:NO];
       // [_movieIndicator startAnimating];
    }else if(_moviePlayerController.loadState == MPMovieLoadStateUnknown){
    
       // [_movieIndicator setHidden:NO];
       // [_movieIndicator startAnimating];

    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSArray *)getListGenreKey:(NSString *)cate{
    NSMutableArray *result= [[NSMutableArray alloc] init];
    NSArray *cats= [cate componentsSeparatedByString:@","];
    for(int i = 0; i < cats.count;i++){
        NSString *key= [self getGenreKeyByTitle:[cats objectAtIndex:i]];
        if(![key isEqualToString:@"Not Found"]){
            [result addObject:key];
        }
    }
    return result;


}
-(NSString *) getGenreKeyByTitle:(NSString *)title{
    for(int i = 0; i < genraData.count;i++){
        Genre *gen = [genraData objectAtIndex:i];
        if([title containsString:gen.title]){
            return gen.key;
        }
        
    }
    return @"Not Found";
}
-(void)updateRightMenuData : (NSArray *)data{
//    UIViewController *vc = [SlideNavigationController sharedInstance].rightMenu;
//    
//    if ([vc isKindOfClass:[RightMenuViewController class]]) {
//        // code
//        RightMenuViewController *rv = (RightMenuViewController *)vc;
//        [rv setFilmDataArray:data];
//        NSLog(@"Em day roi ");
//    }else{
//        NSLog(@"Em dau roi");
//    }

}
#pragma Mark DatabaseManager
-(void)saveFilmHistory{
    NSLog(@"SAVEHISTORY");
    
    UserDataFilm *data = [self.dbManager getUserDataByFilmId:_infoDetail._id];
    data.info =_infoDetail;
    data.type = 1;
    data.date = @"01-01-2015";
    [self.dbManager saveFilmUserData:data];
}
#pragma textFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    NSLog(@"comment on facebook commentbox");
}
-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    keyboardHeight = keyboardFrame.size.height;
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
}

- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
   keyboardHeight =  keyboardHeight > 100?keyboardHeight : 300;
    [UIView animateWithDuration:0.5f animations:^{
        self.view.frame = CGRectMake(0, -keyboardHeight, viewWidth, viewHeight);
    }];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    [UIView animateWithDuration:0.5f animations:^{
        self.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    }];

}
-(void)caculatePlayerHeight{
    NSString *deviceString =[[UIDevice currentDevice] platformString];
    if ([deviceString containsString:@"iPad"]) {
        //panelWidth = self.view.frame.size.width - 320;
        playerHeight = viewHeight/4 + viewHeight/8;
    }else{
        //panelWidth = PANEL_WIDTH;
        playerHeight = viewHeight/4;
        
    }
}
#pragma mark - call php api
-(void)callWebService{
    NSLog(@"call API");
    NSString *ext= @"%2F0";
    NSString *WS_URL = [NSString stringWithFormat:@"%@%d%@",API_URL_WHATCH_FILM,filmInfo._id,ext];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:WS_URL]];
//    
//    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:WS_URL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"API URL %@",WS_URL);
    if (connection)
    {
        //receivedData = nil;
    }
    else
    {
        NSLog(@"Connection could not be established");
    }
    
}
#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!receivedData)
        receivedData = [[NSMutableData alloc] initWithData:data];
    else
        [receivedData appendData:data];
    [self pareJsonToData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"***** Connection failed");
    
    receivedData=nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    NSLog(@"***** Succeeded! Received %d bytes of data",[receivedData length]);
   // NSLog(@"***** AS UTF8:%@",[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
}
-(void)pareJsonToData{
    NSLog(@"pareDAta");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Background work
        NSString *receivedDataString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSError* error;
        
        NSDictionary* json =     [NSJSONSerialization JSONObjectWithData: [receivedDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error];        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update UI
            
            
            //SearchResultItem *item = [[SearchResultItem alloc] initWithData:json];
            if(json){
//                [searchResults removeAllObjects];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *listLink= [json objectForKey:@"movie_links"];
                    NSLog(@"LinkfilmARR %@ %d",listLink,listLink.count);
                    if([listLink count]>0){
                        
                        movieURL =[NSURL URLWithString:[listLink objectAtIndex:0 ]];
                        NSLog(@"Linkfilm %@",movieURL);
//                        [_moviePlayerViewController.moviePlayer setContentURL:movieURL];
//                        [_moviePlayerViewController.moviePlayer prepareToPlay];
                    }
                    
                   // NSDictionary *serverlist = [json objectForKey:@"movie_links_server"];
                   // NSLog(@"serverlist %@",[serverlist objectForKey:@"server_2"]);
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [_tbSearch reloadData];
                        [_relateView setDataArrayEpsolider2:listLink];
                        _infoDetail = [[FilmInfoDetails alloc] initWithData:json];
                        [_infoView bindDataToView:_infoDetail];
                        [_overviewView bindDataToView:_infoDetail.name desc:_infoDetail.desc];
                        [self.moviePlayerViewController .moviePlayer setContentURL:movieURL];
                        [self.moviePlayerViewController.moviePlayer prepareToPlay];
                        [self.moviePlayerController setContentURL:movieURL];
                        [self.moviePlayerController prepareToPlay];
                        [_btnPlay setUserInteractionEnabled:YES];
                        [self saveFilmHistory];
                        //                        EmployeeDbUtil get
                        //[self pressPlay:nil];
//                        [self updateRightMenuData : listLink];
                    });
                });
            }
            
        });
    });


}
#pragma PlayVideo Delegate
-(void)playVideoAtIndex:(NSInteger)index{
    [self pressPlay:nil];
    
}
-(void)playMovieWithData:(SearchResultItem *)item{
    filmInfo = item;
    _infoView.thumbnail.image = nil;
    [self btnMovePanelLeft:nil];
    [self prepareFilmData:item];
}
-(void)playMovieAtIndex:(NSString *)url{
    movieURL = [NSURL URLWithString:url];
//    [self.moviePlayerViewController .moviePlayer setContentURL:movieURL];
//    [self.moviePlayerViewController.moviePlayer prepareToPlay];
//    NSLog(@"movieURL %@",movieURL);
    [self.moviePlayerController setContentURL:movieURL];
    [self.moviePlayerController prepareToPlay];
    [self pressPlay:nil];

}


@end
