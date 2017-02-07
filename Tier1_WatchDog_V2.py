# notes: UTC +3 correction is hardcoded
import calendar
import datetime
import getopt
import logging
import re
import sys
import time
import signal

from pywinusb import hid
from simple_salesforce import Salesforce

UseTestVars = False

def printHelp():
        print (
            'Tier1_WatchDog.py -t <TimeToReact> -v <VendorID> -p <ProductID> -l <LoggingLevel> -c <CheckTimeOut> -q <Queue>')
        print ()
        print ('Usage-------------------------VERSION 2-----------------------------------------')
        print ('"-t", "--TimeToReact": smallest allowed FTR time before to trigger an action, min')
        print ('"-v", "--VendorID": ID of USB relay Vendor, recommended: "0x20a0"')
        print ('"-p", "--ProductID": ID of USB relay Product, recommended: "0x4173"')
        print ('"-l", "--LoggingLevel": "DEBUG", "INFO" or "WARNING"')
        print ('"-c", "--CheckTimeOut": frequency to check the queue, recommended: "20"')
        print ('"-q", "--Queue": queue to watch, supported:')
        print ('  Tier German: type "German" as argument')
        print ('  Tier French: type "French" as argument')
        print ('  Tier Italian: type "Italian" as argument')
        print ('  Tier Europe: type "Europe" as argument')
        print ('OPTIONAL: "-u", "--Users": "FirstName LastName, FirstName LastName, FirstName LastName"')
        print ('                    Use "," (comma) as separator, start and finish with " sing')
        print ('OPTIONAL: "-s", "--Snooze": True or False')
        print ()
        print ('Examples------------------------------------------------------------------------')
        print ('python Tier1_WatchDog_V2.py -t 30 -v 0x20a0 -p 0x4173 -l WARNING -c 20 -q German '
               '-u "Dmitriy Rozhdestvenskiy"')


def startup(argv):
        TimeToReact = ''
        VendorID = ''
        ProductID = ''
        LoggingLevel = ''
        CheckTimeOut = ''
        Tier = ''
        users = ''
        snooze = ''
        try:
            opts, args = getopt.getopt(argv, "h:t:v:p:l:c:q:u:s:",
                                       ["help=", "TimeToReact=", "VendorID=", "ProductID=", "LoggingLevel=",
                                        "CheckTimeOut=", "Queue=", "Users=", "Snooze="])
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
            elif opt in ("-u", "--Users"):
                users = arg
            elif opt in ("-s", "--Snooze"):
                snooze = arg
        if TimeToReact == '' or VendorID == '' or ProductID == '' or LoggingLevel == '' or CheckTimeOut == '' or Tier == '':
            print('Invalid arguments supplied. See help.')
            print('TimeToReact:', TimeToReact)
            print('VendorID:', VendorID)
            print('ProductID:', ProductID)
            print('LoggingLevel:', LoggingLevel)
            print('CheckTimeOut:', CheckTimeOut)
            print('Tier:', Tier)
            print('Users:', users)
            sys.exit(2)
        else:
            return TimeToReact, VendorID, ProductID, LoggingLevel, CheckTimeOut, Tier, users, snooze

# Initial vars
if not sys.argv[1:]:
    print('Started without arguments, s: "-h" or "--help"')
    if UseTestVars is True:
        # Test vars
        TimeToReact = 100
        vendor_id = 0x20a0
        product_id = 0x4173
        LoggingLevel = 'INFO'
        CheckTimeOut = 20
        Tier = 'German'
        ownerid = '00G60000001Qw8xEAC'
        users = 'Dmitriy Ovsyannikov, Dmitriy Mironov, Dmitriy Rozhdestvenskiy'.split(",")
        snooze = True
    else:
        sys.exit(2)
        ###
else:
    TimeToReact = int(startup(sys.argv[1:])[0])
    vendor_id = int(startup(sys.argv[1:])[1], 16)
    product_id = int(startup(sys.argv[1:])[2], 16)
    LoggingLevel = str(startup(sys.argv[1:])[3])
    CheckTimeOut = int(startup(sys.argv[1:])[4])
    snooze = bool(startup(sys.argv[1:])[7])
    users = str(startup(sys.argv[1:])[6])
    if users != '':
        users = users.split(",")
    else:
        users = ''
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
logging.warning('Version 2.0')
# print('-t ' + str(TimeToReact) + ' -l ' + str(LoggingLevel) + ' -c ' + str(CheckTimeOut) + ' -q ' + str(Tier) +
#      ' users: ' + str(users) + ' Snooze ' + str(snooze))
# Hid Lab
hid_devices = hid.HidDeviceFilter(vendor_id=vendor_id).get_devices()
if not hid_devices:
    print('ERROR: no USB relays found, stopping...')
    sys.exit(2)
for device in hid_devices:
    device.open()
    print('DEVICE ' + device.vendor_name + ' is ready')
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

