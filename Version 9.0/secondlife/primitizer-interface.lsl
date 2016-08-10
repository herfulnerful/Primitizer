// Enable/Disable Debug Mode
integer LINK_INTERFACE_DEBUG = 17000; // Send message too LINK_INTERFACE_ENABLE_DEBUG or LINK_INTERFACE_DISABLE_DEBUG based on toggle state

// Debug Mode Enabled
integer LINK_INTERFACE_ENABLE_DEBUG = 17001;

// Debug Mode Disabled
integer LINK_INTERFACE_DISABLE_DEBUG = 17002;

// Add Menus To Interface API
integer LINK_INTERFACE_ADD = 15002;

// Cancel Dialog Request
integer LINK_INTERFACE_CANCEL = 14012;

// Cancel Is Hit For LINK_INTERFACE_NUMERIC
integer LINK_INTERFACE_CANCELLED = 14006; // Message sent from LINK_INTERFACE_CANCEL to link message to be used in other scripts.

// Clear Dialog Request
integer LINK_INTERFACE_CLEAR = 15001;

// Display Dialog Interface
integer LINK_INTERFACE_DIALOG = 14001;

// Notify Dialog Type
integer LINK_INTERFACE_NOTIFY = 14004;

// Dialog Not Found
integer LINK_INTERFACE_NOT_FOUND = 15010;

// Display Numeric Interface
integer LINK_INTERFACE_NUMERIC = 14005;

// Reshow Last Dialog Displayed
integer LINK_INTERFACE_RESHOW = 14011;

// A Button Is Hit, Or OK Is Hit For LINK_INTERFACE_NUMERIC
integer LINK_INTERFACE_RESPONSE = 14002;

// Display Dialog
integer LINK_INTERFACE_SHOW = 15003;

// Play Sound When Dialog Button Touched
integer LINK_INTERFACE_SOUND = 15021;

// Display Textbox Interface
integer LINK_INTERFACE_TEXTBOX = 14007;

// No Button Is Hit, Or Ignore Is Hit
integer LINK_INTERFACE_TIMEOUT = 14003;

// Define A Channel For Listening
integer LISTEN_CHANNEL;

// Define A Channel Handle To Remove LISTEN_CHANNEL
integer LISTEN_HANDLE;

// Define API Seperator For Parsing String Data
string DIALOG_SEPERATOR = "||";

// Message To Be Shown With The Dialog
string DIALOG_MENU_MESSAGE;

// Define A List Containing All The Possible Menu Buttons
list DIALOG_MENU_BUTTONS = [];

// List Of Packed Menus Command, In Order Of DIALOG_MENU_ID_NAMES
list DIALOG_MENU_COMMANDS = []; //DIALOG_MENU_MESSAGE||DIALOG_TIMEOUT||DIALOG_MENU_BUTTONS||DIALOG_MENU_RETURNS

// Define A List Containing All The Possible Menu Names
list DIALOG_MENU_ID_NAMES = [];

// Define A List Containing All The Possible Menu Returns
list DIALOG_MENU_RETURNS = [];

// Sound To Be Played When A Menu Is Shown
string SOUND_UUID = "00000000-0000-0000-0000-000000000000";

// Sound Volume Of The Menu Sound
float SOUND_VOLUME = 1.0;

// Dialog Time-Out Defined In Dialog Menu Creation.
integer DIALOG_TIMEOUT;

// Key Of User Who Attending This Dialog
key AVATAR_UUID;

// Define Tokens For The Prev and Next Operations
string BUTTON_BACK = "◄ Back";
string BUTTON_NEXT = "Next ►";
string BUTTON_OK = "OK ✔";

// Previous Called Menu Index
integer DIALOG_PREVIOUS_INDEX = 0;

// Returns Numeric Value Result
integer DIALOG_NUMERIC_VALUE;

// Dialog Numeric Display Format
string DIALOG_NUMERIC_FORMAT;

// Redirect States
string REDIRECT_STATE;

