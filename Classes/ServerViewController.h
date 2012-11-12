//
//  ServerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

// table view
#define kOverview -1
#define kDetails 0
#define kIPAddresses 1
#define kActions 2

#define kName 0
#define kStatus 1
#define kHostId 2

#define kImage 0
#define kMemory 1
#define kDisk 2

@class Server, OpenStackAccount, ServersViewController, AnimatedProgressView, OpenStackRequest, AccountHomeViewController, NameAndStatusTitleView;

@interface ServerViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    Server *server;
    OpenStackAccount *account;
    IBOutlet UITableView *tableView;
    AnimatedProgressView *progressView;
    
    ServersViewController *serversViewController;
    
    UIActionSheet *ipAddressActionSheet;
    UIActionSheet *rebootActionSheet;
    UIActionSheet *deleteActionSheet;

    BOOL performingAction;
    
    NSTimer *countdownTimer;
    NSString *rebootCountdown;
    NSString *renameCountdown;
    NSString *resizeCountdown;
    NSString *changePasswordCountdown;
    NSString *backupsCountdown;
    NSString *rebuildCountdown;
    NSString *deleteCountdown;    
    
    NSIndexPath *selectedServerIndexPath;
    
    UIImageView *actionsArrow;
    
    OpenStackRequest *pollRequest;
    BOOL polling;
    
    AccountHomeViewController *accountHomeViewController;
    
    IBOutlet NameAndStatusTitleView *titleView;
    IBOutlet UIView *actionView;
    CGPoint previousScrollPoint;
    
    IBOutlet UIButton *rebootButton;
    IBOutlet UIButton *pingButton;
}

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *selectedIPAddressIndexPath;
@property (nonatomic, retain) ServersViewController *serversViewController;
@property (nonatomic, retain) NSIndexPath *selectedServerIndexPath;
@property (nonatomic, retain) AccountHomeViewController *accountHomeViewController;
@property (nonatomic, retain) NSString *selectedIPAddress;

@property (nonatomic, assign) NSInteger totalActionRows;
@property (nonatomic, assign) NSInteger renameRow;
@property (nonatomic, assign) NSInteger resizeRow;
@property (nonatomic, assign) NSInteger changePasswordRow;
@property (nonatomic, assign) NSInteger backupsRow;
@property (nonatomic, assign) NSInteger rebuildRow;
@property (nonatomic, assign) NSInteger deleteRow;


- (void)refreshLimitStrings;
- (void)pollServer;

- (void)changeAdminPassword:(NSString *)password;
- (void)renameServer:(NSString *)name;
- (IBAction)rebootButtonPressed:(id)sender;
- (IBAction)snapshotButtonPressed:(id)sender;
- (IBAction)pingIPButtonPressed:(id)sender;

@end
