% SetupApt
function hAPT = SetupAPT()

hAPT = AptController();

try,
    hAPT.Initialize();
catch ME
        h=warndlg({['Error:',ME.identifier],'Could not initialize ThorLabs APT Controller.'},'Warning!','modal');
        waitfor(h);
        delete(hAPT);   
        hAPT = [];
end