# notes: UTC +3 correction is hardcoded
from simplecrypt import encrypt, decrypt
import calendar
from datetime import datetime
import getopt
import logging
import re
import sys
import time
import signal
import argparse
from Hid_lib import HidDevice

from pywinusb import hid
from simple_salesforce import Salesforce
import simple_salesforce

##############################################################
#                      Test variables                        #
UseTestVarsSwitch = False
TestVars = {
        'TimeToReact': 100,
        'vendor_id': 0x20a0,
        'product_id': 0x4173,
        'LoggingLevel': 'DEBUG',
        'CheckTimeOut': 20,
        'Tier': 'German',
        'owner_id': '00G60000001Qw8xEAC',
        'users': 'Dmitriy Ovsyannikov, Dmitriy Mironov, Dmitriy Rozhdestvenskiy'.split(","),
        'snooze': True
    }
#                                                            #
##############################################################

if UseTestVarsSwitch is True:
    TimeToReact = TestVars['TimeToReact']
    vendor_id = TestVars['vendor_id']
    product_id = TestVars['product_id']
    LoggingLevel = TestVars['LoggingLevel']
    CheckTimeOut = TestVars['CheckTimeOut']
    Tier = TestVars['Tier']
    users = TestVars['users']
    snooze = TestVars['snooze']
else:
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--TimeToReact", type=str)
    parser.add_argument("-v", "--VendorID", type=int)
    parser.add_argument("-p", "--ProductID", type=int)
    parser.add_argument("-l", "--LoggingLevel", type=str)
    parser.add_argument("-c", "--CheckTimeOut", type=str)
    parser.add_argument("-q", "--Queue", type=str)
    parser.add_argument("-u", "--Users", type=str)
    parser.add_argument("-s", "--Snooze", type=str)
    args = parser.parse_args()
    TimeToReact = args.TimeToReact
    vendor_id = args.VendorID
    product_id = args.ProductID
    LoggingLevel = args.LoggingLevel
    CheckTimeOut = args.CheckTimeOut
    Tier = args.Queue
    users = args.Users
    snooze = args.Snooze

if Tier is None:
    print('Started without arguments, test mode will be used if possible')
    locals().update(TestVars)

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
logger_inst = logging.getLogger()
logger_inst.setLevel(LoggingLevel)
log_name = "Logs\Tier1_WhatchDog" + str(datetime.now().strftime("%Y-%m-%d_%H_%M_%S")) + '_v3.log'
fh = logging.FileHandler(log_name)
fh.setLevel(LoggingLevel)
fh.setFormatter(formatter)
logger_inst.addHandler(fh)
ch = logging.StreamHandler()
ch.setLevel(LoggingLevel)
ch.setFormatter(formatter)
logger_inst.addHandler(ch)

logger_inst.info('----------------------------------------------------------------------------------------------')
logger_inst.info('Starting new log')

try:
    Relay_inst = HidDevice(vendor_id=vendor_id, product_id=product_id)
    IsRelayClosed = Relay_inst.is_relay_closed()

    if IsRelayClosed is True:
        NeedToPanic = False
    else:
        logging.info('Closing relay, since it\'s opened for some reason')
        Relay_inst.relay_off()

except Exception as error:
    logging.error('Failed to initialise relay due to the following error:\n'+str(error))
    exit(1)


def save_credentials_dialog():
    username_def = input("\nusername\n")
    password_def = input("\npassword\n")
    security_token_def = input("\nsecurity_token\n")
    logging.info('Watcher will proceed as ' + str(username_def) + '. Should we store your credentials for future use?')
    store_credentials_dialog = input("\ntype y or n\n")
    if store_credentials_dialog == 'y':
        logging.info('Storing credentials using machine based encryption key')


        logging.info('Credentials were saved')
    else:
        logging.info('Using credentials for this session only')
    return username_def, password_def, security_token_def


SF_username = None
SF_password = None
SF_security_token = None
SF_connected = False
try:
    logging.info('Trying to load previously saved credentials if any were saved on this machine')
    # here we are loading saved user credentials if any exists

except Exception:
    logging.error('No saved credentials were found, prompting save-creds dialog')
    SF_username, SF_password, SF_security_token = save_credentials_dialog()


while SF_connected is False:
    try:
        SF_connection = Salesforce(username=SF_username, password=SF_password, security_token=SF_security_token)
        SF_connected = True

    except simple_salesforce.exceptions.SalesforceAuthenticationFailed as error:
        logging.error('Failed to connect to SalesForce due to the following error:\n' + str(error))
        logging.info('Need to find any better credentials, please, submit them here:')
        SF_username, SF_password, SF_security_token = save_credentials_dialog()
    except TypeError as error:
        logging.error('Failed to connect to SalesForce due to the following error:\n' + str(error))
        logging.info('Need to find any better credentials, please, submit them here:')
        SF_username, SF_password, SF_security_token = save_credentials_dialog()


