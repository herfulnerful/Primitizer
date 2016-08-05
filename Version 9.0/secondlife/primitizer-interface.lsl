// Constants

//
integer LINK_INTERFACE_DEBUG = 17000;

integer LINK_INTERFACE_ADD = 15002;
integer LINK_INTERFACE_CANCEL = 14012;
// Cancel is hit for LINK_INTERFACE_NUMERIC
integer LINK_INTERFACE_CANCELLED = 14006;
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

// define a channel for listening
integer LISTEN_CHANNEL;

// define a channel handle to remove LISTEN_CHANNEL
integer LISTEN_HANDLE;

// define API Seperator for parsing string data
string DIALOG_SEPERATOR = "||";

// Message to be shown with the dialog
string DIALOG_MENU_MESSAGE;

// define a list containing all the possible menu buttons
list DIALOG_MENU_BUTTONS = [];

// List of packed menus command, in order of DIALOG_MENU_NAMES
list DIALOG_MENU_COMMANDS = [];

// define a list containing all the possible menu names
list DIALOG_MENU_NAMES = [];

// define a list containing all the possible menu returns
list DIALOG_MENU_RETURNS = [];

// Sound to be played when a menu is shown
string SOUND_UUID = "00000000-0000-0000-0000-000000000000";

// Sound volume of the menu sound
float SOUND_VOLUME = 1.0;

// Dialog time-out defined in dialog menu creation.
integer DIALOG_TIMEOUT;

// Key of user who attending this dialog
key AVATAR_UUID;

// define tokens for the Prev and Next operations
string BUTTON_BACK = "<< Back";
string BUTTON_NEXT = "Next >>";
string BUTTON_OK = "OK";
string BUTTON_CANCEL = "Cancel";

// previous called menu index
integer DIALOG_PREVIOUS_INDEX = 0;

// returns numeric value result
float DIALOG_NUMERIC_VALUE;

// Use integer instead of floats
integer DIALOG_NUMERIC_INTEGER;

// redirect states
string REDIRECT_STATE;

// link number of the requested prim
integer REQUESTED_LINK;

integer REQUESTED_CHANNEL = -1;
string REQUESTED_MESSAGE;
key REQUESTED_KEY;

// ********** V9 Interface Updated Variables ********** //

// the maximum number of buttons that can be displayed in the dialog at one time
integer DIALOG_MAX_BUTTONS = 12;

// the number of menu items available (calculated in state_entry)
integer DIALOG_ITEMS_COUNT = 0;

// define a cycle number to keep track of which sublist to display
integer DIALOG_CYCLE_INDEX = 0;

// ********** V9 Interface Updated Functions ********** //
// 0 = DISABLED
// 1 = OWNER
// 2 = PUBLIC
// 3 = DEBUG_CHANNEL
integer DEBUG_MODE = 1;

