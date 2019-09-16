
#import <UIKit/UIKit.h>
#import "MessageDelegate.h"

#define ERROR_DOMAIN_ATTENDANCE @"AttendanceErrorDomain"

#define ATT_CAT_NOT_YET @"0"
#define HANDOUT_CAT_NOT_YET @"0"
#define HANDOUT_CAT_YET @"1"
#define RCPT_CAT_NOT_YET @"0"
#define RCPT_CAT_YET @"1"
#define OK_CANCEL_CAT_CANCEL @"0"
#define OK_CANCEL_CAT_OK @"1"
#define TIMESTAMP_FORMAT @"yyyy-MM-dd HH:mm:ss.SSS"

#define WS_KEY_STATUS_CODE @"statusCode"
#define WS_KEY_ERRORS @"errors"
#define WS_KEY_ERROR_CODE @"errorCode"
#define wS_KEY_ERROR_MESSAGE @"errorMessage"

#define WS_STATUS_OK @"200"
#define WS_STATUS_ERROR @"500"

#define STR_ERROR_CODE_OPTIMISTIC_LOCK @"101"
#define STR_ERROR_CODE_UNKNOWN @"999"

#define ERROR_CODE_OPTIMISTIC_LOCK 101
#define ERROR_CODE_UNKNOWN 999

#define UD_KEY_ATTENDANCE_SERVER_URL @"UD_KEY_ATTENDANCE_SERVER_URL"

@class DetailViewController;
@class EmployeeSettingsViewController;
@class MasterViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MessageDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)outputErrorLog:(NSError *) err forKey:(NSString *) key;
- (EmployeeSettingsViewController *)obtainEmployeeSettingsViewController;
- (DetailViewController *)obtainDetailViewController;
- (MasterViewController *)obtainMasterViewController;
- (void)resetRightView;
- (void)dismissMessage;

@end
