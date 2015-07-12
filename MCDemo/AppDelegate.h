//
//  AppDelegate.h
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"
#import "ConnectionsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MCBrowserViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) ConnectionsViewController *cvController;
@property (nonatomic) MCManager *mcManager;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;
@property (nonatomic, strong) NSString *userID;
@property (strong, nonatomic) NSMutableArray *foundUsersArray;
@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCPeerID *chattingWithID;

-(void)getFoundUser: (MCPeerID *)peerID;
-(void) connectWithPeer:(MCPeerID *)peerID;

-(NSArray *) getChattingWithID;
-(void) setChattingWithID:(MCPeerID *)chattingWithID;

@end
