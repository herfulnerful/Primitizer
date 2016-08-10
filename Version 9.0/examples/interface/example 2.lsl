// Dialog constants
integer LINK_INTERFACE_DEBUG = 17000;

integer LINK_INTERFACE_ENABLE_DEBUG = 17001;
integer LINK_INTERFACE_DISABLE_DEBUG = 17002;


integer LINK_INTERFACE_ADD = 15002;
integer LINK_INTERFACE_CANCEL = 14012;
// Cancel is hit for LINK_INTERFACE_NUMERIC
integer LINK_INTERFACE_CANCELLED = 14006; // Message sent from LINK_INTERFACE_CANCEL
integer LINK_INTERFACE_CLEAR = 15001;


integer LINK_INTERFACE_DIALOG = 14001;
integer LINK_INTERFACE_NOTIFY = 14004;
integer LINK_INTERFACE_NOT_FOUND = 15010;
integer LINK_INTERFACE_NUMERIC = 14005;
integer LINK_INTERFACE_RESHOW = 14011;
// A button is hit, or OK is hit for LINK_INTERFACE_NUMERIC
integer LINK_INTERFACE_RESPONSE = 14002;
integer LINK_INTERFACE_SHOW = 15003;
integer LINK_INTERFACE_SOUND = 15021;
integer LINK_INTERFACE_TEXTBOX = 14007;
// No button is hit, or Ignore is hit
integer LINK_INTERFACE_TIMEOUT = 14003;

string DIALOG_SEPERATOR = "||";
integer DIALOG_TIMEOUT = 30;
// ********** DIALOG FUNCTIONS **********
string dialog_command(string message, list buttons, list returns, integer timeout)
{
    string packed_message = message + DIALOG_SEPERATOR + (string)timeout;
    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++) packed_message += DIALOG_SEPERATOR + llList2String(buttons, i) + DIALOG_SEPERATOR + llList2String(returns, i);
    return packed_message;
}

string numeric_command(integer value, string message, integer timeout)
{
    string packed_message =  (string)value + DIALOG_SEPERATOR + message + DIALOG_SEPERATOR + (string)timeout;
    return packed_message;
}

dialog_show(string name, key id)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_SHOW, name, id);
}

dialog_reshow()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_RESHOW, "", NULL_KEY);
}
dialog_cancel()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_CANCEL, "", NULL_KEY);
    llSleep(1);
}

add_menu(key id, string message, list buttons, list returns, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_ADD, dialog_command(message, buttons, returns, timeout), id);
}
//Return string prefix. If empty, only user's input will be returned.
add_textbox(key id, string message, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_TEXTBOX, message + DIALOG_SEPERATOR + (string)timeout, id);
}

add_numeric(key id, integer value, string message, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_NUMERIC, numeric_command(value, message, timeout), id);
}

dialog_sound(string sound, float volume)
{
	llMessageLinked(LINK_THIS, LINK_INTERFACE_SOUND, sound + DIALOG_SEPERATOR + (string)volume, NULL_KEY);
}

dialog_clear()
{
	llMessageLinked(LINK_THIS, LINK_INTERFACE_CLEAR, "", NULL_KEY);
}
// ********** END DIALOG FUNCTIONS **********
 
 
default{
    state_entry()
	{
        dialog_clear();
		
		dialog_sound("18cf8177-a388-4c1c-90e7-e5750e83d750", 1.0);
        
		add_menu("MainMenu",

            "Main Menu Dialog Message", // Dialog Messages

            [ "BUTTON_1", "BUTTON_2", "BUTTON_3", "Debug", "Textbox", "Numberbox", "BUTTON_X" ], // Dialog Buttons

            [ "MENU_SubMenu1", "MENU_SubMenu2", "MENU_SubMenu3", "Debug", "Textbox", "Numeric", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu1",

            "Sub Menu 1 Dialog Message", // Dialog Messages

            [ "SUB_1_1", "SUB_1_2", "SUB_1_3", "MAIN MENU", "SUB_3", "BUTTON_X" ], // Dialog Buttons

            [ "1.1", "1.2", "1.3", "MENU_MainMenu", "MENU_SubMenu3", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu2",

            "Sub Menu 2 Dialog Message", // Dialog Messages

            [ "SUB_2_1", "SUB_2_2", "SUB_2_3", "MAIN MENU", "SUB_1", "BUTTON_X" ], // Dialog Buttons

            [ "2.1", "2.2", "2.3", "MENU_MainMenu", "MENU_SubMenu1", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );

        add_menu("SubMenu3",

            "Sub Menu 3 Dialog Message", // Dialog Messages

            [ "SUB_3_1", "SUB_3_2", "SUB_3_3", "MAIN MENU", "SUB_2", "BUTTON_X" ], // Dialog Buttons

            [ "3.1", "3.2", "3.3", "MENU_MainMenu", "MENU_SubMenu2", "EXIT" ], // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );
        
        llSetText("Touch me to show menu", <1,1,1>, 1);
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
		if(num == LINK_INTERFACE_ENABLE_DEBUG)
		{
			llSay(0, "Debug State Enabled");
		}
		else if(num == LINK_INTERFACE_DISABLE_DEBUG)
		{
			llSay(0, "Debug State Disabled");
		}
		else if(num == LINK_INTERFACE_NOT_FOUND)
		{
			llSay(0, "Menu name: " + str + " Not Found");
		}
        if(num == LINK_INTERFACE_TIMEOUT)
        {
            llOwnerSay("Menu time-out. Please try again.");
        }
		else if(num == LINK_INTERFACE_CANCELLED)
		{
			llSay(0, "Dialog Cancelled");
		}
        else if(num == LINK_INTERFACE_RESPONSE)
        {
            llWhisper(0, str);
            if(str == "Debug")
            {
                llMessageLinked(LINK_THIS, LINK_INTERFACE_DEBUG, "", llDetectedOwner(0));
            }
            else if(str == "Textbox")
            {
                // Add Dialog Textbox
                add_textbox(id,
                    
                    "Textbox Demo",
                    
					DIALOG_TIMEOUT
				);
            }
            else if(str == "Numeric")
            {

                // Add Number Dialog
                add_numeric(id,

					1000, // current value

					// Dialog message here
					"Current Value = {VALUE}",

					[0, 1, 2, 3, 4, 5, 6, 7, 8, 9], //buttons

					DIALOG_TIMEOUT // Dialog Timeout
				);
            }
        }
    }

    touch_start(integer num_detected)
    {
        dialog_show("SubMenu1", llDetectedOwner(0));
		//llMessageLinked(LINK_THIS, LINK_INTERFACE_SHOW, "", llDetectedOwner(0));
        //llSleep(2);
        //llMessageLinked(LINK_THIS, LINK_INTERFACE_DEBUG, "", llDetectedOwner(0));
    }
}