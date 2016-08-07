// ********** DIALOG FUNCTIONS **********
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
// ********** END DIALOG FUNCTIONS **********

string TEXTURE_DIALOG;

list TEXTURE_BUTTONS = [];
list TEXTURE_RETURNS = [];

string INVENTORY_TEXTURE_NAME; // Get Texture Name

initTextures()
{
// Please me reminded that Nargus Dialog script autometicly add Back/Next buttons for you.
// Optimised dialog generator script. Much more memory efficient than usage of Dialog+Menus control function

    llOwnerSay("Inventory change detected; re-initializing...");

    dialog_clear();

    TEXTURE_DIALOG = "Click BACK/NEXT to change page.\n" +
        "Click a texture button to choose.";

    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);
    integer index;
    for(index = 0; index<count; ++index)
    {
        INVENTORY_TEXTURE_NAME = llGetInventoryName(INVENTORY_TEXTURE, index);
        
        llSay(0, "DEBUG TEXTURE_NAME:" + INVENTORY_TEXTURE_NAME);
        TEXTURE_BUTTONS += [llGetSubString(INVENTORY_TEXTURE_NAME, 0, 12)];
        TEXTURE_RETURNS += [INVENTORY_TEXTURE_NAME];
    }
        add_menu("MainMenu",

            TEXTURE_DIALOG, // Dialog Messages

            TEXTURE_BUTTONS, // Dialog Buttons

            TEXTURE_RETURNS, // Dialog Returns

            DIALOG_TIMEOUT // Dialog Timeout
        );
    //texturesDialog += DIALOG_SEPERATOR + "CLOSE" + DIALOG_SEPERATOR;

    llOwnerSay("Initializing completed.");
}
 
default{
    state_entry(){
        initTextures();
    }
    
    changed(integer changes){
        if(changes & CHANGED_INVENTORY) initTextures();
    }
 
    link_message(integer sender_num, integer num, string str, key id){
        if(num == LINK_INTERFACE_RESPONSE)
        {
            llSay(0, str);
            if(llGetInventoryType(str) == INVENTORY_TEXTURE) llSetTexture(str, ALL_SIDES);
        }
    }
 
    touch_start(integer num_detected)
    {
        llSay(0, "DEBUG TEXTURE_BUTTONS:" + llDumpList2String(TEXTURE_BUTTONS, DIALOG_SEPERATOR));
        llSay(0, "DEBUG TEXTURE_RETURNS:" + llDumpList2String(TEXTURE_RETURNS, DIALOG_SEPERATOR));
        dialog_show("MainMenu", llDetectedOwner(0));
        //llMessageLinked(LINK_THIS, lnkDialog, texturesDialog, llDetectedOwner(0));
    }
}