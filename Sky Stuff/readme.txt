*************************************************
                  MD SKY SHADER
*************************************************


**** File Requirements ****

**shaders**

inc_standard_md      : replacement for inc_standard
inc_light_md         : controls sun/moon lighting as well as other stuff
inc_options_md       : a master file for global options
inc_transform_md     : replacement for inc_transform
inc_math_md          : additional math functions for trig and colors

fst_sky              : the base skybox fragment shader
vsvt_sky             : the base skybox vertex shader

**textures**

tx_skyauto01.mtr     : material file for handling skybox textures

tx_skyauto01.tga     : texture includes sprites like sun and moon
tx_skycolor01.tga    : texture includes the hourly sky gradient

**module code**

nw_inc_dynlight      : replacement for sun and moon motion and lighting
hb_updatetime        : contains code to be run on heartbeat which sends 
					   information to shaders


**** Setup ****

1) Include the above files in a hak

2) Adjust your custom skyboxes.2da to include a line similar to: 

	7   Sky_Shader      ****        0           Sky_Auto    Sky_Auto    Sky_Auto    Sky_Auto
	
3) Include the updated skyboxes.2da into the hak

4) Connect the hak to a module

5) Select the Sky_Shader option as a skybox in an area

6) import the above module code files into the module using either 
   an ERF or by inserting them in the nwn\modules\temp0 folder while
   the module is open, then save, exit, and reload
   

**** Other Considerations ****

The module code uses the following scriptable shader variables

1) scriptableFloat1  : Used to pass a pre-calculated module hour to the shader
                       This value is not the true module hour, but a modified 
					   daylight-hour built from the user-defined dusk and dawn hours
					   Do not use as a true module time.
					   
2) scriptableVec1    : Used to pass the pre-calculated sun position

3) scriptableVec2    : Used to pass the pre-calculated sun diffuse color

4) scriptableVec3    : Used to pass the pre-calculated moon position

5) scriptableVec4    : Used to pass the pre-calculated moon diffuse color

6) scriptableVec5    : Used to pass the pre-calculated second moon position
					   This may be phased out in the future

					   
If you already use these scriptable variables for other purposes, you will need
to either modify your other code, or change the matching between them in hb_updatetime. 

If you need to change the underlying shader code, the functions SetupSunAndMoon() for 
both fs and vs shader levels will need to be updated inside inc_light_md. In addition, 
the matching will need to updated in fst_sky, which does not call SetupSunAndMoon().


**** Options ****

Within tx_skyauto01.mtr are the following options. Any option shown in that file
not listed here should not be modified as it can have unintended consequences. 

texture0           : You can change the sprite sheet for sun and moon(s)
texture6           : You can chnage the sky gradient sheet

SunIntensity       : Changes how wide the sun glow radius and strength is drawn
SunRadius          : Changes the draw scale of the sun sprite on the skybox 
RENDER_SUN_NOISE   : Toggles a water-like wobble of the sun's surface image
RENDER_SUN_GLOW    : Changes the draw style of the sun sprite (see MTR for notes)
MoonIntensity      : Changes how wide the moon glow radius and strength is drawn
MoonRadius         : Changes the draw scale of the moon sprite on the skybox 
RENDER_MOON_GLOW   : Toggles drawing moon glow 
USE_SECOND_MOON    : Uses the bottom-left sprite for a second moon in the sky 
SecondMoonIntensity: Changes how wide the second moon glow and strength is drawn 
SecondMoonRadius   : Changes the draw scale of the second moon sprite 
SECOND_MOON_ORDER  : Changes the draw order of the second moon 
RENDER_STARS       : Toggles the star field 
StarDensity        : Set the star field density 
StarMaxSize        : Set the point size of the brightest star 
SkyLowestRender    : Set the angle from horizon to stop drawing the skybox 
SpaceColor         : Set the color of space on which the rest is drawn (normally black)


Within inc_options_md are some GLOBAL options.


SOLAR_BURN         : Toggles a gamma burn/dodge by distance. Also applies to any
                     connected terrain, foliage or water shader. 
					 Setting this to 2 will affect skyboxes in addition to other
					 materials. 
					 
SOLAR_BURN_DIST    : Set an offset to start doing burn. Number is from -1 to 1 
                     where positive numbers push the burn away from the camera
                     and negative numbers pull it closer

SOLAR_BURN_POWER   : Set the strength of burn. Values are from 0.001 to infinity
                     where values less than 1.0 will produce a dodge effect instead
					 of burn.
					 
					 
Within nw_inc_dynlight are some more GLOBAL OPTIONS. Many of the options listed
there are not used by this shader. Only those listed here will be used.


NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE_DEFAULT
                   : This lets you set the latitude (north/south) of the module
				     which changes the overhead position of the sun
					 