def signal_handler(signal, frame):
    print('Stopping...')
    stop()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
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

sf = Salesforce(username='user@veeam.com', password='password',
                security_token='token')
ownerIDsWITHOwner = []
if users != '':
    for user in users:
        if user.startswith(" "): user = user[1:]
        string = str(sf.query("SELECT Id FROM user WHERE Name like '" + user + "'"))
        UserID = re.findall(r"'Id', '(\w+)", string)
        ownerIDsWITHOwner.append([user, str(UserID[0])])
    ownerIDsWITHOwner.append([Tier, ownerid])
else:
    ownerIDsWITHOwner.append([Tier, ownerid])


# print (str(datetime.datetime.time(datetime.datetime.now())) + ' Starting Loop')

NEIN = False
# LOOP Starts here
while 1:
    TotalCases = 0
    CaseIDsTotal = []
    CaseNumbersTotal = []
    for ownerID in ownerIDsWITHOwner:
        statusToCheck = ['OPEN', 'NEW']
        for status in statusToCheck:
            string = str(sf.query("SELECT caseNumber FROM case WHERE status ='" + status + "' and ownerid ='" + ownerID[1] + "'"))
            NumCasesFound = re.findall(r"totalSize', (\w+)", string)
            NumCasesFound = int(NumCasesFound[0])
            CaseNumbers = re.findall(r"'CaseNumber', '(\w+)", string)
            for i in range(len(CaseNumbers)):
                temp=[CaseNumbers[i], ownerID[0]]
                CaseNumbers[i] = temp
            CaseIDs = re.findall(r"'url', '/services/data/v29.0/sobjects/Case/(\w+)", string)
            TotalCases += NumCasesFound
            CaseIDsTotal += CaseIDs
            CaseNumbersTotal += CaseNumbers
    if CaseNumbersTotal == []:
        time.sleep(CheckTimeOut)
        if snooze is True:
            # print ('snooze starts')
            relay_off()
    else:
        w, h = 5, TotalCases
        FoundCasesArray = [[0 for x in range(w)] for y in range(h)]
        for i in range(TotalCases):
            FoundCasesArray[i][0] = CaseNumbersTotal[i]
            FoundCasesArray[i][1] = CaseIDsTotal[i]
            ResultOfQuery = str(
                sf.query("SELECT targetdate, IsCompleted FROM casemilestone where caseid ='" + FoundCasesArray[i][1] + "'"))
            IsCompleted = re.findall(r"'IsCompleted', (\w+)", ResultOfQuery)
            TargetDate = re.findall(r"'TargetDate', '(\w+[-]\w+[-]\w+[:]\w+)", ResultOfQuery)
            FoundCasesArray[i][2] = TargetDate[0]
            FoundCasesArray[i][4] = IsCompleted[0]
            SLA = time.mktime(datetime.datetime.strptime(TargetDate[0],
                                                         "%Y-%m-%dT%H:%M").timetuple()) + 10800.0  # hardcoded correction for UTC+3
            # SLA = calendar.timegm(time.gmtime())-10800.0 #test for violated SLA
            SLAleft = int((SLA - calendar.timegm(time.gmtime())) // 60)
            FoundCasesArray[i][3] = SLAleft

        logging.debug(FoundCasesArray)
        # print (FoundCasesArray)
        # print ('Total cases found:' + str(len(FoundCasesArray)))

        NeedToPanic = False
        for SLA in FoundCasesArray:
            # noinspection PyUnboundLocalVariable
            if SLA[4] != "True":
                logging.warning ('in case ' + SLA[0][0] + ', owned by ' + SLA[0][1] + ' first response wasn\'t sent yet....')
                if SLA[3] < TimeToReact:
                    CurrentRelayState = get_current_state()
                    if CurrentRelayState == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or CurrentRelayState == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
                        print ('WARNING! In case ' + SLA[0][0] + ', owned by ' + SLA[0][1] + 'SLA will expire in ' + str(SLA[3]))
                        logging.warning('Case ' + SLA[0][0] + ' ' + str(SLA[3]) + '<' + str(TimeToReact) + ': Relay will be on')
                        NeedToPanic = True
                else:
                    logging.warning('            SLA will expire in ' + str(SLA[3]) + ' - there is no need to react right now')
                   # print('     SLA in case ' + SLA[0][0] + ' will expire in ' + str(SLA[3]) + ' - there is no need to react right now')

        if NeedToPanic:
                relay_on()
        else:
                CurrentRelayState = get_current_state()
                if CurrentRelayState == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or CurrentRelayState == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
                    if NEIN is not True:
                        print('No action is needed because no burning cases were found')
                        NEIN = True
                else:
                    relay_off()
                    NEIN = False
                    logging.warning('No potential violations found, closing the relay')
        # print (str(datetime.datetime.time(datetime.datetime.now())) + ' Ending Loop')
        time.sleep(CheckTimeOut)
        if snooze is True:
            # print ('snooze starts')
            relay_off()