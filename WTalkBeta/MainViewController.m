//
//  MainViewController.m
//  WTalkBeta
//
//  Created by silicon on 14-9-24.
//  Copyright (c) 2014年 silicon. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController()

@end

@implementation MainViewController
@synthesize isSpeak = _isSpeak;
@synthesize voiceArray = _voiceArray;
@synthesize fileName = _fileName;
@synthesize isPlaying = _isPlaying;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.vTableView.delegate = self;
    self.voiceArray = [[NSMutableArray alloc] init];
    
    UILongPressGestureRecognizer *guesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handSpeakBtnPressed:)];
    guesture.delegate = self;
    guesture.minimumPressDuration = 0.01f;
    
    //录音按钮添加手势操作
    [_speekBtb addGestureRecognizer:guesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView+++++++++++++++++++++++++++++++++++++++
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //cell选中属性修改为无
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifid = @"simpleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifid];
    if(!cell){
        cell = [[UITableViewCell alloc] init];
    }
    
    NSMutableDictionary *dic = [self.voiceArray objectAtIndex:indexPath.row];
    
    //加载聊天内容
    UIButton *chatView = [dic objectForKey:@"view"];
    if([[dic objectForKey:@"from"] isEqualToString:@"SELF"]){
        
        //add the date/time when it is recorded.
        UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 100, 30)];
        NSDate *date = [dic objectForKeyedSubscript:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd hh:mm"];
        NSString *strDate = [dateFormatter stringFromDate:date ];
        [labelDate setText:strDate];
        [cell addSubview:labelDate];
        
        //添加录音时长显示
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(120, 25, 30, 30)];
        int time = [[dic objectForKey:@"time"] intValue];
        [label setText:[NSString stringWithFormat:@"%d'", time]];
        [cell addSubview:label];
        
        //添加头像
        float offset = (chatView.frame.size.height - 48)>0?(chatView.frame.size.height - 48)/2:10;
        UIImageView *headIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 48 -5, offset, 48, 48)];
        [headIcon setImage:[UIImage imageNamed:@"h2.jpg"]];
        [cell addSubview:headIcon];
        [chatView setTitle:@"点击播放" forState:UIControlStateNormal];
        
        chatView.tag = 100 + indexPath.row;
        [chatView addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        
    }else if([[dic objectForKey:@"from"] isEqualToString:@"OTHER"]){
        //系统自动回复部分
        float offset = (chatView.frame.size.height - 48)>0?(chatView.frame.size.height - 48)/2:10;
        UIImageView *headIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, offset, 48, 48)];
        [headIcon setImage:[UIImage imageNamed:@"h1.jpg"]];
        [cell addSubview:headIcon];
        
        NSString *title = [NSString stringWithFormat:@"%d Hello",indexPath.row];
        [chatView setTitle:title forState:UIControlStateNormal];
    }

    [cell addSubview:chatView];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_voiceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *chatView = [[_voiceArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
    return chatView.frame.size.height+30;
}

//添加手势操作，长按按钮
- (void)handSpeakBtnPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        
        [self.speekBtb setTitle:@"松开结束" forState:UIControlStateNormal];
        [self talk:nil];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
        [self.speekBtb setTitle:@"按住说话" forState:UIControlStateNormal];
        [self stopRecordVoice];
    }
}

//开始录音
- (IBAction)talk:(id)sender {
    //若正在播放则立即返回
    if(self.isPlaying){
        return;
    }
    
    if(!self.isSpeak){
        self.isSpeak = YES;
        [RecorderManager sharedManager].delegate = self;
        [[RecorderManager sharedManager] startRecording];
    }
}

//结束录音
- (void)stopRecordVoice{
    self.isSpeak = NO;
    [[RecorderManager sharedManager] stopRecording];
}

