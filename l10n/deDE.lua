local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("AfLogicLoot", "deDE")
if not L then return end -- in non-default!

-- DON'T EDIT WITH HOUSTON AS IT LOSES ENCODING SETTINGS
-- USE SOMETHING LIKE NOTEPAD++ FOR THAT TASK

-- Tabs
L["equipment1"] = "Equipment 1"
L["equipment2"] = "Equipment 2"
L["style"]      = "Style"
L["crafting"]   = "Crafting"
L["profiles"]   = "Profile"

-- global options
L["chk_log"] = "automatische Aktionen im Chat ausgeben"

-- quality
L["inferior"]         = "minderwertig"
L["average"]          = "mittel"
L["good"]             = "gut"
L["excellent"]        = "ausgezeichnet"
L["superb"]           = "super"
L["legendary"]        = "legendär"
L["artifact"]         = "Artefakt"
-- "Major" like in "Sign of Water - Major"
L["excellent_major"]  = "ausgezeichnet (übergeordnet)"
-- "Sign of Water - Eldan"
L["superb_eldan"]     = "super (eldanisch)"

-- actions
L["need"]      = "Bedarf"
L["greed"]     = "Gier"
L["pass"]      = "passen"
L["no_action"] = "keine Aktion"

-- category side labels
L["quality_below"] = "von dieser Qualität und darunter"
L["action"]        = "Aktion"
L["no_need"]       = "kein Bedarf"
L["selected"]      = "ausgewählt"
L["otherwise"]     = "ansonsten"

-- equipment
L["equipment_headline"]         = "Equipment"
L["equipment_headline_tooltip"] = "Rüstung, Ausrüstung und Waffen"
L["equipment_action_tooltip"]   = "Führe diese Aktion bei Equipment der ausgewählten Qualitätsstufe oder darunter aus. Es gibt keine Möglichkeit, \"Bedarf\" zu wählen. Du solltest nur \"Bedarf\" wählen, wenn Du vor hast, das Equipment auszurüsten. Ansonsten wähle bitte \"Gier\". Dies ist der einzig faire Weg für alle, auch wirklich Equipment zu erhalten, das sie tragen können und wollen."
L["equipment_no_need_tooltip"]  = "Führe diese Aktion bei Equipment durch, bei dem du nicht \"Bedarf\" wählen kannst."
L["equipment_not_wearable"]     = "nicht ausrüstbar"

-- sigils
L["sigils_headline"]          = "Sigille"
L["sigils_headline_tooltip"]  = "Material wie \"Zeichen des Wassers\"."
L["sigils_selected_tooltip"]  = "Führe diese Aktion bei Sigillen der ausgewählten Qualitätsstufe oder darunter aus."
L["sigils_otherwise_tooltip"] = "Führe diese Aktion bei Sigillen über der ausgewählten Qualitätsstufe aus."

-- fragments
L["fragments_headline"]         = "Fragmente"
L["fragments_headline_tooltip"] = "Material wie \"augmentiertes Runenfragment\" oder \"Runenfragment des Espers\"."

-- runic flux
L["flux_headline"]         = "Runenflux"
L["flux_headline_tooltip"] = "\"Runen-Elementar-Flux\" und \"Eldanisches Runenmodul\", Material zum Ändern und Freischalten von Runen-Slots."

-- proprietary material
L["prop_headline"]         = "Geheimes Material"
L["prop_headline_tooltip"] = "\"Unvollständiges Urmuster\", \"verschlüsselter Datensplitter\", \"beschädigtes eldanisches Geschenk\"."

-- AMPs
L["amps_headline"]         = "VIPs ohne Nutzen"
L["amps_headline_tooltip"] = "Bei VIPs, die du noch brauchst, wird automatisch \"Bedarf\" gewählt."

-- AMPs and schematics you really need
L["useful_amps_schematics"] = "VIPs und Rezepte, die du noch nicht besitzt"

-- bags
L["bags_headline"]         = "Taschen"
L["bags_headline_tooltip"] = "Taschen erweitern deinen Platz im Rucksack."

-- scanbot vanity
L["scanbot_headline"]         = "ScanBot-Schmuck"
L["scanbot_headline_tooltip"] = "Zeug, das man an den ScanBot anbauen kann."

-- decor
L["decor_headline"]          = "Dekor"
L["decor_headline_tooltip"]  = "Nur Dekor, keine BAUsätze,"
L["decor_selected_tooltip"]  = "Führe diese Aktion bei Dekor der ausgewählten Qualitätsstufe oder darunter aus."
L["decor_otherwise_tooltip"] = "Führe diese Aktion bei Dekor über der ausgewählten Qualitätsstufe aus."

-- fabkits
L["fabkits_headline"]          = "BAUsätze"
L["fabkits_headline_tooltip"]  = "Für die Bauplätze in deinem Haus."
L["fabkits_selected_tooltip"]  = "Führe diese Aktion bei BAUsätzen der ausgewählten Qualitätsstufe oder darunter aus."
L["fabkits_otherwise_tooltip"] = "Führe diese Aktion bei BAUsätzen über der ausgewählten Qualitätsstufe aus."

-- dye
L["dye_headline"]         = "Farbstoffe"
L["dye_headline_tooltip"] = "Farbstoffe und Farbstoff-Sammlungen."

