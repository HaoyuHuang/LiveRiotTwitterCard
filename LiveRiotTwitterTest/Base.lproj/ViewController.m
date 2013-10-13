//
//  ViewController.m
//  STTwitterDemoiOSSafari
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import "Social/SLComposeViewController.h"
#import "Social/SLServiceTypes.h"

@interface ViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@end

// https://dev.twitter.com/docs/auth/implementing-sign-twitter

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // set the twitter app keys.
    self.consumerKey = @"Sh5JfGh1T74hpE8lh35Rhg";
    self.consumerPwd = @"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo";
    _appToken = @"1672361641-yUsEsXiEKFAw4ikjwr3H42IdhZTANyCFCJs6lpD";
    _appSecret = @"XyotUZro7JsXJlnFYN0ebLrpfNuYZQEBZxJQzDc";
}

// postStatus button action
- (IBAction)postTweets:(id)sender {
    [self twitterSheet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// loginWithiOSAction
- (IBAction)loginWithiOSAction:(id)sender {
    
    _loginStatusLabel.text = @"Trying to login with iOS...";
    _loginStatusLabel.text = @"";
    
    _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey consumerSecret:self.consumerPwd oauthToken:_appToken oauthTokenSecret:_appSecret];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        
        _loginStatusLabel.text = username;
        
    } errorBlock:^(NSError *error) {
        _loginStatusLabel.text = [error localizedDescription];
    }];
   }

// print all key-value pairs in a dictionary
- (void) printDictionary:(NSDictionary*)status {
    for (id key in [status allKeys]) {
        NSLog(@"status reply key: %@ value: %@", key,  [status objectForKey:key]);
    }
}

- (IBAction)loginInSafariAction:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey
                                                 consumerSecret:self.consumerPwd];
    
    _loginStatusLabel.text = @"Trying to login with Safari...";
    _loginStatusLabel.text = @"";
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
        [[UIApplication sharedApplication] openURL:url];
        
    } oauthCallback:@"myapp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        _loginStatusLabel.text = [error localizedDescription];
                    }];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier {
    
    [_twitter postAccessTokenRequestWithPIN:verfier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
        _loginStatusLabel.text = screenName;
        
    } errorBlock:^(NSError *error) {
        
        _loginStatusLabel.text = [error localizedDescription];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)getTimelineAction:(id)sender {
    [self postTweets];
}

- (void) postTweets {
    NSLog(@"postsTweets");
    NSNumber* yes = [NSNumber numberWithBool:YES];
    [_twitter postStatusUpdate:@"test" inReplyToStatusID:nil latitude:@"37.7821120598956" longitude:@"-122.400612831116" placeID:@"df51dec6f4ee2b2c" displayCoordinates:yes trimUser:yes successBlock:^(NSDictionary *status) {
                //
        [self printDictionary:status];
    } errorBlock:^(NSError *error) {
        //
        NSLog(@"-- %@", [error localizedDescription]);
        _loginStatusLabel.text = [error localizedDescription];
    }];
}

#pragma mark postStatusUpdate methods

- (void) twitterSheet {
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"http://greenbay.usc.edu/csci577/fall2013/projects/team04/twittercard.html"];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"larry.png"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}

// post tweets with media contents
- (void) postMediaTweets {
    NSLog(@"postsTweets");
    NSURL* url = [NSURL alloc];
    NSString* path = @"http://greenbay.usc.edu/csci577/fall2013/projects/team04/twittercard.html";

    url = [NSURL URLWithString:path];
    
    [_twitter postStatusUpdate:@"Test LiveRiot" inReplyToStatusID:nil mediaURL:url placeID:nil latitude:nil longitude:nil successBlock:^(NSDictionary *status) {
        [self printDictionary:status];
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
        _loginStatusLabel.text = [error localizedDescription];
    }];
}

- (void) getTimeLine {
    self.getTimelineStatusLabel.text = @"";
    
    [_twitter getHomeTimelineSinceID:nil
                               count:20
                        successBlock:^(NSArray *statuses) {
                            
                            NSLog(@"-- statuses: %@", statuses);
                            
                            self.getTimelineStatusLabel.text = [NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]];
                            
                            self.statuses = statuses;
                            
                            [self.tableView reloadData];
                            
                        } errorBlock:^(NSError *error) {
                            self.getTimelineStatusLabel.text = [error localizedDescription];
                        }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@ | %@", screenName, dateString];
    
    return cell;
}

@end