//播放录音
- (void)playVoice:(id)sender{
    if(self.isSpeak){
        return;
    }
    
    if(!self.isPlaying){
        UIButton *btn = (UIButton *)sender;
        NSInteger index = btn.tag;
        
        NSMutableDictionary *dic = [_voiceArray objectAtIndex:(index - 100)];
        self.fileName = [dic objectForKey:@"voice"];
        
        [PlayerManager sharedManager].delegate = nil;
        
        self.isPlaying = YES;
        [[PlayerManager sharedManager] playAudioWithFileName:self.fileName delegate:self];
    }else{
        self.isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
}

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval{
    //录音保存的文件地址
    self.fileName = filePath;
    UIButton *view = [self bubbleView:@"点击播放" from:YES];
    //时长
    NSNumber *num = [[NSNumber alloc] initWithDouble:interval];
    NSDate  *date = [[NSDate alloc] init ];
    
    NSLog(@"audio create at : %@", date);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"SELF", @"from", view, @"view", self.fileName, @"voice", num, @"time", date, @"date", nil];
    [self.voiceArray addObject:dic];
    
    //系统默认回复消息
    UIButton *otherView = [self bubbleView:@"你好!" from:NO];
    NSMutableDictionary *m_dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"OTHER", @"from", otherView, @"view", @"", @"voice", 0, @"time",nil];
    
    [self.voiceArray addObject:m_dic];
    
    //[self.vTableView reloadData];
    [self.vTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    long lastRowNumber = [self.vTableView numberOfRowsInSection:0 ] - 1;
    
    if(lastRowNumber >= 0)
    {
        NSIndexPath* ip  = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        //[self.vTableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
        [self.vTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

//超时操作
- (void)recordingTimeout{
    self.isSpeak = NO;
}

//录音机停止采集声音
- (void)recordingStopped{
    self.isSpeak = NO;
}

//录制失败操作
- (void)recordingFailed:(NSString *)failureInfoString{
    self.isSpeak = NO;
}

//播放停止
- (void)playingStoped{
    self.isPlaying = NO;
}

//聊天气泡按钮生成
- (UIButton*)bubbleView:(NSString *)message from:(BOOL)isFromSelf
{
    UIView *returnView = [self assembleMessageAtIndex:message from:isFromSelf];
    UIButton *cellView = [[UIButton alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    [returnView setBackgroundColor:[UIColor clearColor]];
    
    NSString *picName = [NSString stringWithFormat:@"%@.png", isFromSelf?@"bubble2":@"bubble1"];
    UIImage *bubble = [UIImage imageNamed:picName];
    
    UIImageView *bubbleView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:35 topCapHeight:3]];
    if(isFromSelf)
    {
        returnView.frame = CGRectMake(9.0f, 20.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+45.0f, returnView.frame.size.height + 20.0f);
        cellView.frame = CGRectMake(self.view.frame.size.width - bubbleView.frame.size.width - 60, 20.0f, bubbleView.frame.size.width, bubbleView.frame.size.height + 20.0f);
    }
    else
    {
        returnView.frame = CGRectMake(88.0f, 20.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleView.frame = CGRectMake(55.0f, 14.0f, returnView.frame.size.width + 45.0f, returnView.frame.size.height + 20.0f);
        cellView.frame = CGRectMake(50.0f, 20.0f, bubbleView.frame.size.width + 50.0f, bubbleView.frame.size.height + 20.0f);
    }
    
    [cellView setBackgroundImage:bubble forState:UIControlStateNormal];
    [cellView setFont:[UIFont systemFontOfSize:13.0f]];
    return cellView;
}

#pragma mark -
#pragma mark assemble message at index
#define BUBBLEWIDTH 18
#define BUBBLEHEIGHT 18
#define MAX_WIDTH 140
- (UIView *)assembleMessageAtIndex:(NSString *)message from:(BOOL)fromself
{
    NSMutableArray  *array = [[NSMutableArray alloc] init];
    [self getImageRange:message _array:array];
    
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    if(array)
    {
        for(int i = 0; i < [array count]; i++)
        {
            NSString *msg = [array objectAtIndex:i];
            
            for (int index = 0; index < msg.length; index++)
            {
                NSString *m_ch = [msg substringWithRange:NSMakeRange(index, 1)];
                if(upX >= MAX_WIDTH)
                {
                    upY = upY + BUBBLEHEIGHT;
                    upX = 0;
                    x = 140;
                    y = upY;
                }
                
                UIFont *font = [UIFont systemFontOfSize:13.0f];
                CGSize m_size = [m_ch sizeWithFont:font constrainedToSize:CGSizeMake(140, 40)];
                UILabel *m_label = [[UILabel alloc] initWithFrame:CGRectMake(upX, upY, m_size.width, m_size.height)];
                [returnView addSubview:m_label];
                m_label.font = font;
                m_label.text = m_ch;
                m_label.backgroundColor = [UIColor clearColor];
                upX = upX+m_size.width;
                if(x < 140)
                {
                    x = upX;
                }
            }
        }
    }
    
    returnView.frame = CGRectMake(15.0f, 1.0f, x, y);
    return returnView;
}

- (void) getImageRange:(NSString *)message _array:(NSMutableArray *)array
{
    if(message != nil)
    {
        [array addObject: message];
    }
}


- (void)dealloc{

    [self removeObserver:self forKeyPath:@"isSpeak"];
    self.fileName = nil;
}

@end

































