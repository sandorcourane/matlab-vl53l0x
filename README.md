# matlab-vl53l0x
Matlab Arduino add-on library for the Adafruit VL53L0X sensor
This is a Matlab extension that allows Matlab to receive distance data from the VL53L0X Time of Flight distance sensor. It
wraps the Adafruit libraries in Matlab compatible code.

Requirements:
Matlab - this extension is tested with R2017a and may or may not work with earlier versions
the Matlab hardware support package for Arduino
Arduino software
the Adafruit_VL53L0X libraries installed through Arduino

Usage:
Put the extension somewhere on a drive and add it to Matlab with addpath; you can verify it was found with the
listArduinoLibraries command; you should see "Adafruit/VL53L0X" in the list.
Create an Arduino object in Matlab with
>> a = arduino('COM3','Uno','Libraries','Adafruit/VL53L0X')
(using your correct com port and board type.)
Create a sensor object with
>> v = addon(a,'Adafruit/VL53L0X')
Initialize the sensor before taking measurements
>> begin(v)
Now the device is ready to read distance
>> mm = rangeMilliMeter(v)