NW_DYNAMIC_LIGHT_GLOBE_ROTATION_AXIAL_TILT
                   : The tilt between sun and the planet. Also affects the position
                     of the sun overhead

NW_DYNAMIC_LIGHT_MOON_ROTATION_AXIAL_TILT
                   : The tilt between the planet and the moons. Affects the position
                     of the moon overhead.

NW_HORIZON_OFFSET  : Sets the skybox deeper into the sky by this angle offset. 
                     Has the effect of making rise/set positions deeper in the
					 horizon. If you use a large sun/moon radius, think about
					 increasing this number.
					 

Within hb_updatetime there are a few things you can change which affect the moon
and sun positions. 

					 
1) where GetMoonlightDirectionFromTime(fGlobalLatitude, 0.0, 2.0) is called, the 
	moon is assumed to be directly opposite the sun. The third parameter used 
	sets a delay in hours. So if the sun sets at 6pm, the moon would come up 2 hours later.
	
2) where GetMoonlightDirectionFromTime2(fGlobalLatitude, 0.0, 6.0, 1.25) is called,
   the moon is assumed to be directly opposite the sun. The third parameter used 
   sets a delay in hours. The fourth parameter sets the tracking speed of the 
   second moon. So a moon coming up 6 hours later than sunset of 6pm would come up
   at midnight. But if a speed modifier is applied, it will also move 1.25 faster 
   and so will come up earlier. Some testing will be needed to set the second moon
   how you want it.

					 
Within the module you can change the following to affect the sun/moon position.
See module properties panel, advanced tab. 


Minutes per Hour   : Sets the number of real minutes per game hour. Changes the
					 of the sun and moon tracking across the sky, as well as hour
					 transition.
Mod_DuskHour       : Sets the hour of sunset and light transition.
Mod_DawnHour       : Sets the hour of sunrise and light transition.


Within the area you can change the following to affect the sun/moon/fog details.
See area properties panel, visual tab. Environment options.


Sun Diffuse Color  : Sets the color of the sun applied to sun glow in the sky 
Moon Diffuse Color : Sets the color of the moon applied to moon glow in the sky 

Cycle Day/Night    : This option is suggested. Without it, the sun/moon will 
                     still track, and will ignore always day/night. Also fog will
					 not get updated correctly if disabled.


**** Notes on using tx_skycolor01 ****

The image represents an array of gradients. The X axis represents the modified 
solar module hour. So x = 0 and x = 1 are midnight, whereas x = 0.5 is noon. 
The Y axis represents the altitude in the sky. So y = 0 is the horizon, and 
y = 1 is directly overhead. The skybox will clone the gradient downward to the 
maximum SkyLowestRender value supplied in the MTR file. 

Remember that when sun/moon glow are enabled, they will add their color to the 
skybox, so you do not need to add sun glow into the skybox for the position of
the sun and moon. This is just for the "atmosphere". You will want to have fog 
painted into the skybox at y = 0, plus any environment color for smog/fog/dust 
above that. It is natural that a sun/moon will apply distant brightness to the
opposite side of a skybox horizon. If you don't want that, then don't use high
luminance colors at y = 0.

The skybox will paint this gradient for that time all around the skybox. Allow
the sun/moon glow * intensity to produce the additional color you need. Remember 
glow is keyed to the sun/moon diffuse color in the area environment settings.
High saturation and luminance can have very strong effects when mixed to the sky.
Try to use colors closer to grayscale rather than full saturation values. A little
saturation goes a very long way.

The sky color provided is modified  from hourly intervals in Black Desert Online.
The color strips are then blended together and enlarged to provide the 
gradient sheet. You could do the same by making 12-24 strips from daily photos
of a real sky.

**** Known Issues ****

There is a known issue with moon2 skipping backward at midnight. A future fix 
will base more parts of moon2 on moon1 and will therefore not need to track 
a separate time.

Area fog color is still managed by the module's transition period. If you don't
like the fog applied during the normal gameplay, I suggest adding a function to 
modify the fog color scheme during the day. It does not need to be sent to the
shader, as the shaders will already have the fog color.

The current code does not consider a yearly movement of the sun and moon. These 
were temporarily removed to reduce total calculation time. The shader therefore 
represents the day/night of June 20th and will repeat that day indefinitely
using any of the other provided settings/options.

The tracking of the sun/moon will use realistic altitudes. This may cause the 
position to leave the screen for players with camera rotation locked. They can 
either unlock their camera in options, or the  module can provide new lock limits.
If you want the sun to be lower in the sky, you can change the latitude and 
axial tilt values in the module. However, the altitude of the sun sets the total 
brightness of the display. So if you do want a lower sun/moon, you also have to 
modify the way moduleHour is used in the shader. If you forcefully half the altitude,
then you should also double the moduleHour value sent to the shader via 
scriptableFloat1.