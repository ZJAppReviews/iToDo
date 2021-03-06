//
//  AddToDoViewController.m
//  iToDo
//
//  Created by Bilal ARSLAN on 07/07/14.
//  Copyright (c) 2014 Bilal ARSLAN. All rights reserved.
//

#import "AddToDoViewController.h"
#import "DBManager.h"

@interface AddToDoViewController ()

@property (nonatomic, strong) DBManager *dbManager;

-(void)loadInfoToView;
@end

@implementation AddToDoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtTitle.delegate = self;
    self.txtDesc.delegate = self;
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFileName:@"iToDoDb.sql"];
    
    //  Check if should load specific to edit.
    if (self.self.recordIDToEdit != -1)
    {
        [self loadInfoToView];
    }
    [self check];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) check
{
    if ([self.editButton.title isEqualToString:@"Edit"])
    {
        self.txtDesc.editable = NO;
        self.txtTitle.enabled = NO;
        self.navigationItem.title = @"iToDo";
    }
    else
    {
        self.txtDesc.editable = YES;
        self.txtTitle.enabled = YES;
        self.navigationItem.title = @"Add iToDo";
    }
}

-(void)loadInfoToView
{
    //  Create a query to find all inf. from db
    NSString *query = [NSString stringWithFormat:@"select * from todoInfo where todoInfoID=%d", self.recordIDToEdit];
    
    //  Load the relevant data.
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDBWithQuery:query]];
    
    //  Set the loaded data to the textfields
    self.txtTitle.text = [[results objectAtIndex:0] objectAtIndex:1];
    self.txtDesc.text = [[results objectAtIndex:0] objectAtIndex:2];
}

#pragma mark - Keyboard Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Save Button
- (IBAction)SaveToDo:(id)sender
{
    if ([self.editButton.title isEqualToString:@"Edit"])
    {
        [self.editButton setTitle:@"Save"];
        self.txtDesc.editable = YES;
        self.txtTitle.enabled = YES;
        self.navigationItem.title = @"Edit iToDo";
    }
    else
    {
        //  Dismissing Keyboard
        [self.txtDesc resignFirstResponder];
        [self.txtTitle resignFirstResponder];
        
        //  Warning if title field is emtpy.
        if ([self.txtTitle.text isEqualToString:@""] || [self.txtTitle.text isEqual:nil]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Fill the Title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
             return;
        }
        
        [self.editButton setTitle:@"Edit"];
        self.txtDesc.editable = NO;
        self.txtTitle.enabled = NO;
        self.navigationItem.title = @"iToDo";
        
        bool typeOfQuery = NO;

        
        //  Prepare the query string.
        NSString *query;
        
        if (self.recordIDToEdit == -1)
        {
            query = [NSString stringWithFormat:@"insert into todoInfo values(null, '%@', '%@')", self.txtTitle.text, self.txtDesc.text];
            NSLog(@"The query is: %@", query);
            typeOfQuery = YES;
        }
        else
        {
            query = [NSString stringWithFormat:@"update todoInfo set title='%@', description='%@' where todoInfoID=%d", self.txtTitle.text, self.txtDesc.text, self.recordIDToEdit];
            NSLog(@"The query is: %@", query);
        }
        
        
        
        //  Execute the query.
        [self.dbManager executeQuery:query];
        
        //  If query was succesfully executed then pop the view controller.
        if (self.dbManager.affectedRows != 0)
        {
            
            if(typeOfQuery)
            {
                NSLog(@"-----------------------------------------------------------------------------------------");
                NSLog(@"Query was executed succesfully. Affected rows = %d", self.dbManager.affectedRows);
                NSLog(@"Added Todo Name: %@", self.txtTitle.text);
                NSLog(@"-----------------------------------------------------------------------------------------");
            }
            else
            {
                NSLog(@"-----------------------------------------------------------------------------------------");
                NSLog(@"Query was executed succesfully. Affected rows = %d", self.dbManager.affectedRows);
                NSLog(@"Updated Todo Name: %@", self.txtTitle.text);
                NSLog(@"-----------------------------------------------------------------------------------------");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update" message:@"Succesfull operation!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            //  Inform the delegate that editing was finished.
            [self.delegate editingInfoWasFinished];
            
            //  Pop the view controller
            if (self.recordIDToEdit == -1)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            NSLog(@"Could not ecexute the query");
        }
    }
}

@end
