local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("AfLogicLoot", "enUS", true)


-- DON'T EDIT WITH HOUSTON AS IT LOSES ENCODING SETTINGS
-- USE SOMETHING LIKE NOTEPAD++ FOR THAT TASK

-- Tabs
L["equipment1"] = "Equipment 1"
L["equipment2"] = "Equipment 2"
L["style"]      = "Style"
L["crafting"]   = "Crafting"
L["profiles"]   = "Profiles"

-- global options
L["chk_log"] = "log automatic options to chat"

-- quality
L["inferior"]         = "Inferior"
L["average"]          = "Average"
L["good"]             = "Good"
L["excellent"]        = "Excellent"
L["superb"]           = "Superb"
L["legendary"]        = "Legendary"
L["artifact"]         = "Artifact"
-- "Major" like in "Sign of Water - Major"
L["excellent_major"]  = "Excellent (Major)"
-- "Sign of Water - Eldan"
L["superb_eldan"]     = "Superb (Eldan)"

-- actions
L["need"]      = "Need"
L["greed"]     = "Greed"
L["pass"]      = "Pass"
L["no_action"] = "No action"

-- category side labels
L["quality_below"] = "of this quality and below"
L["action"]        = "action"
L["no_need"]       = "no need"
L["selected"]      = "selected"
L["otherwise"]     = "otherwise"

-- equipment
L["equipment_headline"]         = "Equipment"
L["equipment_headline_tooltip"] = "Armor, gear and weapons."
L["equipment_action_tooltip"]   = "Do this with equipment of specified quality and below. There is no possibility to automatically select \"need\". You should press \"need\" only on equipment you intend to wear. Otherwise please select \"greed\". It's the only fair way so people get the equipment they can and want to use."
L["equipment_no_need_tooltip"]  = "Do this with equipment where you are not allowed to press \"need\"."
L["equipment_not_wearable"]     = "not wearable"

-- sigils
L["sigils_headline"]          = "Sigils"
L["sigils_headline_tooltip"]  = "Stuff like \"Sign of Water\"."
L["sigils_selected_tooltip"]  = "Do this with sigils of the specified quality and below."
L["sigils_otherwise_tooltip"] = "Do this with sigils above the specified quality."

-- fragments
L["fragments_headline"]         = "Fragments"
L["fragments_headline_tooltip"] = "Stuff like \"Augmented Rune Fragment\" or \"Rune Fragment of the Esper\"."

-- runic flux
L["flux_headline"]         = "Runic Flux"
L["flux_headline_tooltip"] = "\"Runic Elemental Flux\" and \"Eldan Runic Module\", stuff you need to change or activate rune slots."

-- proprietary material
L["prop_headline"]         = "Proprietary Material"
L["prop_headline_tooltip"] = "\"Partial Primal Pattern\", \"Encrypted Datashard\", \"Tarnished Eldan Gift\"."

-- AMPs
L["amps_headline"]         = "AMPs you don't need"
L["amps_headline_tooltip"] = "AMPs you need will be \"needed\" automatically."

-- AMPs and schematics you really need
L["useful_amps_schematics"] = "AMP and Schematics you don't already own"

-- bags
L["bags_headline"]         = "Bags"
L["bags_headline_tooltip"] = "Bags expand your inventory."

-- decor
L["decor_headline"]          = "Decor"
L["decor_headline_tooltip"]  = "Just decor, no FABkits."
L["decor_selected_tooltip"]  = "Do this with decor of the specified quality and below."
L["decor_otherwise_tooltip"] = "Do this with decor above the specified quality."

-- fabkits
L["fabkits_headline"]          = "FABkits"
L["fabkits_headline_tooltip"]  = "For the plugs in your house."
L["fabkits_selected_tooltip"]  = "Do this with FABkits of the specified quality and below."
L["fabkits_otherwise_tooltip"] = "Do this with FABkits above the specified quality."

-- dye
L["dye_headline"]         = "Dye"
L["dye_headline_tooltip"] = "Dye and dye collection."