-- catalysts_my
L["catalysts_my_headline"]          = "Katalysatoren von Nutzen"
L["catalysts_my_headline_tooltip"]  = "Katalysatoren helfen dir beim Craften. Dieser Kasten ist für Katalysatoren, die zu einem deiner Handwerksberufe passen."
L["catalysts_my_selected_tooltip"]  = "Führe diese Aktion bei Katalysatoren der ausgewählten Qualitätsstufe oder darunter aus."
L["catalysts_my_otherwise_tooltip"] = "Führe diese Aktion bei Katalysatoren über der ausgewählten Qualitätsstufe aus."

-- catalysts_other
L["catalysts_other_headline"]          = "andere Katalysatoren"
L["catalysts_other_headline_tooltip"]  = "Katalysatoren, die zu keinem deiner Handwerksberufe passen"
L["catalysts_other_selected_tooltip"]  = "Führe diese Aktion bei Katalysatoren der ausgewählten Qualitätsstufe oder darunter aus."
L["catalysts_other_otherwise_tooltip"] = "Führe diese Aktion bei Katalysatoren über der ausgewählten Qualitätsstufe aus."

-- schematics
L["schematics_headline"]         = "Rezepte ohne Nutzen"
L["schematics_headline_tooltip"] = "Bei Rezepten, die du noch benötigst, wird automatisch \"Bedarf\" gewählt."

-- survivalist
L["survivalist_headline"]         = "Überlebenskünstler"
L["survivalist_headline_tooltip"] = "Fleisch, Fisch, Geflügel, Leder, Knochen."

-- cloth
L["cloth_headline"]         = "Kleidung"
L["cloth_headline_tooltip"] = "Kleidung."

-- profiles
L["profile_management"]  = "Profil-Management"
L["profile_title"]       = "Speichere aktuelle Einstellungen als neues Profil mit dem Namen:"
L["profile_add"]         = "hinzufügen"
L["profile_explanation"] = "Um ein Profil zu verändern, wähle es unten aus dem Drop-Down-Feld aus, führe dann alle Einstellungen durch und klicke anschließend auf OK."
L["profile_delete"]      = "dieses Profil löschen"

L["profile_turn_off"]    = "ausschalten"
L["profile_use_profile"] = "nutze Profil:"
L["profile_select_that"] = "Benutze aktuell ausgewähltes Profil für diesen Fall."

L["profile_automatic_headline"]     = "automatische Profil-Auswahl"
L["profile_automatic_headline_tt"]  = "Wähle Profile aufgrund deines aktuellen Aufenthaltsortes."
L["profile_ini_group"]              = "Gruppen-Content in Instanzen (Dungeons und Abenteuer)"
L["profile_ini_group_tt"]           = "jeder instanziierter Content, der in einer Gruppe gespielt wird"
L["profile_group_zero"]             = "gilden-intern"
L["profile_group_zero_tt"]          = "alle Gruppenmitglieder sind in der selben Gilde wie du"
L["profile_group_one"]              = "ein Random"
L["profile_group_one_tt"]           = "ein Gruppenmitglied ist von einer anderen Gilde"
L["profile_group_two"]              = "zwei Randoms"
L["profile_group_two_tt"]           = "zwei Gruppenmitglieder sind von einer anderen Gilde"
L["profile_group_three"]            = "drei Randoms"
L["profile_group_three_tt"]         = "drei Gruppenmitglieder sind von einer anderen Gilde"
L["profile_group_four"]             = "du bist der Random"
L["profile_group_four_tt"]          = "du bist der einzige von deiner Gilde in dieser Gruppe"

L["profile_ini_raid"]    = "Raids in Instanzen"
L["profile_ini_raid_tt"] = "normales Raiden"
L["profile_group"]       = "Gruppen"
L["profile_group_tt"]    = "in einer Gruppe in der freien Welt: vielleicht Leveln oder Welt-Bosse töten"
L["profile_raid"]        = "Raids"
L["profile_raid_tt"]     = "Events in der freien Welt, bei denen man sich in Raids sammelt"

L["profile_automatic"]    = "automatische Profil-Auswahl aktivieren"
L["profile_hudlog"]       = "aufdringlichere Benachrichtigung"
L["profile_log_scene"]    = "auch Szenenwechsel melden"
L["profile_statistic"]    = "zeige Loot-Statistik nach Dungeon"

-- messages
-- [...] will be replaced by actual values so use them but don't translate them

-- colon and profile name follow
L["msg_switch_profile"] = "wechsle zu Profil"
L["msg_statistic1"] = "[LOOTED] Mal automatisch gewürfelt."
L["msg_statistic2"] = "Du hast [WON] Items erhalten."
L["msg_statistic3"] = "Das sind [PERCENT] Prozent des Gesamtloots."

L["msg_action_log_sentence"]               = "[ACTION] auf [ITEM] aus der Kategorie [CATEGORY]."
L["msg_action_log_sentence_need"]          = "Wähle BEDARF"
L["msg_action_log_sentence_greed"]         = "Wähle GIER"
L["msg_action_log_sentence_pass"]          = "PASSE"
-- [CATEGORY] will be replaced by the Category-Name
-- if it's quality based then a ", " and one of the following is added
L["msg_action_log_sentence_quality_below"] = "von ausgewählter Qualität oder darunter"
L["msg_action_log_sentence_quality_above"] = "über ausgewählter Qualität"

L["msg_activated"]   = "aktiviert"
L["msg_deactivated"] = "deaktiviert"

L["msg_error_name_missing"] = "Bitte gib einen Namen für das Profil ein."
L["msg_error_no_delete"]    = "Du kannst nicht das aktuelle Profil löschen. Aktiviere zuerst ein anderes Profil."
L["msg_error_keep_last"]    = "Du musst ein Profil behalten."

-- other
L["default_profile"] = "Standard-Profil"