log(string message)
{
	if(DEBUG_MODE == 1 ) llOwnerSay(message);
	else if(DEBUG_MODE == 2 ) llSay(0, message);
	else if(DEBUG_MODE == 3 ) llSay(DEBUG_CHANNEL, message);
}
// figure out which sublist cycle should be displayed
//
// items can be any list that has a bunch of items in it
// direction can be BUTTON_BACK, BUTTON_NEXT, or a blank String
list cycle_dialog(list items, string direction)
{
	// the sublist that will be generated by the next few operations
	list sublist = [];

	// calculate the number of items available
	DIALOG_ITEMS_COUNT = llGetListLength(items);

	// check to see what the direction was (if one was specified)
	if(direction == BUTTON_BACK)
	{
		// display the previous cycle if the preconditions are met
		if(DIALOG_CYCLE_INDEX > 0)
		{
			// the index can be cycled backward safely
			DIALOG_CYCLE_INDEX--;
		}
	}
	else if(direction == BUTTON_NEXT)
	{
		// display the next cycle if the preconditions are met
		DIALOG_CYCLE_INDEX++;
	}

	// figure out which button cycle needs to be displayed
	if(DIALOG_CYCLE_INDEX == 0) // first cycle
	{
		// check the number of available items
		if(DIALOG_ITEMS_COUNT <= DIALOG_MAX_BUTTONS)
		{
			// the entire list can be displayed as one complete dialog
			sublist = llList2List(items, 0, DIALOG_ITEMS_COUNT - 1);
		}
		else
		{
			// grab the sublist from the beginning until DIALOG_MAX_BUTTONS - 2
			// to take into account the need for a BUTTON_NEXT item
			sublist = llList2List(items, 0, DIALOG_MAX_BUTTONS - 2);

			// append the BUTTON_NEXT item to the end of the cycle
			sublist += [BUTTON_NEXT];
		}
	}
	else // second...n cycle
	{
		// make sure we did not go over the list bounds
		integer start_index = 0;

		// (DIALOG_MAX_BUTTONS - 1) represents the first cycle with the
		// NEXT button
		//
		// ((DIALOG_CYCLE_INDEX - 1) * (DIALOG_MAX_BUTTONS - 2)) calculates
		// every cycle after the first (with NEXT and PREV buttons)
		start_index = (DIALOG_MAX_BUTTONS - 1) + ((DIALOG_CYCLE_INDEX - 1) * (DIALOG_MAX_BUTTONS - 2));

		// calculate how many items we'll have left after this cycle
		integer items_left = DIALOG_ITEMS_COUNT - start_index;

		// check to see if we'll have another cycle after this one
		if(items_left > DIALOG_MAX_BUTTONS - 2)
		{
			// we can fill another dialog with PREV and NEXT buttons, so
			// this is just another regular cycle (with DIALOG_MAX_BUTTONS - 3) to ensure that
			// the total number of items pulled from DIALOG_MENU_BUTTONS is actually equal to
			// (DIALOG_MAX_BUTTONS - 2)
			sublist = llList2List(items, start_index, start_index + (DIALOG_MAX_BUTTONS - 3));

			// add the PREV button and NEXT button
			sublist = [BUTTON_BACK] + sublist + [BUTTON_NEXT];
		}
		else
		{
			// we can finish the list along with a PREV button, so this
			// is the final cycle for the list
			sublist = llList2List(items, start_index, DIALOG_ITEMS_COUNT - 1);

			// add the PREV button to the beginning of the cycle
			sublist = [BUTTON_BACK] + sublist;
		}
	}

	// return and generated the generated sublist cycle
	sublist = llListSort(sublist, 1, TRUE);
	return sublist;
}

// ********** String Replace Functions **********

