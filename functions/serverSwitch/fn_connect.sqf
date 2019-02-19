#include "\A3\Ui_f\hpp\defineResincl.inc"

#define UI_DIRECTCONNECTTIMEOUT        5

params [["_port",2302], ["_password", nil]];

diag_log format ["Attempting direct connect to port %1", _port];
GRAD_Briefing_directConnectPort = _port;
GRAD_Briefing_password = _password;

onEachFrame {
    GRAD_Briefing_directConnectStartTime = diag_tickTime;

    private _displayMain = findDisplay IDD_MAIN;
    private _ctrlServerBrowser = _displayMain displayCtrl IDC_MAIN_MULTIPLAYER;
    ctrlActivate _ctrlServerBrowser;

    onEachFrame {
        ctrlActivate (findDisplay IDD_MULTIPLAYER displayCtrl IDC_MULTI_TAB_DIRECT_CONNECT);

        onEachFrame {
            private _ctrlServerAddress = findDisplay IDD_IP_ADDRESS displayCtrl 2300;
            _ctrlServerAddress controlsGroupCtrl IDC_IP_ADDRESS ctrlSetText "arma.gruppe-adler.de";

            _ctrlServerAddress controlsGroupCtrl IDC_IP_PORT ctrlSetText str GRAD_Briefing_directConnectPort;

            ctrlActivate (_ctrlServerAddress controlsGroupCtrl IDC_OK);

            onEachFrame {
                private _ctrlServerList = findDisplay IDD_MULTIPLAYER displayCtrl IDC_MULTI_SESSIONS;

                private _exit = for "_i" from 0 to ((lbSize _ctrlServerList) - 1) do {
                    ([_ctrlServerList lbText _i,_ctrlServerList lbData _i]) call {
                        params [["_serverName",""],["_serverData",""]];

                        if (diag_tickTime > (GRAD_Briefing_directConnectStartTime + UI_DIRECTCONNECTTIMEOUT)) exitWith {
                            diag_log format ["direct connect on port %1 timed out", GRAD_Briefing_directConnectPort];
                            onEachFrame {};
                            true
                        };

                        if (_serverData isEqualTo format ["138.201.30.228:%1",GRAD_Briefing_directConnectPort]) exitWith {
                            findDisplay IDD_MULTIPLAYER displayCtrl IDC_MULTI_SESSIONS lbSetCurSel _i;

                            onEachFrame {
                                ctrlActivate (findDisplay IDD_MULTIPLAYER displayCtrl IDC_MULTI_JOIN);

                                onEachFrame {
                                    if (diag_tickTime > GRAD_Briefing_directConnectStartTime + UI_DIRECTCONNECTTIMEOUT) then {
                                        diag_log format ["direct connect on port %1 timed out", GRAD_Briefing_directConnectPort];
                                        onEachFrame {};
                                    };

                                    if (!isNull findDisplay IDD_PASSWORD) then {
                                        private _display = findDisplay IDD_PASSWORD;
                                        private _passwordEditBoxCtrl = _display displayCtrl IDC_PASSWORD;

                                        // no password saved by CBA --> abort here so user can enter password
                                        if (!isNull _passwordEditBoxCtrl && {ctrlText _passwordEditBoxCtrl == ""} && ({isNil "GRAD_Briefing_password"} || {GRAD_Briefing_password == ""})) exitWith {
                                            onEachFrame {};
                                        };

                                        if (ctrlText _passwordEditBoxCtrl == "" && {GRAD_Briefing_password != ""} ) then {
                                           _passwordEditBoxCtrl ctrlSetTextColor [0,0,0,0];
                                           _passwordEditBoxCtrl ctrlSetText GRAD_Briefing_password;
                                        };

                                        ctrlActivate (_display displayCtrl IDC_OK);
                                    };

                                    if (getClientStateNumber >= 3) then {
                                        diag_log "RCTS Success";
                                        onEachFrame {};
                                    };
                                };
                            };

                            true
                        };

                        false
                    };

                    if (_exit) exitWith {};
                };
            };
        };
    }
};
