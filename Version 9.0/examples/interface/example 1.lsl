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

add_numeric(key id, string message, list buttons, list returns, integer timeout)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_NUMERIC, dialog_command(message, buttons, returns, timeout), id);
}

dialog_sound(string sound, float volume)
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_SOUND, sound + DIALOG_SEPERATOR + (string)volume, NULL_KEY);
}

dialog_clear()
{
    llMessageLinked(LINK_THIS, LINK_INTERFACE_CLEAR, "", NULL_KEY);
}


list NUMBERS_BUTTONS = [];
list NUMBERS_RETURNS = [];

default
{
    state_entry()
    {
        integer count = 100;
        integer index = 0;
        for(index = 0; index<count; index++)
        {
            NUMBERS_BUTTONS += [index];
            NUMBERS_RETURNS += [index];
        }

		dialog_clear(); // Clear Lists

        add_menu("MainMenu",
 
            // Dialog message here
            "Messages go here",
 
            // List of dialog buttons
            NUMBERS_BUTTONS,
 
            // List of return value from the buttons, in same order
            // Note that this value do not need to be the same as button texts
            NUMBERS_RETURNS,
            
            DIALOG_TIMEOUT
        );
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == LINK_INTERFACE_TIMEOUT)
        {
            llOwnerSay("Menu time-out. Please try again.");
            state default;
        }
        else if(num == LINK_INTERFACE_RESPONSE)
        {
            llWhisper(0, str);
        }
    }
 
    touch_start(integer num_detected)
    {
        dialog_show("MainMenu", llDetectedOwner(0));
    }
}