// Link Number of the requested prim
integer REQUESTED_LINK;

// Requested Link Channel Number
integer REQUESTED_CHANNEL = -1;

// Requested Link Message String
string REQUESTED_MESSAGE;

// Requested Link Key Either Dialog ID Or Owner/User Key
key REQUESTED_KEY;

// The Maximum Number Of Buttons That Can Be Displayed In The Dialog At One Time
integer DIALOG_MAX_BUTTONS = 12;

// The Number Of Menu Items Available.
integer DIALOG_ITEMS_COUNT = 0;

// Define Cycle Number To Keep Track Of Which DIALOG_ITEMS_SUBLIST To Display
integer DIALOG_CYCLE_INDEX = 0;

// Toggle Debug Mode On/Off
integer DEBUG_TOGGLE;

// new 0.9.8
integer NUMERIC_TOGGLE;

string Sign = "+";
string SignInput = " ";

list sort(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}

string BUTTON_ADDITION = "+/-";



invert()
{
    if(Sign == "+")
        Sign = "-";
    else
        Sign = "+";
}

list cycle(list items, string direction)
{
    list DIALOG_ITEMS_SUBLIST = [];

    if(direction == BUTTON_BACK)
    {
        if(DIALOG_CYCLE_INDEX > 0)
        {
            DIALOG_CYCLE_INDEX--;
        }
    }
    else if(direction == BUTTON_NEXT)
    {
        DIALOG_CYCLE_INDEX++;
    }

    if(DIALOG_CYCLE_INDEX == 0)
    {
        if(DIALOG_ITEMS_COUNT <= DIALOG_MAX_BUTTONS)
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, 0, DIALOG_ITEMS_COUNT - 1);
        }
        else
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, 0, DIALOG_MAX_BUTTONS - 2);

            DIALOG_ITEMS_SUBLIST += [BUTTON_NEXT];
        }
    }
    else
    {
        integer start_index = 0;

        start_index = (DIALOG_MAX_BUTTONS - 1) + ((DIALOG_CYCLE_INDEX - 1) * (DIALOG_MAX_BUTTONS - 2));

        integer items_left = DIALOG_ITEMS_COUNT - start_index;

        if(items_left > DIALOG_MAX_BUTTONS - 2)
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, start_index, start_index + (DIALOG_MAX_BUTTONS - 3));

            DIALOG_ITEMS_SUBLIST = [BUTTON_BACK] + DIALOG_ITEMS_SUBLIST + [BUTTON_NEXT];
        }
        else
        {
            DIALOG_ITEMS_SUBLIST = llList2List(items, start_index, DIALOG_ITEMS_COUNT - 1);

            DIALOG_ITEMS_SUBLIST = [BUTTON_BACK] + DIALOG_ITEMS_SUBLIST;
        }
    }
    return sort(DIALOG_ITEMS_SUBLIST);
}

string replace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

integer dialog(key id, string message, list buttons)
{
    integer channel = ( -1 * (integer)("0x"+llGetSubString((string)llGetKey(),-5,-1)) );

    llListenRemove(LISTEN_HANDLE);
    LISTEN_HANDLE = llListen(channel, "", id, "");
    if(DIALOG_ITEMS_COUNT > 0)
        llDialog(id, message, buttons, channel);
    else
        llTextBox(id, message, channel);
    return channel;
}

message_linked(integer num, string str, key id)
{
    REQUESTED_CHANNEL = num;
    REQUESTED_MESSAGE = str;
    REQUESTED_KEY = id;
}

