classdef VL53L0X < arduinoio.LibraryBase & matlab.mixin.CustomDisplay
    % VL53L0X Create a VL53L0X device object
    %
    % To begin with connect to an Arduino Uno board on COM port 3 on Windows (change as needed)
    % a = arduino('COM3','Uno','Libraries','Adafruit/VL53L0X');
    %
	% Create the sensor object
    % v = addon(a,'Adafruit/VL53L0X');
    %
	% Initialize the VL53L0X - use this before taking measurements
    % begin(v);
    %
	% Read the sensor
    % mm=RangeMilliMeter(v);
    %
  
    % Define command IDs for all public methods of the class object
    properties(Access = private, Constant = true)
        VL53L0X_CREATE          = hex2dec('00')
        VL53L0X_BEGIN           = hex2dec('01')
        VL53L0X_RANGEMILLIMETER = hex2dec('02')
        VL53L0X_DELETE          = hex2dec('03')
    end  
    
    % Include all the source files
    properties(Access = protected, Constant = true)
        LibraryName = 'Adafruit/VL53L0X'
        DependentLibraries = {}
        ArduinoLibraryHeaderFiles = 'Adafruit_VL53L0X/Adafruit_VL53L0X.h'
		CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'VL53L0X.h')
        CppClassName = 'VL53L0X'
    end
    
    properties(Access = private)
        ResourceOwner = 'Adafruit/VL53L0X';
    end
    
    methods(Hidden, Access = public)
		% Connect to a VL53L0X device connected to pins A4 and A5 on the Arduino.
		%
		% Syntax:
		% v = addon(a,'Adafruit/VL53L0X');
		
        function obj = VL53L0X(parentObj)
            obj.Parent = parentObj;
			obj.Pins = {'A4','A5'};
            count = getResourceCount(obj.Parent,obj.ResourceOwner);
            % Since this example allows implementation of only one VL53L0X
            % error out if resource count is more than 0
            if count > 0
                error('You can only have one VL53L0X');
            end 
            incrementResourceCount(obj.Parent,obj.ResourceOwner);    
            createVL53L0X(obj);
        end
    
        function createVL53L0X(obj)
            try
                % Initialize command ID for each method for appropriate handling by
                % the commandHandler function in the wrapper class.
                cmdID = obj.VL53L0X_CREATE;
                
                % Allocate the pins connected to the VL53L0X
                configurePinResource(obj.Parent,'A4',obj.ResourceOwner,'I2C');
                configurePinResource(obj.Parent,'A5',obj.ResourceOwner,'I2C');
                
                % Call the sendCommand function to link to the appropriate method in the Cpp wrapper class
                sendCommand(obj, obj.LibraryName, cmdID, []);
            catch e
                throwAsCaller(e);
            end
        end
	end

    methods(Access = protected)
        function delete(obj)
            try
                parentObj = obj.Parent;
                % Clear the pins that have been configured to the VL53L0X
                for iLoop = obj.Pins
                    configurePinResource(parentObj,iLoop{:},obj.ResourceOwner,'Unset');
                end
                % Decrement the resource count for the VL53L0X
                decrementResourceCount(parentObj, obj.ResourceOwner);
                cmdID = obj.VL53L0X_DELETE;
                sendCommand(obj, obj.LibraryName, cmdID, []);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
        end  
    end

    methods(Access = public)
        function begin(obj)
            % Initialize command ID for each method for appropriate handling by
            % the commandHandler function in the wrapper class.
            cmdID = obj.VL53L0X_BEGIN;
            success = sendCommand(obj, obj.LibraryName, cmdID, []);
			if ~success
				error('Error initializing the VL53L0X');
			end
        end
    end
    
    methods(Access = public)
        % Read the sensor
        function out = rangeMilliMeter(obj)
            cmdID = obj.VL53L0X_RANGEMILLIMETER;  
            out = sendCommand(obj, obj.LibraryName, cmdID, []);
			out = 256*out(1)+out(2);
        end
    end
	
	methods (Access = protected)
        function displayScalarObject(obj)
            header = getHeader(obj);
            disp(header);
                        
            % Display main options
            fprintf('               Pins: ''%s''(SDA), ''%s''(SCL)\n', obj.Pins{1}, obj.Pins{2});
            fprintf('\n');
                  
            % Allow for the possibility of a footer.
            footer = getFooter(obj);
            if ~isempty(footer)
                disp(footer);
            end
        end
    end
end
