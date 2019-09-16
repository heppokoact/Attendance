//
//  Cat.h
//  Attendance
//
//  Created by heppokoact on 2012/09/17.
//
//

#import <CoreData/CoreData.h>

@interface Cat :NSObject

+ (Cat *)sharedInstance;

- (NSDictionary *)dictForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;

@end
