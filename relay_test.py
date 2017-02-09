#!/usr/bin/env python
# -*- coding: utf-8 -*-

#Sample that shows how to use vid 0x20a0 pid 0x4173 USB HID device.
#Use python 3.5 or above
#If you cannot find your answer here: https://msdn.microsoft.com/en-us/windows/hardware/drivers/hid/introduction-to-hid-concepts feel free to ask me direct: dremsama-at-gmail-dot-com

from pywinusb import hid #посмотрите примеры использования этой библиотеки на https://github.com/rene-aguirre/pywinusb
import time
vendor_id = 0x20a0
product_id = 0x4173

### Для начала нам нужно найти usage feature report-а (см. терминовлогию MS) HID девайся, который мы хотим использовать.
hid_devices = hid.HidDeviceFilter(vendor_id = vendor_id).get_devices()
if hid_devices == []:
    print('ERROR: no USB relayes found, stopping...')
    sys.exit(2)
for device in hid_devices:
    device.open()
    print('DEVICE ',device.vendor_name, ' is ready')
target_usage = hid.get_full_usage_id(0xff00, 0x00) # generic vendor page, usage_id = 0, т.к. это первая и, в нашем случае, единственная фтча девайса 
usage_found = False 
for report in device.find_feature_reports():
                    if target_usage in report:
                        #usage found
                        report.get()
                        usage_found = True
if not usage_found:
            print("The target device was found, but the requested usage does not exist!\n")
            sys.exit(2)

def get_current_state():
    old_raw_data = report.get_raw_data()
    return format(old_raw_data)

def relay_switch(mode):
    if mode =='ON':
        value = [0xE7,0x00,0x00,0,0,0,0,0] #on #как выяснилось из примера, предоставленного разработчиками, этот массив переменных открывает релей,
    elif mode =='OFF':
        value = [0xE7,0x19,0x19,0,0,0,0,0] #off #а этот закрывает
    report[target_usage] = value
    new_raw_data = report.get_raw_data()
    report.set_raw_data( new_raw_data )
    report.send()
def test():
    x=0
    while x <2:
        relay_switch('ON')
        print('Relay is ON')
        time.sleep(1)
        relay_switch('OFF')
        print('Relay is OFF')
        x=x+1
        time.sleep(0.5)
       
#finishing - не забываем закрывать handle девайсa, чтобы избежать конфликтов
def stop():
    relay_switch('OFF') #закроем релей, на всякий случай.
    device.close()
    print('Device is closed')

#Starting test:
test()
#stop()
