//
//  AppDelegate.m
//  DigitalOcean Indicator
//
//  Created by Eric J. Duran on 4/27/14.
//  Copyright (c) 2014 ericduran. All rights reserved.
//
// EXECUSE THE MESS, I was just hacking stuff together.
// 

#import "AppDelegate.h"
#include <Python.h>

@implementation AppDelegate
NSStatusItem *statusItem;
NSMenu *theMenu;
NSMenu *subMenu;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    // Lets try to get some python code running.
    PyObject *pName, *pModule, *pDict, *pFunc, *pArgs, *pValue;
    NSString *nsString;
    NSString *drop_ip = @"IP: ";
    NSString *drop_size = @"Size: ";

    
    
    NSMenuItem *tItem = nil;
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    subMenu = [[NSMenu alloc] initWithTitle:@""];
    
    [theMenu setAutoenablesItems:NO];
    
    
    Py_Initialize();
    const char *pypath = [[[NSBundle mainBundle] resourcePath] UTF8String];

    // Add our project path to the python path.
    PyObject *sys = PyImport_Import(PyString_FromString("sys"));
    PyObject *sys_path_append = PyObject_GetAttrString(PyObject_GetAttrString(sys, "path"), "append");
    PyObject *resourcePath = PyTuple_New(1);
    PyTuple_SetItem(resourcePath, 0, PyString_FromString(pypath));
    PyObject_CallObject(sys_path_append, resourcePath);

    // import digitalocean
    PyObject *digitalocean = PyImport_Import(PyString_FromString("digitalocean"));

    // TODO:
    // HOW THE HELL DO YOU PASS IN the damn args to the manager instance, try every possible way.
    // gave up for now, I'm just hard-coding my credentials in the python manager class.
    PyObject *manager = PyObject_GetAttrString(digitalocean, "Manager");
    PyObject *managerInst = PyObject_CallObject(manager, NULL);

    PyObject* objectsRepresentation = PyObject_Repr(managerInst);
    NSLog(@"Object represents: %s", PyString_AsString(objectsRepresentation));
    
    PyObject *my_func = PyObject_GetAttrString(managerInst, "get_all_droplets");
//    objectsRepresentation = PyObject_Repr(my_func);
//    NSLog(@"func represents: %s", PyString_AsString(objectsRepresentation));

    
//    NSLog(@"func represents: %d",     PyCallable_Check(my_func));
    if (my_func && PyCallable_Check(my_func)){
        PyObject *result = PyObject_CallObject(my_func, NULL);
        if(result != NULL){
//            objectsRepresentation = PyObject_Repr(result);
//            NSLog(@"func represents: %s", PyString_AsString(objectsRepresentation));

            
            
            PyObject *item = PyList_GetItem(result, 0);
            
            PyObject *name = PyObject_GetAttrString(item, "name");
            NSString *drop_name = [NSString stringWithUTF8String: PyString_AsString(name)];
            PyObject *ip = PyObject_GetAttrString(item, "ip_address");
            NSString *i_ip = [NSString stringWithUTF8String: PyString_AsString(ip)];

            
            NSLog(@"name: %s", PyString_AsString(name));
            NSLog(@"ip: %s", PyString_AsString(ip));
            
            // START OF SUB MENU LOOP
            // This is what we need to loop
            NSMenuItem *item1 = [theMenu addItemWithTitle:drop_name action:NULL keyEquivalent:@""];
            NSMenu *onTheFlyMenu = [[NSMenu alloc] initWithTitle:@"utilities"];
            
            [onTheFlyMenu addItemWithTitle:[drop_ip stringByAppendingString:i_ip] action:nil keyEquivalent:@""];
//            [onTheFlyMenu addItemWithTitle:@"Type: Debian 7.x x64" action:nil keyEquivalent:@""];
//            [onTheFlyMenu addItemWithTitle:@"Region: New York 1" action:nil keyEquivalent:@""];
//            [onTheFlyMenu addItemWithTitle:@"Size: 512MB" action:nil keyEquivalent:@""];
            [onTheFlyMenu addItem:[NSMenuItem separatorItem]];
            [onTheFlyMenu addItemWithTitle:@"View on the web" action:@selector(terminate:) keyEquivalent:@""];
            [onTheFlyMenu addItemWithTitle:@"Reboot" action:@selector(terminate:) keyEquivalent:@""];
            [onTheFlyMenu addItemWithTitle:@"Power Off" action:@selector(terminate:) keyEquivalent:@""];
            [item1 setSubmenu:onTheFlyMenu];
            
            // END OF SUB MENU LOOP

        }
    }

    
    // Sets the menu seperator
    [theMenu addItem:[NSMenuItem separatorItem]];

    tItem = [theMenu addItemWithTitle:@"Preferences" action:@selector(terminate:) keyEquivalent:@"p"];
    tItem = [theMenu addItemWithTitle:@"Refresh" action:@selector(terminate:) keyEquivalent:@"r"];
    tItem = [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];

    
    [tItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"digital.png"]];
    [statusItem setToolTip:@"Digital Ocean Status"];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:theMenu];

}

-(void)onHandleFour:(id) sender
{
    NSLog(@"You selected Four");
}

@end
