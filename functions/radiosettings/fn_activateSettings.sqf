#include "component.hpp"

if !(isClass (configFile >> "CfgPatches" >> "tfar_core")) exitWith {
    systemChat "radiosettings: not activated (tfar < 1.0)";
};

private _loadoutWaitCondition = if (isClass (missionConfigFile >> "CfgFunctions" >> "GRAD_loadout")) then {{player getVariable ["GRAD_loadout_applicationCount", 0] > 0}} else {true};
[_loadoutWaitCondition, {
    if ((assignedItems player) select 3 == "") exitWith {systemChat "radiosettings: No radio in loadout."};

    [] call grad_missionSetup_fnc_waitForRadioInit;
    [{player getVariable ["grad_radiosReceived",false]}, {
        [{
            private _activeLR = [] call TFAR_fnc_activeLrRadio;
            if (!isNil "_activeLR") then {
                private _settings = switch (side player) do {
                    case (WEST): {tf_freq_west_lr};
                    case (EAST): {tf_freq_east_lr};
                    case (INDEPENDENT): {tf_freq_guer_lr};
                    default {tf_freq_west_lr};
                };
                [call TFAR_fnc_activeLrRadio, _settings] call TFAR_fnc_setLrSettings;
            };

            private _activeSR = [] call TFAR_fnc_activeSwRadio;
            if (!isNil "_activeSR") then {
                private _settings = switch (side player) do {
                    case (WEST): {tf_freq_west};
                    case (EAST): {tf_freq_east};
                    case (INDEPENDENT): {tf_freq_guer};
                    default {tf_freq_west};
                };
                [call TFAR_fnc_activeSwRadio, _settings] call TFAR_fnc_setSwSettings;
            };

            systemChat "radiosettings: activated";
            GRAD_radioSettingsActivated = true;
        }, [], 1] call CBA_fnc_waitAndExecute;
    }, []] call CBA_fnc_waitUntilAndExecute;
}, []] call CBA_fnc_waitUntilAndExecute;
