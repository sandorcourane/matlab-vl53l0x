/*
 * VL53L0X.h
 *
 * This is a C++ wrapper class to link the incoming byte streams to its corresponding
 * command handler in the Arduino source code.
 */

// Inherit from the LibraryBase class and Adafruit_VL53L0X header file
#include "LibraryBase.h"
#include "Adafruit_VL53L0X.h"

const char MSG_CREATE_VL53L0X[]               PROGMEM = "Arduino::lox->createVL53L0XObject();\n";
const char MSG_DELETE_VL53L0X[]               PROGMEM = "Arduino::lox->deleteVL53L0XObject();\n";
const char MSG_FAILED_TO_BOOT[]               PROGMEM = "Failed to boot VL53L0X\n";
const char MSG_OUT_OF_RANGE[]                 PROGMEM = "Out of range\n";
const char MSG_BEGIN[]                        PROGMEM = "Arduino::lox->begin();\n";
const char MSG_RANGEMILLIMETER[]              PROGMEM = "Arduino::lox->rangeMilliMeter();\n";

#define VL53L0X_CREATE                             0x00
#define VL53L0X_BEGIN                              0x01
#define VL53L0X_RANGEMILLIMETER                    0x02
#define VL53L0X_DELETE                             0x03

VL53L0X_RangingMeasurementData_t measure;

// Define the constructor
class VL53L0X : public LibraryBase
{
public:
    Adafruit_VL53L0X *lox;
    
public:
    VL53L0X(MWArduinoClass& a)
    {
        libName = "Adafruit/VL53L0X";
        a.registerLibrary(this);
    }
    
// Override the commandHandler, mapping each command ID to appropriate methods     
public:
    void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
    {
        switch(cmdID)
        {
			case VL53L0X_CREATE:
			{
				createVL53L0XObject();
				sendResponseMsg(cmdID, 0, 0);
				break;
			}
            case VL53L0X_BEGIN:  //initialize VL53L0X, return 1 or 0 on success or failure
            {
                byte success[1] = {begin()};
				sendResponseMsg(cmdID, success, 1);
				break;
            }
            case VL53L0X_RANGEMILLIMETER:  //get measure in mm, return as two bytes. If object is out of range value returned is 0
            {
                uint16_t milliMeter = rangeMilliMeter();
				byte high = highByte(milliMeter);
				byte low = lowByte(milliMeter);
				byte mm[2] = {high,low};
                sendResponseMsg(cmdID, mm, 2);
                break;
            }
			case VL53L0X_DELETE:  //delete
            {
                deleteVL53L0XObject();
                sendResponseMsg(cmdID, 0, 0);
                break;
            }
            default:
            {
                // Do nothing
                break;
            }
        }
    }

// Wrap VL53L0X methods to add debug messages
public:
	void createVL53L0XObject()
	{
		debugPrint(MSG_CREATE_VL53L0X);
		lox = new Adafruit_VL53L0X();
	}

    byte begin()
    {
        debugPrint(MSG_BEGIN);
		boolean success = lox->begin();
        if (!success) {
			debugPrint(MSG_FAILED_TO_BOOT);
			return 0;
		} else {
			return 1;
		}
    }
    
    uint16_t rangeMilliMeter()
    {
		debugPrint(MSG_RANGEMILLIMETER);
        lox->rangingTest(&measure, false);
		if (measure.RangeStatus != 4) {
			return measure.RangeMilliMeter;
		} else {
			debugPrint(MSG_OUT_OF_RANGE);
			return 0;
		}
    }
	
	void deleteVL53L0XObject()
	{
		debugPrint(MSG_DELETE_VL53L0X);
		delete lox;
	}
};