response(integer sender_num, integer num, string str, key id)
{
    list data = llParseStringKeepNulls(str, [DIALOG_SEPERATOR], []);
    if(num == LINK_INTERFACE_DIALOG)
    {
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        REQUESTED_LINK = sender_num;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [];

        if(DIALOG_MENU_MESSAGE == "") DIALOG_MENU_MESSAGE = " ";
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;

        integer index;
        integer count = llGetListLength(data);
        if(count > 2)
        {
            DIALOG_ITEMS_COUNT = 0;
            for(index = 2; index<count;index)
            {
                DIALOG_MENU_BUTTONS += [llList2String(data, index++)];
                DIALOG_MENU_RETURNS += [llList2String(data, index++)];
                ++DIALOG_ITEMS_COUNT;
            }
        }
        else
        {
            DIALOG_MENU_BUTTONS = [BUTTON_OK];
            DIALOG_MENU_RETURNS = [];
            DIALOG_ITEMS_COUNT = 1;
        }

        REDIRECT_STATE = "Dialog";
        if(TRUE) state Redirect;
    }
    else if(num == LINK_INTERFACE_NUMERIC)
    {
        llOwnerSay(llDumpList2String(data, "#"));
        DIALOG_MENU_MESSAGE = llList2String(data, 1);
        DIALOG_TIMEOUT = llList2Integer(data, 2);
        DIALOG_NUMERIC_VALUE = llList2Integer(data, 0);
        
        AVATAR_UUID = id;
        REQUESTED_LINK = sender_num;
        DIALOG_MENU_BUTTONS = [BUTTON_OK, BUTTON_ADDITION];
        DIALOG_MENU_RETURNS = [];

        if(DIALOG_MENU_MESSAGE == "") DIALOG_MENU_MESSAGE = " ";
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;

        integer index;
        integer count = llGetListLength(data);
        if(count > 3)
        {
            DIALOG_ITEMS_COUNT = 0;
            for(index = 3; index<count;index)
            {
                DIALOG_MENU_BUTTONS += [llList2String(data, index++)];
                DIALOG_MENU_RETURNS += [llList2String(data, index++)];
                ++DIALOG_ITEMS_COUNT;
            }
        }
        else
        {
            DIALOG_MENU_BUTTONS = [BUTTON_OK];
            DIALOG_MENU_RETURNS = [];
            DIALOG_ITEMS_COUNT = 1;
        }

        REDIRECT_STATE = "Numeric";
        if(TRUE) state Redirect;
    }
    else if(num == LINK_INTERFACE_TEXTBOX)
    {
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        REQUESTED_LINK = sender_num;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [llList2String(data, 2)];
        DIALOG_ITEMS_COUNT = 0;
        
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;

        REDIRECT_STATE = "Textbox";
        if(TRUE) state Redirect;
    }
    else if(num == LINK_INTERFACE_DEBUG)
    {
        DEBUG_TOGGLE = !DEBUG_TOGGLE;
        if(TRUE == DEBUG_TOGGLE)
        {
            llMessageLinked(LINK_THIS, LINK_INTERFACE_ENABLE_DEBUG, "", id);
        }
        else
        {
            llMessageLinked(LINK_THIS, LINK_INTERFACE_DISABLE_DEBUG, "", id);
        }
    }
    else request(sender_num, num, str, id);
}

clear_dialog()
{
    DIALOG_MENU_BUTTONS = [];
    DIALOG_MENU_RETURNS = [];
    DIALOG_MENU_COMMANDS = [];
    DIALOG_MENU_ID_NAMES = [];
    DIALOG_PREVIOUS_INDEX = 0;
}

add_dialog(string name, string message, list buttons, list returns, integer timeout)
{
    string PACKED_MESSAGE = message + DIALOG_SEPERATOR + (string)timeout;

    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++)
    {
        PACKED_MESSAGE += DIALOG_SEPERATOR + llList2String(buttons, i) + DIALOG_SEPERATOR + llList2String(returns, i);
    }
    integer index = llListFindList(DIALOG_MENU_ID_NAMES, [name]);
    if(index >= 0)
        DIALOG_MENU_COMMANDS = llListReplaceList(DIALOG_MENU_COMMANDS, [PACKED_MESSAGE], index, index);
    else
    {
        DIALOG_MENU_ID_NAMES += [name];
        DIALOG_MENU_COMMANDS += [PACKED_MESSAGE];
    }
}

