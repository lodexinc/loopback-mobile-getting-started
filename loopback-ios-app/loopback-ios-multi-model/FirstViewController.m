//
//  FirstViewController.m
//  loopback-ios-multi-model
//
//  Created by Matt Schmulen on 7/24/13.
//  Copyright (c) 2013 StrongLoop All rights reserved.
//


/*
 Tab 1, Step 1
 
 This Tab shows you how to Create Read Update and Delete Model (CRUD) types and persist to the LoopBack server,
 
 The code sections in the methods below show Create Update & Delete Operations
 - ( void ) getModels
 - ( void ) createNewModel
 - ( void ) updateExistingModel
 - ( void ) deleteExistingModel
 
 You will need to have your Loopback Node server running
 
 You can start your Loopback Node server from the command line terminal with $slc run app.js from within the loopback-nodejs-server/ folder
 
 You can find developer doc's for LoopBack here:
 http://docs.strongloop.com/loopback
 
 */

#import "FirstViewController.h"
#import "AppDelegate.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *tableData;
@end

@implementation FirstViewController

- (NSArray *) tableData
{
    if ( !_tableData) _tableData = [[NSArray alloc] init];
    return _tableData;
};

- ( void ) getModels
{
    // ++++++++++++++++++++++++++++++++++++
    // The block below gets all the 'product' models from the server
    // ++++++++++++++++++++++++++++++++++++
    
    // Define the load success block for the LBModelPrototype allWithSuccess message
    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
        NSLog( @"selfSuccessBlock %d", models.count);
        self.tableData  = models;
        [self.myTableView reloadData];
        // [self showGuideMessage:@"Great! you just pulled code from node"];
    };//end selfSuccessBlock
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
        [AppDelegate showGuideMessage: @"No Server Found"];
    };//end selfFailblock
    
    //Get a local representation of the 'products' model type
    LBModelRepository *prototype = [ [AppDelegate adapter]  repositoryWithModelName:@"products"];
    
    // Invoke the allWithSuccess message for the 'products' LBModelPrototype
    // Equivalent http JSON endpoint request : http://localhost:3000/api/products
    
    [prototype allWithSuccess: loadSuccessBlock failure: loadErrorBlock];
};


- ( void ) createNewModel
{
    // ++++++++++++++++++++++++++++++++++++
    // The block below to creates a new 'product' model on the server
    // ++++++++++++++++++++++++++++++++++++
    
    //Get a local representation of the 'products' model type
    LBModelRepository *prototype = [ [AppDelegate adapter]  repositoryWithModelName:@"products"];
    
    //create new LBModel of type
    LBModel *model = [prototype modelWithDictionary:@{ @"name": @"New Product", @"inventory" : @99, @"price" :@13.34 , @"units-sold" : @44 }];
    
    // Define the load success block for saveNewSuccessBlock message
    void (^saveNewSuccessBlock)() = ^() {
        [AppDelegate showGuideMessage: @"Tab 'One' CreateSuccess"];
        
        // call a 'local' refresh to update the tableView
        [self getModels];
    };
    
    // Define the load error functional block
    void (^saveNewErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error on Save %@", error.description);
        [AppDelegate showGuideMessage: @"No Server Found"];
    };
    
    //Persist the newly created Model to the LoopBack node server
    [model saveWithSuccess:saveNewSuccessBlock failure:saveNewErrorBlock];
};

- ( void ) updateExistingModel
{
    // ++++++++++++++++++++++++++++++++++++
    //  The block below first finds the model with id = 2 and then updates the 'inventory' parameter on the server
    // ++++++++++++++++++++++++++++++++++++
    
    // Define your success functional block
    void (^findSuccessBlock)(LBModel *) = ^(LBModel *model) {
        //dynamically add an 'inventory' variable to this model type before saving it to the server
        model[@"inventory"] = @"66";
        
        //Define the save error block
        void (^saveErrorBlock)(NSError *) = ^(NSError *error) {
            NSLog( @"Error on Save %@", error.description);
        };
        
        void (^saveSuccessBlock)() = ^() {
            [AppDelegate showGuideMessage: @"Tab 'One' UpdateSuccess"];
            
            // call a 'local' refresh to update the tableView
            [self getModels];
        };
        [model saveWithSuccess:saveSuccessBlock failure:saveErrorBlock];
    };
    
    // Define the find error functional block
    void (^findErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error No model found with ID %@", error.description);
        [AppDelegate showGuideMessage: @"No Server Found"];
    };
    
    //Get a local representation of the 'products' model type
    LBModelRepository *prototype = [ [AppDelegate adapter]  repositoryWithModelName:@"products"];
    
    //Get the instance of the model with ID = 2
    // Equivalent http JSON endpoint request : http://localhost:3000/products/2
    [prototype findById:@2 success:findSuccessBlock failure:findErrorBlock ];
    
}//end updateExistingModelAndPushToServer

- ( void ) deleteExistingModel
{
    // ++++++++++++++++++++++++++++++++++++
    //  The block below first finds the model with id = 2 and then deletes the model from the server
    // ++++++++++++++++++++++++++++++++++++
    
    // Define your success functional block
    void (^findSuccessBlock)(LBModel *) = ^(LBModel *model) {
        
        //Define the save error block
        void (^removeErrorBlock)(NSError *) = ^(NSError *error) {
            NSLog( @"Error on Save %@", error.description);
        };
        void (^removeSuccessBlock)() = ^() {
            [AppDelegate showGuideMessage: @"Tab 'One' DeleteSuccess"];
            
            // call a 'local' refresh to update the tableView
            [self getModels];
        };
        
        //Destroy this model instance on the LoopBack node server
        [ model destroyWithSuccess:removeSuccessBlock failure:removeErrorBlock ];
    };
    
    // Define the find error functional block
    void (^findErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error No model found with ID %@", error.description);
        [AppDelegate showGuideMessage: @"No Server Found"];
    };
    
    //Get a local representation of the 'products' model type
    LBModelRepository *prototype = [ [AppDelegate adapter]  repositoryWithModelName:@"products"];
    
    //Get the instance of the model with ID = 2
    // Equivalent http JSON endpoint request : http://localhost:3000/api/products/2
    [prototype findById:@2 success:findSuccessBlock failure:findErrorBlock ];
    
}//end deleteExistingModel

- (IBAction)actionRefresh:(id)sender {
    [self getModels];
}

- (IBAction)actionCreate:(id)sender {
    [self createNewModel];
}

- (IBAction)actionUpdate:(id)sender {
    [self updateExistingModel];
}

- (IBAction)actionDelete:(id)sender {
    [self deleteExistingModel];
}

// UITableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if ( [[ [self.tableData objectAtIndex:indexPath.row] class] isSubclassOfClass:[LBModel class]])
    {
        LBModel *model = (LBModel *)[self.tableData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                               [model objectForKeyedSubscript:@"name"] ,
                               [model objectForKeyedSubscript:@"inventory"] ];
    }
    return cell;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate initializeServerWithData];
    [AppDelegate showGuideMessage: @"Tab 'One' Step1"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
