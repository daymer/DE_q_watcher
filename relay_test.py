"""
Sample to show how to use vid 0x20a0 pid 0x4173 USB HID device.
Use python 3.5 or above
If you can't find your answer here:
https://msdn.microsoft.com/en-us/windows/hardware/drivers/hid/introduction-to-hid-concepts
Feel free to ask me directly: dremsama-at-gmail-dot-com
"""

from pywinusb import hid  # check https://github.com/rene-aguirre/pywinusb for more examples
import time
import sys
vendor_id = 0x20a0
product_id = 0x4173
device = True

# First we need to find a usage feature of report of the device we plan to use
hid_devices = hid.HidDeviceFilter(vendor_id=vendor_id).get_devices()
if hid_devices is []:
    print('ERROR: no USB relays were found, stopping...')
    sys.exit(2)
for device in hid_devices:
    device.open()
    print('DEVICE ', device.vendor_name, ' is ready')


target_usage = hid.get_full_usage_id(0xff00, 0x00)
# a generic vendor page, usage_id = 0 since we are looking for a first (and single) feature of our device

usage_found = False
for report in device.find_feature_reports():
                    if target_usage in report:  # which means that a usage found
                        report.get()
                        usage_found = True
if not usage_found:
            print("The target device was found, but the requested usage does not exist!\n")
            sys.exit(2)


def get_current_state():
    old_raw_data = report.get_raw_data()
    return format(old_raw_data)


def relay_switch(mode):
    value = None
    if mode == 'ON':
        value = [0xE7, 0x00, 0x00, 0, 0, 0, 0, 0]  # As I get from a vendor's example, this set of vars opens a relay
    elif mode == 'OFF':
        value = [0xE7, 0x19, 0x19, 0, 0, 0, 0, 0]  # and this closes it
    report[target_usage] = value
    new_raw_data = report.get_raw_data()
    report.set_raw_data(new_raw_data)
    report.send()


def test():
    x = 0
    while x < 2:
        relay_switch('ON')
        print('Relay is ON')
        time.sleep(1)
        relay_switch('OFF')
        print('Relay is OFF')
        x += 1
        time.sleep(0.5)
       

def stop():  # don't forget to free device before stopping your app
    relay_switch('OFF')
    device.close()
    print('Device is closed')


test()
