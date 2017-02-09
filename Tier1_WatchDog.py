#!/usr/bin/env python
# -*- coding: utf-8 -*-

# notes: UTC +3 correction is hardcoded
import calendar
import datetime
import getopt
import logging
import re
import sys
import time

from pywinusb import hid
from simple_salesforce import Salesforce

#
UseTestVars = False


#
def printHelp():
    print (
        'Tier1_WatchDog.py -t <TimeToReact> -v <VendorID> -p <ProductID> -l <LoggingLevel> -c <CheckTimeOut> -q <Queue>')
    print ('Usage---------------------------------------------------------------------------')
    print ('"-t", "--TimeToReact" - smallest allowed FTR time before to trigger an action, min')
    print ('"-v", "--VendorID" - ID of USB relay Vendor, recommended: "0x20a0"')
    print ('"-p", "--ProductID" - ID of USB relay Product, recommended: "0x4173"')
    print ('"-l", "--LoggingLevel" - "DEBUG", "INFO" or "WARNING"')
    print ('"-c", "--CheckTimeOut" - frequency to check the queue, recommended: "20"')
    print ('"-q", "--Queue" - queue to watch, supported:')
    print ('      Tier German, ownerid "00G60000001Qw8xEAC" - type "German" as argument')
    print ('      Tier French, ownerid "00G60000001Qw8wEAC" - type "French" as argument')
    print ('      Tier Italian, ownerid "00G60000001Qw8yEAC" - type "Italian" as argument')
    print ('      Tier Europe, ownerid "00G60000001Qw8iEAC" - type "Europe" as argument')
    print ('Examples------------------------------------------------------------------------')
    print ('Tier1_WatchDog.py -t 30 -v 0x20a0 -p 0x4173 -l WARNING -c 20 -q German')


def startup(argv):
    TimeToReact = ''
    VendorID = ''
    ProductID = ''
    LoggingLevel = ''
    CheckTimeOut = ''
    Tier = ''
    try:
        opts, args = getopt.getopt(argv, "h:t:v:p:l:c:q:",
                                   ["help=", "TimeToReact=", "VendorID=", "ProductID=", "LoggingLevel=",
                                    "CheckTimeOut=", "Queue="])
    except getopt.GetoptError:
        printHelp()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            printHelp()
            sys.exit()
        elif opt in ("-t", "--TimeToReact"):
            TimeToReact = arg
        elif opt in ("-v", "--VendorID"):
            VendorID = arg
        elif opt in ("-p", "--ProductID"):
            ProductID = arg
        elif opt in ("-l", "--LoggingLevel"):
            LoggingLevel = arg
        elif opt in ("-c", "--CheckTimeOut"):
            CheckTimeOut = arg
        elif opt in ("-q", "--Queue"):
            Tier = arg
    if TimeToReact == '' or VendorID == '' or ProductID == '' or LoggingLevel == '' or CheckTimeOut == '' or Tier == '':
        print('Invalid arguments supplied. See help.')
        print('TimeToReact:', TimeToReact)
        print('VendorID:', VendorID)
        print('ProductID:', ProductID)
        print('LoggingLevel:', LoggingLevel)
        print('CheckTimeOut:', CheckTimeOut)
        print('Tier:', Tier)
        sys.exit(2)
    else:
        return TimeToReact, VendorID, ProductID, LoggingLevel, CheckTimeOut, Tier


### Initial vars
if not sys.argv[1:]:
    print('Started without arguments, s: "-h" or "--help"')
    if UseTestVars:
        ### Test vars
        TimeToReact = 100
        vendor_id = 0x20a0
        product_id = 0x4173
        LoggingLevel = 'INFO'
        CheckTimeOut = 20
        ownerid = '00G60000001Qw8xEAC'
    else:
        sys.exit(2)
        ###
else:
    TimeToReact = int(startup(sys.argv[1:])[0])
    vendor_id = int(startup(sys.argv[1:])[1], 16)
    product_id = int(startup(sys.argv[1:])[2], 16)
    LoggingLevel = str(startup(sys.argv[1:])[3])
    CheckTimeOut = int(startup(sys.argv[1:])[4])
    Tier = str(startup(sys.argv[1:])[5])
    if Tier == 'German':
        ownerid = '00G60000001Qw8xEAC'
    elif Tier == 'French':
        ownerid = '00G60000001Qw8wEAC'
    elif Tier == 'Italian':
        ownerid = '00G60000001Qw8yEAC'
    elif Tier == 'Europe':
        ownerid = '00G60000001Qw8iEAC'
    else:
        print(
            "This Tier isn't supported. Please, open a feature request. P.S.: input is very case-sensitiveand and the names of the countries should be inputted as 'Russia' instead of 'russia'. Have a respect! ^_^")
        sys.exit(2)
if LoggingLevel == 'DEBUG':
    logging.basicConfig(filename='Tier1_WatchDog.DEBUG.log', level=logging.DEBUG, format='%(asctime)s %(message)s')
elif LoggingLevel == 'INFO':
    logging.basicConfig(filename='Tier1_WatchDog.INFO.log', level=logging.INFO, format='%(asctime)s %(message)s')
else:
    logging.basicConfig(filename='Tier1_WatchDog.log', level=logging.WARNING, format='%(asctime)s %(message)s')