integer show_dialog(string name, key id)
{
    if(llGetListLength(DIALOG_MENU_ID_NAMES) <= 0) return FALSE;

    integer index;
    if(name != "")
    {
        index = llListFindList(DIALOG_MENU_ID_NAMES, [name]);
        if(index < 0) return FALSE;
    }
    else index = DIALOG_PREVIOUS_INDEX;

    DIALOG_PREVIOUS_INDEX = index;

    string PACKED_MESSAGE = llList2String(DIALOG_MENU_COMMANDS, index);

    if(SOUND_UUID != NULL_KEY) llTriggerSound(SOUND_UUID, SOUND_VOLUME); 
    llMessageLinked(LINK_THIS, LINK_INTERFACE_DIALOG, PACKED_MESSAGE, id);
    return TRUE;
}

request(integer sender_num, integer num, string str, key id)
{
    list data = llParseString2List(str, [DIALOG_SEPERATOR], []);
    if(num == LINK_INTERFACE_RESPONSE)
    {
        if(llGetSubString(str, 0, 4) == "MENU_")
        {
            str = llDeleteSubString(str, 0, 4);
            show_dialog(str, id);
        }
    }
    else if(num == LINK_INTERFACE_CLEAR)
    {
        clear_dialog();
    }
    else if(num == LINK_INTERFACE_ADD)
    {
        integer DIALOG_DATA_COUNT = ((llGetListLength(data) - 2) / 2);
        if(DIALOG_DATA_COUNT < 80)
        {
            DIALOG_MENU_MESSAGE = llList2String(data, 0);
            DIALOG_TIMEOUT = llList2Integer(data, 1);
            DIALOG_MENU_BUTTONS = [];
            DIALOG_MENU_RETURNS = [];
            integer index = 2;
            integer count = llGetListLength(data);
            for(index = 2; index < count; index)
            {
                DIALOG_MENU_BUTTONS += [llList2String(data, index++)];
                DIALOG_MENU_RETURNS += [llList2String(data, index++)];
            }
            add_dialog((string)id, DIALOG_MENU_MESSAGE, DIALOG_MENU_BUTTONS, DIALOG_MENU_RETURNS, DIALOG_TIMEOUT);
        }
        else llSay(0, "Too Many Buttons, Try Reduce the Menu Size");
    }
    else if(num == LINK_INTERFACE_SHOW)
    {
        if(!show_dialog(str, id)) llMessageLinked(sender_num, LINK_INTERFACE_NOT_FOUND, str, NULL_KEY);

    }
    else if(num == LINK_INTERFACE_SOUND)
    {
        SOUND_UUID = llList2String(data, 0);
        SOUND_VOLUME = llList2Float(data, 1);
    }
}

default
{
    state_entry()
    {
        if(REQUESTED_CHANNEL > 0) llMessageLinked(REQUESTED_LINK, REQUESTED_CHANNEL, REQUESTED_MESSAGE, REQUESTED_KEY);
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        response(sender_num, num, str, id);
    }
}

state Redirect
{
    state_entry()
    {
        if(REDIRECT_STATE == "Dialog") state Dialog;
        else if(REDIRECT_STATE == "Textbox") state Textbox;
        else if(REDIRECT_STATE == "Numeric") state Numeric;
        else state default;
    }
}

state Dialog
{
    state_entry()
    {
        REQUESTED_CHANNEL = -1;
        LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
        llSetTimerEvent(DIALOG_TIMEOUT);
    }

    state_exit()
    {
        llSetTimerEvent(0);
    }

    on_rez(integer start_param)
    {
        state default;
    }

    timer()
    {
        message_linked(LINK_INTERFACE_TIMEOUT, "", AVATAR_UUID);
        state default;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == LINK_INTERFACE_RESHOW)
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(num == LINK_INTERFACE_CANCEL)
        {
            message_linked(LINK_INTERFACE_CANCELLED, "", AVATAR_UUID);
            state default;
        }
        else
        {
            response(sender_num, num, str, id);
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;

        if(msg == BUTTON_BACK)
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, BUTTON_BACK));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(msg == BUTTON_NEXT)
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, BUTTON_NEXT));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(msg == " ")
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else
        {
            integer index = llListFindList(DIALOG_MENU_BUTTONS, [msg]);
            message_linked(LINK_INTERFACE_RESPONSE, llList2String(DIALOG_MENU_RETURNS, index), AVATAR_UUID);
            state default;
        }
    }
}

