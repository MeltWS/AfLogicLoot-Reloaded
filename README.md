# afLogicLoot

[WildStar](http://www.wildstar-online.com)-Addon

DISCLAIMER: I did not develop this addon, all credit goes to the original author arnefi, all I did was change , add or remove a few things to make it work good for WS reloaded.

## Description

Automatically select »need« or »greed« based on you settings.

![Configuration Window Equipment 1](http://fs1.directupload.net/images/150208/dpcc7fgs.jpg)
![Configuration Window Equipment 2](http://fs1.directupload.net/images/150208/w7znvvju.jpg)
![Configuration Window Style](http://fs1.directupload.net/images/150208/3n8cqz9b.jpg)
![Configuration Window Crafting](http://fs1.directupload.net/images/150208/cyzde6v3.jpg)
![Profile Management](http://fs2.directupload.net/images/150208/xn2n5mmp.jpg)

When there's group loot in dungeons you can now let this addon automatically select »need« or »greed«.

Just open the configuration window once and define on which kind of loot what should be selected. There are multiple categories to choose from to adjust the looting behaviour to your own needs.

After installation you can configure it by typing `/afloot` in any chat window or using the ESC-Menu.

You can quicky turn the addon on and off by the big green/red button at the bottom of the window or with the help of the following slash commands:

* `/afloot on`
* `/afloot off`
* `/afloot toggle`

And you can set up different profiles, for example one for dungeons and one for raiding. And afLogicLoot can select the desired autmatically, just like you want it.
	
[Addon on Curse](http://curse.com/project/227397)

![afLogicLoot DVD Case](http://fs1.directupload.net/images/150131/qvmzbu93.png)


## Configuration

Even if configuring the addon is quite easy, it may not be that obvious at once, so here are two examples. Let's take a look at the sigil section:

![Sigils](http://fs2.directupload.net/images/150131/qx34etts.png)

Both need and greed options on the right side depend on the quality setting. The upper one (labeled "selected") defines the action if the sigil is of the selected quality or below. The lower one (labeled "otherwise") defines the action if the sigil is above the selected quality.
So if your plan is to "need" all Eldan Signs and to "greed" all other, you would select "Excellent" on the left side, "greed" on the upper action box and "need" on the lower box.

The equipment box is a little bit different from that:

![Equipment settings](http://fs2.directupload.net/images/150131/vixbdfn5.png)

Main thoughts are:

* If the item is of interest for me I want to select the action myself.
* My equipment is quite good so I don't need any green stuff or below.
* I will only select "need" if I really want to equip the item.

So with the quality selector you select, what items you're not interested in anymore and the addon should take care of. Select the appropriate action from the action box and of course there's no "need" option. Wearable equipment above the selected quality will always be displayed and you will have to select an option yourself.
And then there's loot where there's no "need" button in the game. For those items the lower action box applies.


## Tooltips

Yes, there are some. Hover the mouse over the title of a section or of an action and you will find short explanations whitin the addon.


## General Looting Rules

Quite often you'll see people who aren't absolutely sure, what to select when, so I want to summarize the rules quickly:

* if you want to wear or use it, you *need* it
* if you just want to sell or salvage it or you don't mind, you *greed* it

So it's quite simple. There is no answer to the question "what do I have to press on runes". Do you need them? Meaning are you going to build runes for your equipment yourself? So you'll definitely *need* runes. You only buy runes from the AH? Then you seem to just want the money they are worth.
