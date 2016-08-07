///////////////////////////////////////////////////////////////////////////////
// Dazzle Software - Primitizer Version (7.0)
//
// An Commerical primitizer for Second Life by and Open Simulator by Revolution Perenti & Dazzle Software
//
// This file is commerical software; you can not redistribute it and/or modify
// or reverse enginner this source code in anyway or in any form
// it under the terms of the Commerical License as published by Stephen Bishop (Revolution Perenti)
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Timer Check Variables
///////////////////////////////////////////////////////////////////////////////
float TIMER_INTERVAL = 0.25;        // Time in seconds between movement 'ticks'
///////////////////////////////////////////////////////////////////////////////
// Channel Variables
///////////////////////////////////////////////////////////////////////////////
integer DEFAULT_CHANNEL = -68191;              // default channel
integer PRIMITIZER_CHANNEL = DEFAULT_CHANNEL;  // Channel used by primitizer to talk to label scripts;
integer PRIMITIZER_HANDLE;
///////////////////////////////////////////////////////////////////////////////
// Location Offset Variables
///////////////////////////////////////////////////////////////////////////////
vector POSITION_OFFSET;
rotation ROTATION_OFFSET;
integer PRIMITIZER_MOVE;
vector DESTINATION_POSITION;
rotation DESTINATION_ROTATION;

integer ABSOLUTE = FALSE;
integer SAVED = FALSE;

string PRIMITIZER_SEPARATOR = "|";

string first_pass(string message, string name)
{
    if(name == "") name = " ";
    integer pos = llSubStringIndex(message, name);
    if( pos >= 1 )
        return llGetSubString(message, 0, pos - 1);
    else
        return message;
}

string second_pass(string message, string name)
{
    if( name == "" ) name = " ";
 
    integer pos = llSubStringIndex(message, name);
    if( pos >= 1 )
        return llGetSubString(message, pos + 1, llStringLength(message));
    else
        return "";
}

primitizer_position()
{
    integer i = 0;
    vector vLastPos = ZERO_VECTOR;
    while( (i < 5) && (llGetPos() != DESTINATION_POSITION) )
    {
        list lParams = [];

        if( llGetPos() != DESTINATION_POSITION )
        {
            if( llGetPos() == vLastPos )
            {
                lParams = [ PRIM_POSITION, llGetPos() + <0, 0, 10.0> ];
            } else {
                vLastPos = llGetPos();
            }
        }
 
        integer iHops = llAbs(llCeil(llVecDist(llGetPos(), DESTINATION_POSITION) / 10.0));
        integer x;
        for( x = 0; x < iHops; x++ ) {
            lParams += [ PRIM_POSITION, DESTINATION_POSITION ];
        }
        llSetPrimitiveParams(lParams);
        i++;
    }

    llSetRot(DESTINATION_ROTATION);
}
 
start_move(string message, key id)
{
    //Don't move if we've not yet Saved a position
    if( !SAVED ) return;
    
    // ignore commands from primitizer with a different owner than us
    if( llGetOwner() != llGetOwnerKey(id) ) return;
    
    //Calculate our destination position relative to base?
    if(!ABSOLUTE) {
        message = second_pass(message, " ");
        list lParams = llParseString2List(message, [PRIMITIZER_SEPARATOR], []);
        vector PRIMITIZER_VECTOR_BASE = (vector)llList2String(lParams, 0);
        rotation ROTATION_OFFSET_BASE = (rotation)llList2String(lParams, 1);
 
        DESTINATION_POSITION = (POSITION_OFFSET * ROTATION_OFFSET_BASE) + PRIMITIZER_VECTOR_BASE;
        DESTINATION_ROTATION = ROTATION_OFFSET * ROTATION_OFFSET_BASE;
    }
    else
    {
        //Sim position
        DESTINATION_POSITION = POSITION_OFFSET;
        DESTINATION_ROTATION = ROTATION_OFFSET;
    }
    
 
    //Make sure our calculated position is within the sim
    if(DESTINATION_POSITION.x < 0.0) DESTINATION_POSITION.x = 0.0;
    if(DESTINATION_POSITION.x > 255.0) DESTINATION_POSITION.x = 255.0;
    if(DESTINATION_POSITION.y < 0.0) DESTINATION_POSITION.y = 0.0;
    if(DESTINATION_POSITION.y > 255.0) DESTINATION_POSITION.y = 255.0;
    if(DESTINATION_POSITION.z < 0.0) DESTINATION_POSITION.z = 0.0;
    if(DESTINATION_POSITION.z > 4096.0) DESTINATION_POSITION.z = 4096.0;
 
    //Turn on our timer to perform the move?
    if( !PRIMITIZER_MOVE )
    {
        llSetTimerEvent(TIMER_INTERVAL);
        PRIMITIZER_MOVE = TRUE;
    }
    return;
}

default
{
    state_entry()
    {
        // Open up the listener
        PRIMITIZER_HANDLE = llListen(PRIMITIZER_CHANNEL, "", NULL_KEY, "");
        llSetRemoteScriptAccessPin(PRIMITIZER_CHANNEL);
    }
 
    on_rez(integer start_param)
    {
        if( start_param != 0 )
        {
            PRIMITIZER_CHANNEL = start_param;           
            state reset_listeners;
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        string command = llToUpper(first_pass(message, " "));       
        if( command == "SAVED")
        {
            // Save position relative to base prim
            message = second_pass(message, " ");
            list lParams = llParseString2List(message, [PRIMITIZER_SEPARATOR], []);
            vector PRIMITIZER_VECTOR_BASE = (vector)llList2String(lParams, 0);
            rotation ROTATION_OFFSET_BASE = (rotation)llList2String(lParams, 1);
 
            POSITION_OFFSET = (llGetPos() - PRIMITIZER_VECTOR_BASE) / ROTATION_OFFSET_BASE;
            ROTATION_OFFSET = llGetRot() / ROTATION_OFFSET_BASE;
            ABSOLUTE = FALSE;
            SAVED = TRUE;            
            llOwnerSay("Saved Position.");
            return;
        }        
        if( command == "SAVED_ABSOLUTE" )
        {
            //Record absolute position
            ROTATION_OFFSET = llGetRot();
            POSITION_OFFSET = llGetPos();
            ABSOLUTE = TRUE;
            SAVED = TRUE;            
            llOwnerSay("Saved Sim Position.");
            return;
        }       
        if( command == "MOVE")
        {
            start_move(message, id);
            return;
        }        
        if( command == "FINISH")
        {
            llRemoveInventory(llGetScriptName());
            return;
        }
        if( command == "CLEAN")
        {
            llDie();
            return;
        }
        if( command == "DELETE")
        {
            llResetScript();
        }
        if ( command == "GETPRIMS")  
        {
            llSay(PRIMITIZER_CHANNEL, "PRIMS " + (string)llGetNumberOfPrims() );
            return;
        }        
    }

    timer()
    {
        if( PRIMITIZER_MOVE )
        {
            primitizer_position();           

            PRIMITIZER_MOVE = FALSE;
        }        
    }
}

state reset_listeners
{
    state_entry()
    {
        state default;
    }
}