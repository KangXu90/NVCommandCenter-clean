classdef TrackerEventData < event.EventData
   properties
      NewData
   end

   methods
      function data = TrackerEventData(myData)
         data.NewData= myData;
      end
   end
end
