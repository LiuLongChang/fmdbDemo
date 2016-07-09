//
//  ViewController.m
//  FMDB2
//
//  Created by 刘隆昌 on 14-12-30.
//  Copyright (c) 2014年 刘隆昌. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    
    IBOutlet UITextField *_name;
    
    IBOutlet UITextField *_age;
    
    IBOutlet UITextField *_sex;
    
    
    
    IBOutlet UIButton *_saveBtn;
    IBOutlet UIButton *_showBtn;
    IBOutlet UIButton *_selectBtn;
    IBOutlet UIButton *_deleteBtn;
    IBOutlet UIButton *_updateBtn;
    
    IBOutlet UITableView *_tableView;
    
    
}

@property(nonatomic,retain)NSMutableArray* dataArray;

@end

@implementation ViewController

-(void)loadView{
    
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"ViewController" owner:self options:nil] lastObject];
    self.dataArray = [[NSMutableArray alloc] init];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * ID = @"ID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSString* age =
    [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"age"];
    NSString * sex = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"sex"];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@ %@",age,sex];
    
    
    return cell;
}


- (IBAction)saveBtnAction:(id)sender {
    FMDatabase * database = [FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        
        return;
    }
    
    if (![database tableExists:@"user"]) {
        
        [database executeUpdate:@"create table user (id integer primary key autoincrement not null,name text,age integer,sex text)"];
    }
    
    
    FMResultSet * set = [database executeQuery:@"select* from user"];
    while ([set next]) {
        
        NSString * name = [set stringForColumn:@"name"];
        NSInteger age = [set intForColumn:@"age"];
        NSString * sex = [set stringForColumn:@"sex"];
        
        if ([name isEqualToString:_name.text] && [sex isEqualToString:_sex.text] && age==[_age.text intValue]) {
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"请别重复插入" message:@"repete" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            
            
            return;
        }
        
    }
    
    
    
    BOOL insert = [database executeUpdate:@"insert into user(name,age,sex) values (?,?,?)",_name.text,_age.text,_sex.text];
    
    if (insert) {
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alert show];
        
        
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:_name.text,@"name",_age.text,@"age",_sex.text,@"sex", nil];
        [self.dataArray addObject:dic];
        [_tableView reloadData];

        
    }else{
        NSLog(@"insert Failed");
    }
    
    [database close];
}

- (IBAction)showBtnAction:(id)sender {
    
    FMDatabase * database = [FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        return;
    }
    
    
    FMResultSet * resultSet = [database executeQuery:@"select* from user"];
    NSString * str = @"";
    while ([resultSet next]) {
        NSString * name = [resultSet stringForColumn:@"name"];
        NSInteger age = [resultSet intForColumn:@"age"];
        NSString * sex = [resultSet stringForColumn:@"sex"];
        str = [str stringByAppendingFormat:@"Name:%@,Age:%ld,Sex:%@\n",name,age,sex];
        
        
        
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",[NSString stringWithFormat:@"%ld",age],@"age",sex,@"sex", nil];
        
        [self.dataArray addObject:dic];
        NSLog(@"name:%@  age:%ld  sex:%@",name,age,sex);
        
    }
    
    [_tableView reloadData];
    [database close];
    
}
- (IBAction)selectBtnAction:(id)sender {
    
    FMDatabase * database = [FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        return;
    }
    
    FMResultSet * resultSet = [database executeQuery:@"select* from user where name = ?",_name.text];
    NSString * str = @"";
    [self.dataArray removeAllObjects];
    
    while ([resultSet next]) {
        NSString * name = [resultSet stringForColumn:@"name"];
        NSInteger age = [resultSet intForColumn:@"age"];
        NSString * sex = [resultSet stringForColumn:@"sex"];
        str = [str stringByAppendingFormat:@"Name:%@,Age:%ld,Sex:%@\n",name,age,sex];
        
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",[NSString stringWithFormat:@"%ld",age],@"age",sex,@"sex", nil];
        [self.dataArray addObject:dic];
        
    }
    
    if (self.dataArray.count == 0) {
        NSLog(@"没有查询到内容");
    }
    
    [_tableView reloadData];
    
    
}
- (IBAction)deletaBtnAction:(id)sender {
    
    FMDatabase * database = [FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        return;
    }
    
    FMResultSet * result = [database executeQuery:@"select* from user"];
    for (int i=0; i<self.dataArray.count; i++) {
        
        NSString * str = [[self.dataArray objectAtIndex:i] objectForKey:@"name"];
        while ([result next]) {
            
            [database executeUpdate:@"delete from user where name = ?",str];
            
            
        }

        
    }
    [self.dataArray removeAllObjects];
    BOOL delete = [database executeUpdate:@"delete from user where name = ?",_name.text];
    if (delete) {
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alert show];
        
    }
    
    [database close];
    [_tableView reloadData];
    
}

- (IBAction)updateBtnClick:(id)sender {
    
    FMDatabase * database = [FMDatabase databaseWithPath:[self databasePath]];
    if (![database open]) {
        return;
    }
    BOOL update = [database executeUpdate:@"update user set age = ? where name= ?",[NSNumber numberWithInt:20],@"chen"];
    if (update) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"更新成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alert show];
        
        
        
    }
    [database close];
    
    
    
}


-(NSString*)databasePath{
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString * dbPath = [path stringByAppendingPathComponent:@"user.db"];
    
 //   NSLog(@"xxssmm  %@",dbPath);
    return dbPath;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _saveBtn.layer.cornerRadius = 5;
    _showBtn.layer.cornerRadius = 5;
    _selectBtn.layer.cornerRadius = 5;
    _updateBtn.layer.cornerRadius = 5;
    _deleteBtn.layer.cornerRadius = 5;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