-- catalysts_my
L["catalysts_my_headline"]          = "Catalysts you could use"
L["catalysts_my_headline_tooltip"]  = "Catalysts help you craft. This box is for catalysts that match one of your tradeskills."
L["catalysts_my_selected_tooltip"]  = "Do this with catalysts of the specified quality and below."
L["catalysts_my_otherwise_tooltip"] = "Do this with catalysts above the specified quality."

-- catalysts_other
L["catalysts_other_headline"]          = "Other Catalysts"
L["catalysts_other_headline_tooltip"]  = "Catalysts that don't match one of your tradeskills."
L["catalysts_other_selected_tooltip"]  = "Do this with catalysts of the specified quality and below."
L["catalysts_other_otherwise_tooltip"] = "Do this with catalysts above the specified quality."

-- schematics
L["schematics_headline"]         = "Schematics you don't need"
L["schematics_headline_tooltip"] = "Schematics you need will be \"needed\" automatically."

-- survivalist
L["survivalist_headline"]         = "Survivalist"
L["survivalist_headline_tooltip"] = "Meat, fish, poultry, leather, bones."

-- cloth
L["cloth_headline"]         = "Cloth"
L["cloth_headline_tooltip"] = "Cloth."

-- profiles
L["profile_management"]  = "Profile Management"
L["profile_title"]       = "Save current settings as new profile with the name:"
L["profile_add"]         = "add"
L["profile_explanation"] = "To change a profile just select it from the combobox at the bottom, do all your settings and then press OK."
L["profile_delete"]      = "delete this profile"

L["profile_turn_off"]    = "turn off"
L["profile_use_profile"] = "use profile"
L["profile_select_that"] = "Use currently selected profile for that case."

L["profile_automatic_headline"]     = "Automatic Profile Selection"
L["profile_automatic_headline_tt"]  = "Select Profiles based on your current location."
L["profile_ini_group"]              = "Group Content in Instances (Dungeons and Adventures)"
L["profile_ini_group_tt"]           = "every instanced content done in a group"
L["profile_group_zero"]             = "guild-intern"
L["profile_group_zero_tt"]          = "all party members are in the same guild you are"
L["profile_group_one"]              = "one random"
L["profile_group_one_tt"]           = "one party member is from another guild"
L["profile_group_two"]              = "two randoms"
L["profile_group_two_tt"]           = "two party members are from another guild"
L["profile_group_three"]            = "three randoms"
L["profile_group_three_tt"]         = "three party members are from another guild"
L["profile_group_four"]             = "you're the random"
L["profile_group_four_tt"]          = "you're the only one from your guild in that party"

L["profile_ini_raid"]    = "Raids in Instances"
L["profile_ini_raid_tt"] = "regular raiding"
L["profile_group"]       = "Groups"
L["profile_group_tt"]    = "in a group in the open world: maybe levelling or doing world bosses"
L["profile_raid"]        = "Raids"
L["profile_raid_tt"]     = "open world events where you group up in raids"

L["profile_automatic"] = "activate automatic profile selection"
L["profile_hudlog"]    = "more obstrusive notifications"

-- messages

-- colon and profile name follow
L["msg_switch_profile"] = "switching to profile"

-- [...] will be replaced by actual values so use them but don't translate them
L["msg_action_log_sentence"]               = "[ACTION] on [ITEM] from category [CATEGORY]."
L["msg_action_log_sentence_need"]          = "Selecting NEED"
L["msg_action_log_sentence_greed"]         = "Selecting GREED"
L["msg_action_log_sentence_pass"]          = "PASSING"
-- [CATEGORY] will be replaced by the Category-Name
-- if it's quality based then a ", " and one of the following is added
L["msg_action_log_sentence_quality_below"] = "of selected quality and below"
L["msg_action_log_sentence_quality_above"] = "above selected quality"

L["msg_activated"]   = "activated"
L["msg_deactivated"] = "deactivated"

L["msg_error_name_missing"] = "Please enter a name for that profile."
L["msg_error_no_delete"]    = "You can not delete the active profile. Activate another profile first."
L["msg_error_keep_last"]    = "You have to keep one profile."

-- other
L["default_profile"] = "default profile"
