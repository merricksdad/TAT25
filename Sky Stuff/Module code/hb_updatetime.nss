#include "nw_inc_dynlight"

void main()
{
    //initialize sun/moon cycle for v.35+
    ExecuteScript("nw_dynlight");

    float fModuleHour = GetDuskDawnModifiedModuleTime();

    //setup time vars
    float fFadeTime = 0.0; //turned off to stop wiggling
    int bRecursive = 0;  //turned off to stop wiggling
    if(bRecursive)
    {
        if(!GetLocalInt(GetModule(), NW_DYNAMIC_LIGHT_RUNNING))
            return;

        fFadeTime = NW_DYNAMIC_LIGHT_FADE_TIME + NW_DYNAMIC_LIGHT_FADE_TIME_OVERLAP;
    }

    float fGlobalLatitude = GetLocalFloat(GetModule(), NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE);

    if(fGlobalLatitude == 0.0)
        fGlobalLatitude = NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE_DEFAULT;


    //get light positions based on time of day
    vector vSun = GetSunlightDirectionFromTime(fGlobalLatitude, 0.0);
    vector vMoon = GetMoonlightDirectionFromTime(fGlobalLatitude, 0.0, 2.0);
    vector vMoon2 = GetMoonlightDirectionFromTime2(fGlobalLatitude, 0.0, 6.0, 1.25);

    //send all PCs the details
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC)) {

        //pass global time to the shaders
        SetShaderUniformFloat(oPC, SHADER_UNIFORM_1, fModuleHour);

        //pass sun and moon positions to the shaders

        SetShaderUniformVec(oPC, SHADER_UNIFORM_1, vSun.x, vSun.y, vSun.z, 1.0f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_2, vMoon.x, vMoon.y, vMoon.z, 1.0f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_5, vMoon2.x, vMoon2.y, vMoon2.z, 1.0f);

        //get player's local area sun and moon diffuse colors
    `   object oArea = GetArea(oPC);
        vector vSunColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_SUN_DIFFUSE, oArea));
        vector vMoonColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_MOON_DIFFUSE, oArea));

        //pass sun and moon colors
        SetShaderUniformVec(oPC, SHADER_UNIFORM_3, vSunColor.x, vSunColor.y, vSunColor.z, 1.0f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_4, vMoonColor.x, vMoonColor.y, vMoonColor.z, 1.0f);

        //update the area details so the sun moves over time
        SetAreaLightDirection(AREA_LIGHT_DIRECTION_SUN, vSun, oArea, 0.0);
        SetAreaLightDirection(AREA_LIGHT_DIRECTION_MOON, vMoon, oArea, 0.0);


        oPC = GetNextPC();
    }


}