// when using opensim use the following instead:
// osReplaceString(str, search, replace, -1, 0);
string string_replace(string str, string search, string replace)
{
	return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

// ********** Dialog Functions **********
integer create_dialog(key id, string message, list buttons)
{
    integer channel = -((integer)llFrand(8388608))*(255) - (integer)llFrand(8388608) - 11;

    llListenRemove(LISTEN_HANDLE);
    LISTEN_HANDLE = llListen(channel, "", id, "");
    if(DIALOG_ITEMS_COUNT > 0)
        llDialog(id, message, buttons, channel);
    else llTextBox(id, message, channel);
 
    return channel;
}

// Function: numeric_dialog
// Generate numeric adjustment dialog which adjustment values are in given list.
// If useNegative is TRUE, "+/-" button will be available.
list numeric_dialog(list adjustValues, integer useNegative)
{
    list dialogControlButtons;
    list positiveButtons;
    list negativeButtons;
    list additionButtons;
 
    dialogControlButtons = [BUTTON_OK, BUTTON_CANCEL];
 
    // Config adjustment buttons
    integer count = llGetListLength(adjustValues);
    integer index;
    for(index = 0; (index < count) && (index < 3); index++)
	{
        string sValue = llList2String(adjustValues, index);
 
        if((float)sValue != 0)
		{
            positiveButtons += ["+" + sValue];
            negativeButtons += ["-" + sValue];
        }
    }
 
    // Check positive/negative button
    if(useNegative)
        additionButtons = ["+/-"];
    else additionButtons = [];
 
    // If there is fourth adjustment button
    if(count > 3)
	{
        if(llGetListLength(additionButtons) == 0) additionButtons = [" "];
 
        string sValue = llList2String(adjustValues, index);
        additionButtons += ["+" + sValue, "-" + sValue];
    }
	else if(additionButtons != []) additionButtons += [" ", " "];
 
    // Return list dialog buttons
    return additionButtons + negativeButtons + positiveButtons + dialogControlButtons;
}

message_linked(integer num, string str, key id)
{
    REQUESTED_CHANNEL = num;
    REQUESTED_MESSAGE = str;
    REQUESTED_KEY = id;
}

checkDialogRequest(integer sender_num, integer num, string str, key id)
{
    // Common dialog requests
    if((num == LINK_INTERFACE_NOTIFY) || (num == LINK_INTERFACE_NUMERIC) || (num == LINK_INTERFACE_DIALOG))
	{
        list data = llParseStringKeepNulls(str, [DIALOG_SEPERATOR], []);
 
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        REQUESTED_LINK = sender_num;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [];
 
        if(DIALOG_MENU_MESSAGE == "") DIALOG_MENU_MESSAGE = " ";
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;
 
        // Generate buttons list
        integer i=2;
        integer count = llGetListLength(data);
        if(count > 2)
		{
            //DIALOG_ITEMS_COUNT = 0;
            for(; i<count;i) //added last line i to fix opensim loop issue
			{
                DIALOG_MENU_BUTTONS += [llList2String(data, i++)];
                DIALOG_MENU_RETURNS += [llList2String(data, i++)];
                //++DIALOG_ITEMS_COUNT;
            }
        }
		else
		{
            DIALOG_MENU_BUTTONS = [BUTTON_OK];
            DIALOG_MENU_RETURNS = [];
            //DIALOG_ITEMS_COUNT = 1;
        }

        // Determine the type of dialog
        if(num == LINK_INTERFACE_NOTIFY)
		{
            llDialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""), LISTEN_CHANNEL);
            return;
        }
		else if(num == LINK_INTERFACE_NUMERIC)
            REDIRECT_STATE = "Numeric";
        else if(num == LINK_INTERFACE_DIALOG)
		{
            REDIRECT_STATE = "Dialog";
        }
 
        if(TRUE) state Redirect;

    }
	// Text box request
	else if(num == LINK_INTERFACE_TEXTBOX)
	{
        list data = llParseStringKeepNulls(str, [DIALOG_SEPERATOR], []);
 
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
        DIALOG_TIMEOUT = llList2Integer(data, 1);
        AVATAR_UUID = id;
        REQUESTED_LINK = sender_num;
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [llList2String(data, 2)];
        //DIALOG_ITEMS_COUNT = 0;
 
        if(DIALOG_TIMEOUT > 7200) DIALOG_TIMEOUT = 7200;
 
        REDIRECT_STATE = "Textbox";
        if(TRUE) state Redirect;
 
    // Otherwise; Check for menu requests
    }
	else if(num == LINK_INTERFACE_DEBUG)
	{
		log("DEBUG:LINK_INTERFACE_DEBUG");
		log("DEBUG:DIALOG_MENU_MESSAGE" + DIALOG_MENU_MESSAGE);
		log("DEBUG:DIALOG_MENU_BUTTONS" + llDumpList2String(DIALOG_MENU_BUTTONS, DIALOG_SEPERATOR) );
		log("DEBUG:DIALOG_MENU_COMMANDS" + llDumpList2String(DIALOG_MENU_COMMANDS, DIALOG_SEPERATOR) );
		log("DEBUG:DIALOG_MENU_NAMES" + llDumpList2String(DIALOG_MENU_NAMES, DIALOG_SEPERATOR) );
		log("DEBUG:DIALOG_MENU_RETURNS" + llDumpList2String(DIALOG_MENU_RETURNS, DIALOG_SEPERATOR) );
	}
	else checkMenuRequest(sender_num, num, str, id);
}

// ********** Menu Functions **********
clear_dialog()
{
    DIALOG_MENU_NAMES = [];
    DIALOG_MENU_COMMANDS = [];
 
    DIALOG_PREVIOUS_INDEX = 0;
}

add_dialog(string name, string message, list buttons, list returns, integer timeout)
{
    // Reduced menu request time by packing request commands
    string packed_message = message + DIALOG_SEPERATOR + (string)timeout;
 
    integer i;
    integer count = llGetListLength(buttons);
    for(i=0; i<count; i++) packed_message += DIALOG_SEPERATOR + llList2String(buttons, i) + DIALOG_SEPERATOR + llList2String(returns, i);
 
    // Add menu to the DIALOG_MENU_COMMANDS list
    integer index = llListFindList(DIALOG_MENU_NAMES, [name]);
    if(index >= 0)
        DIALOG_MENU_COMMANDS = llListReplaceList(DIALOG_MENU_COMMANDS, [packed_message], index, index);
    else
	{
        DIALOG_MENU_NAMES += [name];
        DIALOG_MENU_COMMANDS += [packed_message];
    }
}

