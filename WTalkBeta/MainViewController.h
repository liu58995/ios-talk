//
//  MainViewController.h
//  WTalkBeta
//
//  Created by silicon on 14-9-24.
//  Copyright (c) 2014年 silicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecorderManager.h"
#import "PlayerManager.h"

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, RecordingDelegate, PlayingDelegate, UIGestureRecognizerDelegate>

- (IBAction)talk:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *vTableView;

@property (strong, nonatomic) IBOutlet UIButton *speekBtb;

@property (assign) BOOL isSpeak;

@property (strong, nonatomic) NSMutableArray *voiceArray;

@property (strong, nonatomic) NSString *fileName;

@property (assign) BOOL isPlaying;

@end
