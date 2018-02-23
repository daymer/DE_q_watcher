import logging
from pywinusb import hid
from time import time
import time

class HidDevice:
    def __init__(self, vendor_id: int, product_id: int):
        self.logger_inst = logging.getLogger()
        self.vendor_id = vendor_id
        self.product_id = product_id
        hid_devices = hid.HidDeviceFilter(vendor_id=vendor_id).get_devices()
        if hid_devices is []:
            self.logger_inst.error('ERROR: no USB relays found, stopping...')
            exit(2)
        for device in hid_devices:
            self.device = device
            self.device.open()
            self.logger_inst.info('DEVICE ' + str(device.vendor_name) + ' is ready')
        self.target_usage = hid.get_full_usage_id(0xff00, 0x00)  # generic vendor page, usage_id = 0
        usage_found = False
        for report in self.device.find_feature_reports():
            if self.target_usage in report:
                # usage found
                self.report = report
                self.report.get()
                usage_found = True
        if not usage_found:
            self.logger_inst.warning("The target device was found, but the requested usage does not exist!\n")
            exit(2)

    def is_relay_closed(self):
        old_raw_data = self.report.get_raw_data()
        self.logger_inst.debug("Empty raw report: {0}".format(old_raw_data))
        if old_raw_data == '[0, 0, 0, 0, 0, 0, 0, 0, 0]' or old_raw_data == '[0, 231, 25, 25, 0, 0, 0, 0, 0]':
            return True
        else:
            return False

    def relay_off(self):
        value = [0xE7, 0x19, 0x19, 0, 0, 0, 0, 0]  # off
        self.report[self.target_usage] = value
        new_raw_data = self.report.get_raw_data()
        self.logger_inst.info('Relay is off')
        logging.debug("Set raw report: {0}".format(new_raw_data))
        self.report.set_raw_data(new_raw_data)
        self.report.send()
        time.sleep(1)

    def relay_on(self):
        value = [0xE7, 0x00, 0x00, 0, 0, 0, 0, 0]  # on
        self.report[self.target_usage] = value
        new_raw_data = self.report.get_raw_data()
        print('Relay is on')
        logging.debug("Set raw report: {0}".format(new_raw_data))
        self.report.set_raw_data(new_raw_data)
        self.report.send()

    def test(self):
        x = 0
        while x < 2:
            self.relay_on()
            time.sleep(0.5)
            self.relay_off()
            x += 1
            time.sleep(0.5)

    def stop(self):
        # used to close device after usage
        self.relay_off()
        self.device.close()
        print('Device is closed')
        logging.info('Device is closed')
        exit(0)