logging.warning('----------------------------------------------------------------------------------------------')
logging.warning('Starting new log')
### Hid Lab
hid_devices = hid.HidDeviceFilter(vendor_id=vendor_id).get_devices()
if not hid_devices:
    print('ERROR: no USB relayes found, stopping...')
    sys.exit(2)
for device in hid_devices:
    device.open()
    print('DEVICE ', device.vendor_name, ' is ready')
target_usage = hid.get_full_usage_id(0xff00, 0x00)  # generic vendor page, usage_id = 0
usage_found = False
for report in device.find_feature_reports():
    if target_usage in report:
        # usage found
        report.get()
        usage_found = True
if not usage_found:
    print("The target device was found, but the requested usage does not exist!\n")
    logging.warning("The target device was found, but the requested usage does not exist!\n")
    sys.exit(2)


def get_current_state():
    old_raw_data = report.get_raw_data()
    logging.debug("  Empty raw report: {0}".format(old_raw_data))
    return format(old_raw_data)


def relay_off():
    value = [0xE7, 0x19, 0x19, 0, 0, 0, 0, 0]  # off
    report[target_usage] = value
    new_raw_data = report.get_raw_data()
    print('Relay is off')
    logging.debug("  Set raw report: {0}\n".format(new_raw_data))
    report.set_raw_data(new_raw_data)
    report.send()


def relay_on():
    value = [0xE7, 0x00, 0x00, 0, 0, 0, 0, 0]  # on
    report[target_usage] = value
    new_raw_data = report.get_raw_data()
    print('Relay is on')
    logging.debug("  Set raw report: {0}\n".format(new_raw_data))
    report.set_raw_data(new_raw_data)
    report.send()


def test():
    x = 0
    while x < 2:
        relay_on()
        time.sleep(0.5)
        relay_off()
        x += 1
        time.sleep(0.5)


# finishing
def stop():
    relay_off()
    device.close()
    print('Device is closed')
    logging.info('Device is closed')
    exit()


###

# close relay if open
CurrentRelayState = get_current_state()
logging.info('Initial state is: ' + CurrentRelayState)
if CurrentRelayState == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or CurrentRelayState == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
    # print('relay is already off')
    NeedToPanic = False
else:
    relay_off()
    logging.warning('Need to initially deactivate relay')
    time.sleep(1)
sf = Salesforce(username='user', password='password',
                security_token='security_token')
NAIN = False

# here we will start the LOOP
while 1:
    string = str(sf.query("SELECT caseNumber FROM case where status ='New' and ownerid ='" + ownerid + "'"))
    NumCasesFound = re.findall(r"totalSize', (\w+)", string)
    NumCasesFound = int(NumCasesFound[0])
    CaseIDs = re.findall(r"'url', '/services/data/v29.0/sobjects/Case/(\w+)", string)
    logging.debug('CaseIDs ' + str(CaseIDs))
    CaseNumbers = re.findall(r"'CaseNumber', '(\w+)", string)
    logging.debug('CaseNumbers ' + str(CaseNumbers))
    w, h = 4, NumCasesFound
    FoundCasesArray = [[0 for x in range(w)] for y in range(h)]

    for i in range(NumCasesFound):
        FoundCasesArray[i][0] = CaseNumbers[i]
        FoundCasesArray[i][1] = CaseIDs[i]
        ResultOfQuery = str(
            sf.query("SELECT targetdate FROM casemilestone where caseid ='" + FoundCasesArray[i][1] + "'"))
        logging.debug(ResultOfQuery)
        TargetDate = re.findall(r"'TargetDate', '(\w+[-]\w+[-]\w+[:]\w+)", ResultOfQuery)
        FoundCasesArray[i][2] = TargetDate[0]
        SLA = time.mktime(datetime.datetime.strptime(TargetDate[0],
                                                     "%Y-%m-%dT%H:%M").timetuple()) + 10800.0  # hardcoded correction for UTC+3
        # SLA = calendar.timegm(time.gmtime())-10800.0 #test for violated SLA
        SLAleft = int((SLA - calendar.timegm(time.gmtime())) // 60)
        FoundCasesArray[i][3] = SLAleft

    logging.debug(FoundCasesArray)
    NeedToPanic = False
    for SLAleftCheck in FoundCasesArray:
        if SLAleftCheck[3] < TimeToReact:
            CurrentRelayState = get_current_state()
            if CurrentRelayState == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or CurrentRelayState == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
                print('Case', SLAleftCheck[0], SLAleftCheck[3], '<', TimeToReact, 'Need to react')
                logging.warning('Case ' + str(SLAleftCheck[0]) + ' ' + str(SLAleftCheck[3]) + '<' + str(
                    TimeToReact) + ': Relay will be on')
            NeedToPanic = True
        else:
            logging.info('Case ' + str(SLAleftCheck[0]) + ' ' + str(SLAleftCheck[3]) + '>' + str(
                TimeToReact) + ': No need to react')
            # print('Case', SLAleftCheck[0], SLAleftCheck[3], '>', TimeToReact, 'No need to react')
    if NeedToPanic:
        relay_on()
    else:
        CurrentRelayState = get_current_state()
        if CurrentRelayState == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or CurrentRelayState == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
            if not NAIN == True:
                print('No action is needed because no burning cases were found')
                NAIN = True
        else:
            relay_off()
            NAIN = False
            logging.warning('No potential violations found, closing the relay')
    time.sleep(CheckTimeOut)
