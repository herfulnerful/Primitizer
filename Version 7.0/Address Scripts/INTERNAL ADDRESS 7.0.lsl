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

integer PRIMITIZER_CHANNEL;
string PRIMITIZER_SEPARATOR = "|";
integer PRIMITIZER_DESTINATION_TIME = 15;
integer PRIMITIZER_START_TIME = 0;
float PRIMITIZER_TICK_TIME = 1; 
string PRIMITIZER_OBJECT_NAME;
integer PRIMITIZER_OBJECT_ID;
string PRIMITIZER_PACKAGE;
vector PRIMITIZER_REZ_OFFSET = <0.00, 0.00, 1.0>;
vector PRIMITIZER_MOVE_OFFSET = <0.00, 0.00, -0.30>;

rez_object(string inventory, vector position, integer channel)
{
    // Delay Rez From The Grey Goo Fence
    llSleep (0.1);     
    //Rez the object indicated by message
    llRezObject(inventory, llGetPos() + position, ZERO_VECTOR, llGetRot(), channel);
}

move_object(vector position, integer channel, string separator)
{
    // Move Command
    llRegionSay(channel, "MOVE " + llDumpList2String([ (vector)llGetPos() + position, (rotation)llGetRot() ], separator));
}
 
default
{
 
    on_rez(integer total_number)
    {
        if (total_number != 0)
        {
            PRIMITIZER_CHANNEL = total_number;
            llRegionSay(PRIMITIZER_CHANNEL, "CLEAN");
            PRIMITIZER_OBJECT_NAME = llGetObjectName();
            llRegionSay(PRIMITIZER_CHANNEL, "TEXTURE " + PRIMITIZER_OBJECT_NAME);
            llRegionSay(PRIMITIZER_CHANNEL, "LIGHTS " + PRIMITIZER_OBJECT_NAME);
            llRegionSay(PRIMITIZER_CHANNEL, "PARTICLES " + PRIMITIZER_OBJECT_NAME);            
            llSetTexture(TEXTURE_TRANSPARENT, ALL_SIDES);
            PRIMITIZER_OBJECT_ID = llGetInventoryNumber(INVENTORY_OBJECT);
            integer i;
            for(i=0; i < PRIMITIZER_OBJECT_ID; i++)
            {
                PRIMITIZER_PACKAGE = llGetInventoryName(INVENTORY_OBJECT, i);
                rez_object(PRIMITIZER_PACKAGE, PRIMITIZER_REZ_OFFSET, PRIMITIZER_CHANNEL);
                move_object(PRIMITIZER_MOVE_OFFSET, PRIMITIZER_CHANNEL, PRIMITIZER_SEPARATOR);
            }
            PRIMITIZER_START_TIME = llGetUnixTime();    
            llSetTimerEvent(PRIMITIZER_TICK_TIME);
        }
    }
        
    timer()
    {
        if((llGetUnixTime() - PRIMITIZER_START_TIME) >= PRIMITIZER_DESTINATION_TIME)
        {
            llDie();
        }
    }
    
    object_rez(key id)
    {
        move_object(PRIMITIZER_MOVE_OFFSET, PRIMITIZER_CHANNEL, PRIMITIZER_SEPARATOR);
    }   
}