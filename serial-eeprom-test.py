#!/usr/bin/env python

import serial
import random

class Eeprom:
    """
    """

    READ  = 0xA5
    WRITE = 0x3C

    #-------------------------#
    def __init__(self, device):
        """
        Creates EEPROM Handler

        Parameters:
            device (str) : a path of a serial device file
        """

        # open serial port with device
        self.port = serial.Serial(device, baudrate=9600)

    #------------------------------#
    def read(self, address, length):
        """
        Reads Bytes from EEPROM

        Parameters:
            address (int) : a start address of data to read
            length  (int) : a length of data to read

        Return:
            data (bytes) : data read from device
        """

        # create command parameters
        command = [self.READ, address, length]

        # convert parameters into bytes
        message = bytes(command)

       #for byte in abc:
       #    #
       #    print('{:02X}'.format(byte), end=' ')

       #print()

        # send data bytes
        self.port.write(message)

        # receive data bytes
        data = self.port.read(length)

        return data

    #-----------------------------#
    def write(self, address, data):
        """
        Writes Bytes into EEPROM

        Parameters:
            address (int)   : a start address of data to write
            data    (bytes) : data to write
        """

        # get data length
        length = len(data)

        # create command parameters
        command = [self.WRITE, address, length]

        # convert parameters into bytes
        message = bytes(command) + data

       #for byte in abc:
       #    #
       #    print('{:02X}'.format(byte), end=' ')

       #print()

        # send data bytes
        self.port.write(message)

        # receive data byte
        data = self.port.read(1)

class Test:
    """
    EEPROM Test Case
    """

    #-----------------#
    def __init__(self):
        """
        Creates Test Case
        """

        # create communication handler
        self.eeprom = Eeprom('/dev/ttyUSB0')

    #----------------------------#
    def generate_write_data(self):
        """
        """

        # define eeprom write sizes
        sizes = [1, 2, 4, 8, 16]

        # generate random size
        item = random.randrange(len(sizes))

        # select generated size
        length = sizes[item]

        # generate random address
        address = random.randrange(0, 32, length)

        # create base values
        data = random.randbytes(length)

        return address, data

    #------------#
    def run(self):
        """
        Executes Test Case
        """

        # generate random data block
        address, write = self.generate_write_data()

        print(address)
        print(len(write))

        # write bytes into eeprom
        self.eeprom.write(address, write)

        # read bytes from eeprom
        read = self.eeprom.read(address, len(write))

        # when data bytes are same
        if read == write:
            # 
            print('passed')

        # when data bytes are not same
        else:
            # 
            print('failed')

        # generate random data block
        address, write = self.generate_write_data()

        print(address)
        print(len(write))

        # write bytes into eeprom
        self.eeprom.write(address, write)

        # read bytes from eeprom
        read = self.eeprom.read(address, len(write))

        # when data bytes are same
        if read == write:
            # 
            print('passed')

        # when data bytes are not same
        else:
            # 
            print('failed')

test = Test()

test.run()