state Textbox
{
    state_entry()
    {
        REQUESTED_CHANNEL = -1;
        LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
        llSetTimerEvent(DIALOG_TIMEOUT);
    }

    state_exit()
    {
        llSetTimerEvent(0);
    }

    on_rez(integer start_param)
    {
        state default;
    }

    timer()
    {
        message_linked(LINK_INTERFACE_TIMEOUT, "", AVATAR_UUID);
        state default;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == LINK_INTERFACE_RESHOW)
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(num == LINK_INTERFACE_CANCEL)
        {
            message_linked(LINK_INTERFACE_CANCELLED, "", AVATAR_UUID);
            state default;
        }
        else
        {
            response(sender_num, num, str, id);
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;

        if(REDIRECT_STATE == "Textbox")
        {
            llMessageLinked(LINK_THIS, LINK_INTERFACE_RESPONSE, msg, AVATAR_UUID);
        }
        state default;
    }
}

state Numeric
{
    state_entry()
    {
        REQUESTED_CHANNEL = -1;
        DIALOG_NUMERIC_FORMAT = replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)DIALOG_NUMERIC_VALUE);
        LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_NUMERIC_FORMAT, sort(DIALOG_MENU_BUTTONS));
        llSetTimerEvent(DIALOG_TIMEOUT);
    }

    state_exit()
    {
        llSetTimerEvent(0);
    }

    on_rez(integer start_param)
    {
        state default;
    }

    timer()
    {
        message_linked(LINK_INTERFACE_TIMEOUT, "", AVATAR_UUID);
        state default;
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == LINK_INTERFACE_RESHOW)
        {
            LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, sort(DIALOG_MENU_BUTTONS));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
        else if(num == LINK_INTERFACE_CANCEL)
        {
            message_linked(LINK_INTERFACE_CANCELLED, "", AVATAR_UUID);
            state default;
        }
        else response(sender_num, num, str, id);
    }

    listen(integer channel, string name, key id, string msg)
    {
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;

		if ( llListFindList( DIALOG_MENU_RETURNS, [ msg ]) != -1 )
		{
			if( llListFindList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], [msg]) != -1)
			{
				DIALOG_NUMERIC_VALUE += (integer)msg;
				DIALOG_NUMERIC_FORMAT = replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)DIALOG_NUMERIC_VALUE);
				LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_NUMERIC_FORMAT, sort(DIALOG_MENU_BUTTONS));
				llSetTimerEvent(DIALOG_TIMEOUT);
			}
			if(msg == BUTTON_OK)
			{
				message_linked(LINK_INTERFACE_RESPONSE, (string)DIALOG_NUMERIC_VALUE, AVATAR_UUID);
				state default;
			}
			else if(msg == BUTTON_ADDITION)
			{
				DIALOG_NUMERIC_VALUE = -DIALOG_NUMERIC_VALUE;
				DIALOG_NUMERIC_FORMAT = replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)DIALOG_NUMERIC_VALUE);
				LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_NUMERIC_FORMAT, sort(DIALOG_MENU_BUTTONS));
				llSetTimerEvent(DIALOG_TIMEOUT);
			}
		}
		else
		{
			LISTEN_CHANNEL = dialog(AVATAR_UUID, DIALOG_NUMERIC_FORMAT, sort(DIALOG_MENU_BUTTONS));
			llSetTimerEvent(DIALOG_TIMEOUT);
		}
   }
}