
//  AppDelegate.m
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const baseURL = @"http://54.69.227.168:8080/users/";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.foundUsersArray = [[NSMutableArray alloc] init];

    self.peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].identifierForVendor.UUIDString];
    
    // Get your own user obj
    [self getFoundUser:self.peerID];
    
    _mcManager = [[MCManager alloc] init];
    
    [_mcManager setupPeerAndSessionWithDisplayName:self.peerID.displayName];
    [_mcManager advertiseSelf:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    
    [_mcManager setupMCBrowser];
    
    return YES;
}


-(void)getFoundUser: (MCPeerID *)peerID {
    
    NSLog(@"Heard getFoundUser, %@", self.foundUsersArray);

    if ([peerID.displayName isEqualToString:self.peerID.displayName]) {
        // get yourself
        self.userID = @"1";
    } else {
        // get your peer
        self.userID = @"2";
        [self.foundUsersArray addObject:peerID];
        [self connectWithPeer:peerID];
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"peerID", nil];
    
    // Hacking this peerID bullshit right now...
    NSArray *vals = [NSArray arrayWithObjects:self.userID, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
    
    NSData *jsonData;
    NSString *jsonString;
    if([NSJSONSerialization isValidJSONObject:jsonDictionary]){
        
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *requestString = [NSString stringWithFormat:[baseURL stringByAppendingString:@"getFoundUser"]];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            NSDictionary *myResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            NSLog(@"Successfully got users from DB, %@", myResponse);
        

        }
        else {
            
            NSLog(@"Error getting users from DB");
        }
    }];
    
    [dataTask resume];
}

-(void) connectWithPeer:(MCPeerID *)peerID {
    
    NSData *data = [[NSData alloc] init];
    NSTimeInterval time = 30.0;
    
    if (self.foundUsersArray.count > 0) {
        [self.mcManager.browser.browser invitePeer:peerID toSession:self.mcManager.session withContext:data timeout:time];
    }

}
//
//-(void) setChattingWithID:(MCPeerID *)chattingWithID {
//    self.chattingWithID = chattingWithID;
//}

-(NSArray *) getChattingWithID {
    NSArray *arr = [[NSArray alloc] initWithObjects:[self.foundUsersArray objectAtIndex:0], nil];
    return arr;
}

#pragma mark - Private method implementation

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    NSLog(@"peerDidChangeStateWithNotification : %@", peerDisplayName);

    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            
            [_arrConnectedDevices addObject:peerDisplayName];
            
            NSLog(@"Adding peer to list of connected devices: %@", peerDisplayName);
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                NSUInteger indexOfPeer = [_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
                NSLog(@"Removing peer from list of connected devices: %@", peerDisplayName);
                
            }
        }
        
        NSLog(@"Would have refreshed the table of connected devices, %@", _arrConnectedDevices);
        
    }
    
}


@end
