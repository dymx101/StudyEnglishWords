//
//  DDPlayAround.m
//  AppFramework
//
//  Created by Dong Yiming on 10/24/13.
//  Copyright (c) 2013 ToMaDon. All rights reserved.
//

#import "DDPlayAround.h"

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Person.h"
//#import "CoreData+MagicalRecord.h"

@implementation DDPlayAround

+(void)play
{
    [self testCocoaLumberJack];
    //[self testFMDB];
    [self testMagicRecord];
}

+(void)testCocoaLumberJack
{
    // init loggers and add them
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    //usage
    DDLogError(@"Broken sprocket detected!");
    NSString *filePath = @"Usr/Dong";
    NSUInteger fileSize = 19999;
    DDLogVerbose(@"User selected file:%@ withSize:%u", filePath, fileSize);
    
    
    // And then enable colors
    //[[DDTTYLogger sharedInstance] setColorsEnabled:YES];   // XcodeColor becomes bad and can't be using any more on my Mac!
    // Check out default colors:
    // Error : Red
    // Warn  : Orange
    
    DDLogError(@"Paper jam");                              // Red
    DDLogWarn(@"Toner is low");                            // Orange
    DDLogInfo(@"Warming up printer (pre-customization)");  // Default (black)
    DDLogVerbose(@"Intializing protcol x26");              // Default (black)
    
    // Now let's do some customization:
    // Info  : Pink
    
//#if TARGET_OS_IPHONE
//    UIColor *pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
//#else
//    NSColor *pink = [NSColor colorWithCalibratedRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
//#endif
//    
//    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];
    
    DDLogInfo(@"Warming up printer (post-customization)"); // Pink !
}


+(void)testFMDB
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dbPath]])
    {
        FMDatabase *db = [FMDatabase databaseWithPath:[self dbPath]];
        if (db.open)
        {
            NSString * sql = @"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'password' VARCHAR(30))";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                DDLogError(@"error when creating db table");
            } else {
                DDLogInfo(@"succ to creating db table");
            }
            
            [db close];
        }
        else
        {
            DDLogError(@"error when open db");
        }
    }
    
    [self testDeleteAll];
    [self testInsert];
    [self testQueryData];

    [self testDeleteAll];
    [self testQueryData];
    
    [self testDbQueue];
}

+(NSString *)dbPath
{
    NSString *dbPath = nil;
    if (dbPath == nil)
    {
        NSString * doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;;
        dbPath = [doc stringByAppendingPathComponent:@"user.sqlite"];
    }
    
    return dbPath;
}

+(void)testInsert
{
    DDLogInfo(@"Test Insert");
    
    static int count = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:[self dbPath]];
    if (db.open)
    {
        NSString * sql = @"insert into user (name, password) values(?, ?) ";
        NSString * name = [NSString stringWithFormat:@"tangqiao%d", count++];
        [db executeUpdate:sql, name, @"boy"];
        [db close];
    }
}

+(void)testQueryData
{
    DDLogInfo(@"Test Query");
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self dbPath]];
    if (db.open)
    {
        NSString * sql = @"select * from user";
        FMResultSet * rs = [db executeQuery:sql];
        
        BOOL hasRecord = NO;
        while (rs.next)
        {
            hasRecord = YES;
            int userId = [rs intForColumn:@"id"];
            NSString * name = [rs stringForColumn:@"name"];
            NSString * pass = [rs stringForColumn:@"password"];
            DDLogVerbose(@"user id = %d, name = %@, pass = %@", userId, name, pass);
        }
        
        if (!hasRecord)
        {
            DDLogWarn(@"No user records.");
        }
        
        [db close];
    }
}

+(void)testDeleteAll
{
    DDLogInfo(@"Test Delete All");
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self dbPath]];
    if (db.open)
    {
        NSString * sql = @"delete from user";
        [db executeUpdate:sql];
        
        [db close];
    }
}