integer show_dialog(string name, key id)
{
    if(llGetListLength(DIALOG_MENU_NAMES) <= 0) return FALSE;
 
    integer index;
    if(name != "")
	{
        index = llListFindList(DIALOG_MENU_NAMES, [name]);
        if(index < 0) return FALSE;
    }
	else index = DIALOG_PREVIOUS_INDEX;
 
    DIALOG_PREVIOUS_INDEX = index;
 
    // Load menu command and execute
    string packed_message = llList2String(DIALOG_MENU_COMMANDS, index);
 
    if(SOUND_UUID != NULL_KEY) llPlaySound(SOUND_UUID, SOUND_VOLUME);
    llMessageLinked(LINK_THIS, LINK_INTERFACE_DIALOG, packed_message, id);
    return TRUE;
}

checkMenuRequest(integer sender_num, integer num, string str, key id)
{
	log("DEBUG:CHECKMENUREQUEST:sender_num" + (string)sender_num);
	log("DEBUG:CHECKMENUREQUEST:num" + (string)num);
    // Menu response commands
    if(num == LINK_INTERFACE_RESPONSE)
	{
		log("DEBUG:LINK_INTERFACE_RESPONSE");
		log("DEBUG RESPONSE STRING:" + str);
		log("DEBUG RESPONSE ID:" + (string)id);
        if(llGetSubString(str, 0, 4) == "MENU_")
		{
            str = llDeleteSubString(str, 0, 4);
            show_dialog(str, id);
        }
    }
 
    // Menu management commands
    else if(num == LINK_INTERFACE_CLEAR)
        clear_dialog();
    else if(num == LINK_INTERFACE_ADD)
	{
        list data = llParseString2List(str, [DIALOG_SEPERATOR], []);
		log("DEBUG:data" + llDumpList2String(data, DIALOG_SEPERATOR));
        // @todo remove cast typing
        DIALOG_MENU_MESSAGE = llList2String(data, 0);
		DIALOG_TIMEOUT = llList2Integer(data, 1);
        DIALOG_MENU_BUTTONS = [];
        DIALOG_MENU_RETURNS = [];
		log("DEBUG:DIALOG_MENU_MESSAGE" + (string)DIALOG_MENU_MESSAGE);
		log("DEBUG:DIALOG_TIMEOUT" + (string)DIALOG_TIMEOUT);
		log("DEBUG:DIALOG_MENU_BUTTONS" + llDumpList2String(DIALOG_MENU_BUTTONS, DIALOG_SEPERATOR));
		log("DEBUG:DIALOG_MENU_RETURNS" + llDumpList2String(DIALOG_MENU_RETURNS, DIALOG_SEPERATOR));
        integer i;
        integer count = llGetListLength(data);
        for(i=2; i<count;i) //added last line i for opensim compile issue
		//do
		{
            DIALOG_MENU_BUTTONS += [llList2String(data, i++)];
            DIALOG_MENU_RETURNS += [llList2String(data, i++)];
        }
		//while (i < count);
 
        add_dialog((string)id, DIALOG_MENU_MESSAGE, DIALOG_MENU_BUTTONS, DIALOG_MENU_RETURNS, DIALOG_TIMEOUT);
 
    }
	else if(num == LINK_INTERFACE_SHOW)
	{
        if(!show_dialog(str, id)) llMessageLinked(sender_num, LINK_INTERFACE_NOT_FOUND, str, NULL_KEY);
 
    }
	else if(num == LINK_INTERFACE_SOUND)
	{
        SOUND_UUID = str;
        SOUND_VOLUME = (float)((string)id);
    }
}
 
// ********** States **********
default
{
    state_entry()
	{
        if(REQUESTED_CHANNEL > 0) llMessageLinked(REQUESTED_LINK, REQUESTED_CHANNEL, REQUESTED_MESSAGE, REQUESTED_KEY);
    }

	link_message(integer sender_num, integer num, string str, key id)
	{
		checkDialogRequest(sender_num, num, str, id);
	}
}

