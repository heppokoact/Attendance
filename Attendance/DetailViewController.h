
#import <UIKit/UIKit.h>
#import "Attendance.h"
#import "ResetableViewController.h"

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate, ResetableViewController, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *empNoLabel;
@property (strong, nonatomic) IBOutlet UILabel *empNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *attButton;
@property (strong, nonatomic) IBOutlet UIButton *absentButton;
@property (strong, nonatomic) IBOutlet UIButton *tardyButton;
@property (strong, nonatomic) IBOutlet UIButton *earlyLeavingButton;
@property (strong, nonatomic) IBOutlet UILabel *handoutExistenceLabel;
@property (strong, nonatomic) IBOutlet UIButton *handoutSitCatButton;
@property (strong, nonatomic) IBOutlet UITextField *handoutNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rcptExistenceLabel;
@property (strong, nonatomic) IBOutlet UIButton *rcptSitCatButton;
@property (strong, nonatomic) IBOutlet UITextField *rcptNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextView *remColTextView;
@property (strong, nonatomic) IBOutlet UIButton *handoutEditButton;
@property (strong, nonatomic) IBOutlet UIButton *rcptEditButton;
@property (strong, nonatomic) IBOutlet UIButton *remColEditButton;

- (IBAction)absenceButtonTapped:(id)sender;
- (IBAction)tardyButtonTapped:(id)sender;
- (IBAction)earlyLeavingButtonTapped:(id)sender;
- (IBAction)attButtonTapped:(id)sender;
- (IBAction)handoutButtonTapped:(id)sender;
- (IBAction)rcptButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)handoutEditButtonTapped:(id)sender;
- (IBAction)rcptEditButtonTapped:(id)sender;
- (IBAction)remColEditButtonTapped:(id)sender;
- (IBAction)textChanged:(id)sender;
- (void)resetView;
- (void)setDetailItem:(Attendance *)detailItem;
- (Attendance *)getDetailItem;
- (BOOL)isChanged;
- (void)displayNavigationMessage;

@end