+(void)testDbQueue
{
    DDLogInfo(@"Test DBQueue");
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[self dbPath]];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        
        [queue inDatabase:^(FMDatabase *db) {
            for (int i = 1; i < 10; ++i)
            {
                NSString * sql = @"insert into user (name, password) values(?, ?) ";
                NSString * name = [NSString stringWithFormat:@"queue111 %d", i];
                [db executeUpdate:sql, name, @"boy"];
            }
        }];
        
        [self testQueryData];
    });
    
    dispatch_async(q2, ^{
        [queue inDatabase:^(FMDatabase *db) {
             for (int i = 1; i < 10; ++i)
             {
                 NSString * sql = @"insert into user (name, password) values(?, ?) ";
                 NSString * name = [NSString stringWithFormat:@"queue222 %d", i];
                 [db executeUpdate:sql, name, @"boy"];
             }
         }];
        
        [self testQueryData];
    });
}

#pragma mark - Magic Record
+(void)testMagicRecord
{
    [self persistNewPersonWithFirstname:@"Daniel" lastname:@"Dong" age:@(36)];
    [self persistNewPersonWithFirstname:@"Roshen" lastname:@"Lei" age:@(26)];
    
    // Query to find all the persons store into the database
    NSArray *persons = [Person MR_findAll];
    DDLogVerbose(@"%@", persons);
    
    // Query to find all the persons store into the database order by their 'firstname'
    NSArray *personsSorted = [Person MR_findAllSortedBy:@"firstname" ascending:YES];
    DDLogInfo(@"%@", personsSorted);
    
    // Query to find all the persons store into the database which have 25 years old
    NSArray *personsWhoHave22 = [Person MR_findByAttribute:@"age" withValue:@(26)];
    DDLogWarn(@"%@", personsWhoHave22);
    
    // Query to find the first person store into the databe
    Person *person = [Person MR_findFirst];
    DDLogError(@"%@", person);
    
    [self updateAge:@(30) ofPersonWithFirstname:@"Daniel" lastname:@"Dong"];
    
    NSArray *personsWhoIs30 = [Person MR_findByAttribute:@"age" withValue:@(30)];
    DDLogWarn(@"%@", personsWhoIs30);
    
    [self deleteFirstPersonWithFirstname:@"Daniel"];
    persons = [Person MR_findAll];
    DDLogInfo(@"%@", persons);
    
    [self deleteFirstPersonWithFirstname:@"Roshen"];
}

+ (void)persistNewPersonWithFirstname:(NSString *)firstname lastname:(NSString *)lastname age:(NSNumber *)age
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Create a new Person in the current thread context
    Person *person = [Person MR_createInContext:localContext];
    person.firstname = firstname;
    person.lastname = lastname;
    person.age = age;
    
    // Save the modification in the local context
    // With MagicalRecords 2.0.8 or newer you should use the MR_saveNestedContexts
    [localContext MR_saveToPersistentStoreAndWait];
}



+ (void)updateAge:(NSNumber *)newAge ofPersonWithFirstname:(NSString *)firstname lastname:(NSString *)lastname
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Build the predicate to find the person sought
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstname ==[c] %@ AND lastname ==[c] %@", firstname, lastname];
    Person *personFounded = [Person MR_findFirstWithPredicate:predicate inContext:localContext];
    
    // If a person was founded
    if (personFounded)
    {
        // Update its age
        personFounded.age = newAge;
        // Save the modification in the local context
        // With MagicalRecords 2.0.8 or newer you should use the MR_saveNestedContexts
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

+ (void)deleteFirstPersonWithFirstname:(NSString *)firstname
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    // Retrieve the first person who have the given firstname
    Person *personFounded = [Person MR_findFirstByAttribute:@"firstname" withValue:firstname inContext:localContext];
    if (personFounded) {
        // Delete the person found
        [personFounded MR_deleteInContext:localContext];
        
        // Save the modification in the local context
        // With MagicalRecords 2.0.8 or newer you should use the MR_saveNestedContexts
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

@end
