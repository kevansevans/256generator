# The 256 Generator
***
The 256 generator is an easy to use asset generator intended for GZDoom modding. Supply a png file that posses any form of transparency and the 256 Generator will create 256 uniquely colored versions of your image based on chosen palette selection.
***
Why might you want this? Recolors are a simple way to take existing assets and make them seem fresh and new in a map. However, they're a pain in the ass to make happen with conventional image editors, because some days you just need a butt ton of recolors for your project. This happened to me one day where I wanted a wide assortment of colors but the exact same texture. I'm sitting at my desk with gimp open doing the edits color by color, when the programming lightbulb went off in my head and realized I could automate this. Three weeks later of one off programs I never thought of sharing, I decided to turn it into a tool for everyone to use.
***
##### Features
* Has all official id Tech 1 game palettes built in
    * Includes Quake, Duke 3D, and a general set of 256 colors. 
	* (Upcoming feature) Random 16 x 16 palette and a mono-fade palette, the mono-fade palette can be saved to the user's disk.
* Sprite mode allows for easy sprite editing by skipping pixels that are fully transparent
    * This assumes that the user has supplied an asset where fully transparent pixels are intentional. May not work on all assets.
	* Sprite mode will be deprecated in favor of Alpha knockout in later update
* Several knobs and buttons to change appearances of the export (lots to come, I hope!)
    * Alpha knockout properties that offer selective adjustment to ignore any range of translucent pixels. 
	* Hue, Saturation, and Luminance modifiers for underlay color.
***
##### Planned features
* Custom palette import - Finished in dev build!
* Animation mode, import multiple frames for easy animated textures or actor sprite generation
* ZScript/Decorate compatible naming and origin offset setting
* Swatch selectivity. No need to generate all 256 swatches.
* HTML5 deployment. No need to download the program!
* Zip file export.
***
##### How to compile

256gen is built with Haxe. If you are already a Haxe user, the libraries you need installed are the latest versions OpenFL and Lime with OpenFL tools installed, as well as Haxeui-core and Haxeui-openfl (indev branch). Run the command ``openfl build cpp`` in the directory containing ``Project.xml``. The project executable will be compiled into ``256generator\bin\[target]\bin``

##### Instructions for those new to Haxe:

1) Download Haxe from https://haxe.org/. 256gen will try to focus on using the latest branch of Haxe, which is currently Haxe 4.0.0 as this readme was last updated.
2) In your terminal, run the command ``haxelib setup``. This is to establish the default directory for Haxe libraries to be installed.
3) Run the command ``Haxelib install openfl``. Once downloaded, run the command ``haxelib run openfl setup``. This will download and install environment for 256gen to compile properly. Make sure to say yes to installing the openfl command.
3.1) (indev branch) install the haxelibs Haxeui-core and Haxeui-openfl ``haxelib install haxeui-core`` and ``haxelib install haxeui-openfl``
4) * Windows users will need an install of Visual Studio at this point. Haxe currently is incapable of identifying the install path of the current version of VS, so you'll need to go into your environment variables and add the var ``HXCPP_VARS`` with the value pointing to cl.exe in the VS install ``C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.14.26428\bin\Hostx64\x86``
    * Linux users will only need G++. It's also recommended you make sure the permissions of the haxe compiler are set to a low enough level the user will not need to use ``sudo`` to run. I'm not familiar with linux enough to verify howneeded this is, but I've personally have found issues getting 256gen to work properly on linux if the user does not run the program as root.
    * MacOS users: I'm sorry, I don't have instructions for you as I haven't had a working Mac VM for a long time.
5) Navigate to the folder where you've cloned/downloaded the project with your terminal and run the command ``openfl test cpp`` or ``openfl test html5`` (for when HTML5 support is official) in the directory containing ``Project.xml``. Haxe should then compile your project and launch it for you.
***
Some thanks:
	
Haxe for being such an awesome toolkit.

OpenFL for being such an awesome library.

Haxeui for being such a good UI.

Rachael for the hue invert formula.

ElementalCode for the help with the HTML5 import.

And from viewers like you, thank you.