state Redirect
{
    state_entry()
	{
		log("DEBUG:ENTERED START DIALOG STATE");
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
		log("DEBUG:ENTERED MULTI DIALOG STATE");
        REQUESTED_CHANNEL = -1;
        LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
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
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
		else if(num == LINK_INTERFACE_CANCEL)
		{
			state default;
		}
        else
		{
			checkDialogRequest(sender_num, num, str, id);
		}
    }
 
    listen(integer channel, string name, key id, string msg)
	{
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;
 
        // Dialog control buttons
        if(msg == BUTTON_BACK)
		{
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, BUTTON_BACK));
			llSetTimerEvent(DIALOG_TIMEOUT);
        }
		else if(msg == BUTTON_NEXT)
		{
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, BUTTON_NEXT));
			llSetTimerEvent(DIALOG_TIMEOUT);
        }
		else if(msg == " ")
		{
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
			llSetTimerEvent(DIALOG_TIMEOUT);
 
        // Response buttons
        }
		else
		{
			log("DEBUG:RESPONSE BUTTONS");
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
		log("DEBUG:ENTERED TEXTBOX DIALOG STATE");
        REQUESTED_CHANNEL = -1;
        LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
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
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
            llSetTimerEvent(DIALOG_TIMEOUT);
        }
		else if(num == LINK_INTERFACE_CANCEL)
		{
			state default;
		}
        else
		{
			checkDialogRequest(sender_num, num, str, id);
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
		log("DEBUG:ENTERED NUMERIC DIALOG STATE");
        REQUESTED_CHANNEL = -1;
 
        DIALOG_NUMERIC_VALUE = llList2Float(DIALOG_MENU_RETURNS, 0);
        DIALOG_NUMERIC_INTEGER = llList2Integer(DIALOG_MENU_RETURNS, 2);
        DIALOG_MENU_BUTTONS = numeric_dialog(DIALOG_MENU_BUTTONS, llList2Integer(DIALOG_MENU_RETURNS, 1));
 
        string vMessage;
        if(DIALOG_NUMERIC_INTEGER)
            vMessage = string_replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)((integer)DIALOG_NUMERIC_VALUE));
        else vMessage = string_replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)DIALOG_NUMERIC_VALUE);

        LISTEN_CHANNEL = create_dialog(AVATAR_UUID, vMessage, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
		//llDialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""), LISTEN_CHANNEL);
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
            LISTEN_CHANNEL = create_dialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
            //llDialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""), LISTEN_CHANNEL);
			llSetTimerEvent(DIALOG_TIMEOUT);
        }
		else if(num == LINK_INTERFACE_CANCEL) state default;
 
        //else checkDialogRequest(sender_num, num, str, id);
		else checkDialogRequest(sender_num, num, str, id);
    }
 
    listen(integer channel, string name, key id, string msg)
	{
        if((channel != LISTEN_CHANNEL) || (id != AVATAR_UUID)) return;
 
        // Dialog control button is hit
        if(msg == BUTTON_OK)
		{
			message_linked(LINK_INTERFACE_RESPONSE, (string)DIALOG_NUMERIC_VALUE, AVATAR_UUID);
            //llMessageLinked(LINK_THIS, LINK_INTERFACE_RESPONSE, (string)DIALOG_NUMERIC_VALUE, AVATAR_UUID);
            state default;
        }
		else if(msg == BUTTON_CANCEL)
		{
			message_linked(LINK_INTERFACE_CANCELLED, (string)DIALOG_NUMERIC_VALUE, AVATAR_UUID);
            llMessageLinked(LINK_THIS, LINK_INTERFACE_CANCELLED, (string)DIALOG_NUMERIC_VALUE, AVATAR_UUID);
            state default;
 
        // Value adjustment button is hit
        }
		else if(msg == "+/-")
            DIALOG_NUMERIC_VALUE = -DIALOG_NUMERIC_VALUE;
        else if(llSubStringIndex(msg, "+") == 0)
            DIALOG_NUMERIC_VALUE += (float)llDeleteSubString(msg, 0, 0);
        else if(llSubStringIndex(msg, "-") == 0)
            DIALOG_NUMERIC_VALUE -= (float)llDeleteSubString(msg, 0, 0);
 
        // Spawn another dialog if no OK nor Cancel is hit
        string vMessage;
        if(DIALOG_NUMERIC_INTEGER)
			vMessage = string_replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)((integer)DIALOG_NUMERIC_VALUE));
		else vMessage = string_replace(DIALOG_MENU_MESSAGE, "{VALUE}", (string)DIALOG_NUMERIC_VALUE);
        LISTEN_CHANNEL = create_dialog(AVATAR_UUID, vMessage, cycle_dialog(DIALOG_MENU_BUTTONS, ""));
		//llDialog(AVATAR_UUID, DIALOG_MENU_MESSAGE, cycle_dialog(DIALOG_MENU_BUTTONS, ""), LISTEN_CHANNEL);
        llSetTimerEvent(DIALOG_TIMEOUT);
   }
}