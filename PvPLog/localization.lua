--[[
    PvPLog 
    Author:           Brad Morgan
    Based on Work by: Josh Estelle, Daniel S. Reichenbach, Andrzej Gorski, Matthew Musgrove
    Version:          3.0.0
    Last Modified:    2008-03-27
]]

PVPLOG = {};

--Everything From here on would need to be translated and put
--into if statements for each specific language.

--***********
--ENGLISH (DEFAULT)
--***********

    -- Startup messages
    PVPLOG.STARTUP = "PvP Logger %v by %w AddOn loaded. Type /pl for options.";

    PVPLOG.DESCRIPTION = "Keeps track of your PvP kills and the people who kill you.";
    
    -- Commands (must be one word and string.lower)
    PVPLOG.RESET = "reset";
    PVPLOG.ENABLE = "enable";
    PVPLOG.DISABLE = "disable";
    PVPLOG.VER = "version";
    PVPLOG.VEN = "vendor";
    PVPLOG.DISPLAY = "display";
    PVPLOG.DING = "ding";
    PVPLOG.MOUSEOVER = "mouseover";
    PVPLOG.NOSPAM = "nospam";
    PVPLOG.DMG = "damage";
    PVPLOG.ST = "stats";
    PVPLOG.NOTIFYKILL = "notifykill";
    PVPLOG.NOTIFYKILLTEXT = "killtext";
    PVPLOG.NOTIFYDEATH = "notifydeath";
    PVPLOG.NOTIFYDEATHTEXT = "deathtext";
    PVPLOG.UI_CONFIG = "config";
    PVPLOG.KEEP = "keep";
        
    -- Other needed phrases
    PVPLOG.TO = " to ";
    PVPLOG.ON = "on";
    PVPLOG.OFF = "off";
    PVPLOG.NONE = "none";
    PVPLOG.CONFIRM = "confirm";
    PVPLOG.USAGE = "Usage";
    
    PVPLOG.STATS = "Statistics";
    PVPLOG.RECORDS = "Records";
    PVPLOG.COMP = "completely";
    
    PVPLOG.SELF = "Self";
    PVPLOG.PARTY = "Party";
    PVPLOG.SAY = "Say";
    PVPLOG.GUILD = "Guild";
    PVPLOG.RAID = "Raid";
    PVPLOG.RACE = "race";
    PVPLOG.CLASS = "class";
    PVPLOG.ENEMY = "enemy";
    PVPLOG.REALM = "Realm";
    PVPLOG.BG = "Battleground";
        
    -- The following are not being used currently
--  PVPLOG.AB = "Arathi Basin";
--  PVPLOG.AV = "Alterac Valley";
--  PVPLOG.WSG = "Warsong Gulch";
--  PVPLOG.EOS = "Eye of the Storm";
    
    PVPLOG.WIN = "win";
    PVPLOG.LOSS = "loss";
    PVPLOG.WINS = "wins";
    PVPLOG.LOSSES = "losses";
    
    PVPLOG.PLAYER = "Player";
    PVPLOG.RECENT = "Recent";
    PVPLOG.TARGET = "Target";
    PVPLOG.DUEL = "Duel";
    PVPLOG.TOTAL = "Total";
    PVPLOG.ALD = "Avg Level Diff";
    
    PVPLOG.DLKB = "Death logged, killed by: ";
    PVPLOG.KL = "Kill logged: ";
    PVPLOG.DWLA = "Duel win logged against: ";
    PVPLOG.DLLA = "Duel loss logged against: ";
    
    -- Default display text for notify
    PVPLOG.DEFAULT_KILL_TEXT = "I killed %n (Level %l %r %c) at [%x,%y] in %z (%w).";
    PVPLOG.DEFAULT_DEATH_TEXT = "%n (Level %l %r %c) killed me at [%x,%y] in %z (%w).";
    
    PVPLOG.UI_OPEN = "Open";
    PVPLOG.UI_CLOSE = "Close";
    PVPLOG.UI_NOTIFY_KILLS = "Notify kills to:";
    PVPLOG.UI_NOTIFY_DEATHS = "Notify deaths to:";
    PVPLOG.UI_CUSTOM = "Custom";
    PVPLOG.UI_ENABLE = "Enable PvPLog";
    PVPLOG.UI_MOUSEOVER = "Mouseover effects";
    PVPLOG.UI_DING = "Audio Ding";
    PVPLOG.UI_DISPLAY = "Floating text messages";
    PVPLOG.UI_NOTIFY_NONE = "None";
    PVPLOG.UI_DING_TIP = "When you mouse-over a player you\nhave fought before a sound will play.";
    PVPLOG.UI_PVP = "PvP";
    PVPLOG.UI_NAME = "Name";
    PVPLOG.UI_RACE = "Race";
    PVPLOG.UI_CLASS = "Class";
    PVPLOG.UI_LDIFF = "L Diff"
    PVPLOG.UI_LEVEL = "Level"
    PVPLOG.UI_WINS = "Wins";
    PVPLOG.UI_LOSSES = "Losses";
    PVPLOG.UI_FLAGS = "Flags";
    PVPLOG.UI_TOGGLE = "Toggles " .. PVPLOG.UI_CONFIG;
    PVPLOG.UI_TOGGLE2 = "Toggles " .. PVPLOG.STATS;
    PVPLOG.UI_RIGHT_CLICK = "Right click: ";
    PVPLOG.UI_LEFT_CLICK = "Left click: ";
    PVPLOG.UI_MINIMAP_BUTTON = "Minimap Button";
    PVPLOG.UI_RECORD_BG = "Record in Battlegrounds";
    PVPLOG.UI_RECORD_DUEL = "Record Duels";
    PVPLOG.UI_NOTIFY_BG = "Notify in Battlegrounds";
    PVPLOG.UI_NOTIFY_DUEL = "Notify Duels";

    PVPLOG.TT_LEVEL = "Level "
    PVPLOG.TT_PLAYER = "Level ([%d%?]+) (%w+%s*%w*) (%w+) %(Player%)" 
    PVPLOG.TT_PET = "'s Pet"
    PVPLOG.TT_MINION = "'s Minion"
    PVPLOG.TT_CREATION = "'s Creation"
    PVPLOG.TT_GUARDIAN = "'s Guardian"
    PVPLOG.TT_LEVEL2 = "Level ([%d%?]+)"

--***********
-- GERMAN
--***********
if (GetLocale() == "deDE") then
    -- Translated by (): yamyam

    -- Startup messages
    PVPLOG.STARTUP = "PvP Logger %v von %w AddOn geladen. Tippe /pl für Optionen.";
    
    PVPLOG.DESCRIPTION = "Zeichnet PvP Siege und Verluste auf, sowie Duelle.";

    -- Commands (must be one word and string.lower)
    PVPLOG.RESET = "zurücksetzen";
    PVPLOG.ENABLE = "aktivieren"; -- "einschalten"    
    PVPLOG.DISABLE = "deaktivieren"; -- "ausschalten"  
    PVPLOG.VER = "version";      -- version? versionsnummer?
    PVPLOG.VEN = "verk\195\164ufer"; -- verkufer?
    PVPLOG.DISPLAY = "anzeige";  
    PVPLOG.DING = "ding";
    PVPLOG.MOUSEOVER = "maus\195\188ber";
    PVPLOG.NOSPAM = "nospam";
    PVPLOG.DMG = "schaden";
    PVPLOG.ST = "stats";
    PVPLOG.NOTIFYKILL = "killanzeige";
    PVPLOG.NOTIFYKILLTEXT = "killtext";
    PVPLOG.NOTIFYDEATH = "todesanzeige";
    PVPLOG.NOTIFYDEATHTEXT = "todestext";
    PVPLOG.UI_CONFIG = "konfiguration";
    PVPLOG.KEEP = "behalten";
    
    -- Other needed phrases
    PVPLOG.TO = " zu ";
    PVPLOG.ON = "an";
    PVPLOG.OFF = "aus";
    PVPLOG.NONE = "keine";        
    PVPLOG.CONFIRM = "bestätigen";  
    PVPLOG.USAGE = "Usage";      -- verwenden?
    
    PVPLOG.STATS = "Statistik";
    PVPLOG.RECORDS = "Aufzeichnungen";
    PVPLOG.COMP = "komplett";
    
    PVPLOG.SELF = "Selbst";
    PVPLOG.SAY = "Sagen";
    PVPLOG.PARTY = "Gruppe";
    PVPLOG.GUILD = "Gilde";
    PVPLOG.RAID = "Schlachtzug";
    PVPLOG.RACE = "Rasse";
    PVPLOG.CLASS = "Klasse";
    PVPLOG.ENEMY = "Feind";
    PVPLOG.BG = "Schlachtfeld";
    
--  PVPLOG.AB = "Arathibecken";
--  PVPLOG.AV = "Alteractal";
--  PVPLOG.WSG = "Warsongschlucht";
--  PVPLOG.EOS = "Auge des Sturms";

    PVPLOG.WIN = "sieg";
    PVPLOG.LOSS = "niederlage"; -- "verlor"
    PVPLOG.WINS = "siege";
    PVPLOG.LOSSES = "niederlagen"; -- "verloren"
    
    PVPLOG.PLAYER = "Spieler";
    PVPLOG.RECENT = "Bekannt";
    PVPLOG.TARGET = "Ziel";
    PVPLOG.DUEL = "Duelle"; -- "Duell"
    PVPLOG.TOTAL = "Summe";
    PVPLOG.ALD = "Durchschnittlicher Levelunterschied";
        
    PVPLOG.DLKB = "Tod geloggt, getötet von: ";
    PVPLOG.KL = "Tod geloggt: ";
    PVPLOG.DWLA = "Duell gewonnen gegen: ";
    PVPLOG.DLLA = "Duell verloren gegen: ";

    -- Default display text for notify
    PVPLOG.DEFAULT_KILL_TEXT = "Ich habe %n (Level %l %r %c) bei [%x,%y] in %z (%w) getötet.";
    PVPLOG.DEFAULT_DEATH_TEXT = "%n (Level %l %r %c) hat mich bei [%x,%y] in %z (%w) getötet.";
    
    PVPLOG.UI_OPEN = "Öffnen";
    PVPLOG.UI_CLOSE = "Schließen";
    PVPLOG.UI_NOTIFY_KILLS = "Kills anzeigen in:";
    PVPLOG.UI_NOTIFY_DEATHS = "Tode anzeigen in:";
    PVPLOG.UI_CUSTOM = "Custom";
    PVPLOG.UI_ENABLE = "PvPLog einschalten";
    PVPLOG.UI_MOUSEOVER = "Mouseover Effekte";
    PVPLOG.UI_DING = "Audio Ding-Sound";
    PVPLOG.UI_DISPLAY = "Floating text messages";
    PVPLOG.UI_NOTIFY_NONE = "Keine";
    PVPLOG.UI_DING_TIP = "Wenn Du mit der Maus \195\182ber einen Gegner f\195\164hrst\n, den Du vorher bek\195\164mpft hast, dann ert\195\182nt ein Signalton.";
    PVPLOG.UI_PVP = "PvP";
    PVPLOG.UI_NAME = "Name";
    PVPLOG.UI_RACE = "Rasse";
    PVPLOG.UI_CLASS = "Klasse";
    PVPLOG.UI_LDIFF = "L Diff"
    PVPLOG.UI_LEVEL = "Level"
    PVPLOG.UI_WINS = "Siege";
    PVPLOG.UI_LOSSES = "Niederlagen"; -- "Verloren"
    PVPLOG.UI_FLAGS = "Flags";
    PVPLOG.UI_TOGGLE = PVPLOG.UI_CONFIG .. " anzeigen/verbergen";
    PVPLOG.UI_TOGGLE2 = PVPLOG.STATS .. " anzeigen/verbergen";
    PVPLOG.UI_RIGHT_CLICK = "Rechtsklick: ";
    PVPLOG.UI_LEFT_CLICK = "Linksklick: ";
    PVPLOG.UI_MINIMAP_BUTTON = "Minimap Button";
    PVPLOG.UI_RECORD_BG = "Schlachtfelder\naufzeichnen";
    PVPLOG.UI_RECORD_DUEL = "Duelle aufzeichnen";
    PVPLOG.UI_NOTIFY_BG = "BG-Benachrichtigung";
    PVPLOG.UI_NOTIFY_DUEL = "Duellbenachrichtigung";

    PVPLOG.TT_LEVEL = "Level "
    PVPLOG.TT_PLAYER = "Level ([%d%?]+) (%w+%s*%w*) (%w+) %(Player%)" 
    PVPLOG.TT_PET = "Begleiter von " --- Begleiter von Name
    PVPLOG.TT_MINION = "Diener von " --- Diener von Name
    PVPLOG.TT_CREATION = "Creation von "
    PVPLOG.TT_LEVEL2 = "Level ([%d%?]+)"

elseif (GetLocale() == "frFR") then
    -- Translated by (): Exerladan

    -- Startup messages
    PVPLOG.STARTUP = "PvP Logger %v par %w chargé. Tapez /pl pour les options.";
    
    PVPLOG.DESCRIPTION = "Enregistre les victoires et les défaites JcJ.";

    -- Commands (must be one word and string.lower)
    PVPLOG.RESET = "raz";      -- 
    PVPLOG.ENABLE = "activer";    -- permettre?
    PVPLOG.DISABLE = "desactiver";  -- 
    PVPLOG.VER = "version";      -- version?
    PVPLOG.VEN = "fournisseur";       -- fournisseur?
    PVPLOG.DISPLAY = "montre";  -- montrer?
    PVPLOG.DING = "ding";
    PVPLOG.MOUSEOVER = "sourisaudessus";
    PVPLOG.NOSPAM = "sansspam";
    PVPLOG.DMG = "degats";
    PVPLOG.ST = "stats";
    PVPLOG.NOTIFYKILL = "notifiervictoires";
    PVPLOG.NOTIFYKILLTEXT = "textedevictoire";
    PVPLOG.NOTIFYDEATH = "notifierdefaites";
    PVPLOG.NOTIFYDEATHTEXT = "textededefaite";
    PVPLOG.UI_CONFIG = "configuration";
    PVPLOG.KEEP = "keep";

    -- Other needed phrases
    PVPLOG.TO = " à ";          -- ?
    PVPLOG.ON = "actif";            -- sur?
    PVPLOG.OFF = "inactif";          -- 
    PVPLOG.NONE = "aucun";        -- aucun?
    PVPLOG.CONFIRM = "confirmer";  -- confirmer?
    PVPLOG.USAGE = "Utilisation";      -- utilisation?
    
    PVPLOG.STATS = "Statistiques";
    PVPLOG.RECORDS = "Records";
    PVPLOG.COMP = "completement";
    
    PVPLOG.SELF = "Soi";
    PVPLOG.SAY = "Say"; --translation needed
    PVPLOG.PARTY = "Groupe";
    PVPLOG.GUILD = "Guilde";
    PVPLOG.RAID = "Raid";
    PVPLOG.RACE = "race";
    PVPLOG.CLASS = "classe";
    PVPLOG.ENEMY = "ennemi";
    PVPLOG.BG = "Champ de bataille";

--  PVPLOG.AB = "Bassin d'Arathi";
--  PVPLOG.AV = "Vallée d'Alterac";
--  PVPLOG.WSG = "Goulet de Chanteguerre";
    
    PVPLOG.WIN = "victoire";
    PVPLOG.LOSS = "défaite";
    PVPLOG.WINS = "victoires";
    PVPLOG.LOSSES = "défaites";
    
    PVPLOG.WIN = "win";
    PVPLOG.LOSS = "loss";
    PVPLOG.WINS = "wins";
    PVPLOG.LOSSES = "losses";
    
    PVPLOG.PLAYER = "Player";
    PVPLOG.RECENT = "Recent";
    PVPLOG.TARGET = "Target";
    PVPLOG.DUEL = "Duel";
    PVPLOG.TOTAL = "Total";
    PVPLOG.ALD = "différence moyenne de niveaux";
    
    PVPLOG.DLKB = "Mort enregistrée, tué par : ";
    PVPLOG.KL = "Victoire enregistrée : ";
    PVPLOG.DWLA = "Duel gagnant logué contre : ";
    PVPLOG.DLLA = "Duel perdant logué contre : ";
    
    -- Default display text for notify
    PVPLOG.DEFAULT_KILL_TEXT = "J'ai tué %n (Niveau %l %r %c) à [%x,%y] en %z (%w).";
    PVPLOG.DEFAULT_DEATH_TEXT = "%n (Niveau %l %r %c) m'a tué à [%x,%y] en %z (%w).";

    PVPLOG.UI_OPEN = "Ouvrir";
    PVPLOG.UI_CLOSE = "Fermer";
    PVPLOG.UI_NOTIFY_KILLS = "Notifier victoires :";
    PVPLOG.UI_NOTIFY_DEATHS = "Notifier morts :";
    PVPLOG.UI_CUSTOM = "Personnalisé";
    PVPLOG.UI_ENABLE = "Activer PvPLog";
    PVPLOG.UI_MOUSEOVER = "Effets passage de la souris";
    PVPLOG.UI_DING = "Avertissement audio";
    PVPLOG.UI_DISPLAY = "Messages texte flotant";
    PVPLOG.UI_NOTIFY_NONE = "Aucun";
    PVPLOG.UI_DING_TIP = "Quand vous passez avec la souris au dessus d'un joueur\nque vous avez combattu, vous entendrez un son.";
    PVPLOG.UI_PVP = "JcJ";
    PVPLOG.UI_NAME = "Nom";
    PVPLOG.UI_RACE = "Race";
    PVPLOG.UI_CLASS = "Class";
    PVPLOG.UI_LDIFF = "L Diff"
    PVPLOG.UI_LEVEL = "Level"
    PVPLOG.UI_WINS = "Victoires";
    PVPLOG.UI_LOSSES = "Défaites";   
    PVPLOG.UI_FLAGS = "Flags";
    PVPLOG.UI_TOGGLE = "Montre " .. PVPLOG.UI_CONFIG;
    PVPLOG.UI_TOGGLE2 = "Montre " .. PVPLOG.STATS;
    PVPLOG.UI_RIGHT_CLICK = "Clic droit : ";
    PVPLOG.UI_LEFT_CLICK = "Clic gauche : ";
    PVPLOG.UI_MINIMAP_BUTTON = "Bouton sur la mini-carte";
    PVPLOG.UI_RECORD_BG = "Enregistrer sur les champs de bataille";
    PVPLOG.UI_RECORD_DUEL = "Enregistrer les duels";
    PVPLOG.UI_NOTIFY_BG = "Notifier sur les champs de bataille";
    PVPLOG.UI_NOTIFY_DUEL = "Notifier les duels";
    
    PVPLOG.TT_LEVEL = "Level "
    PVPLOG.TT_PLAYER = "Level ([%d%?]+) (%w+%s*%w*) (%w+) %(Player%)" 
    PVPLOG.TT_PET = "'s Pet"
    PVPLOG.TT_MINION = "'s Minion"
    PVPLOG.TT_CREATION = "'s Creation"
    PVPLOG.TT_LEVEL2 = "Level ([%d%?]+)"

elseif (GetLocale() == "esES") then
-- Translated by (traducido por): NeKRoMaNT

    -- Startup messages
    PVPLOG.STARTUP = "PvP Logger %v por %w AddOn cargado. Mecanografiar /pl para las opciones.";
    
    PVPLOG.DESCRIPTION = "Hace un seguimiento de tus asesinatos JcJ y de la gente que te ha asesinado.";

    -- Commands (must be one word and string.lower)
    PVPLOG.RESET = "resetear";
    PVPLOG.ENABLE = "activar";
    PVPLOG.DISABLE = "desactivar";
    PVPLOG.DISPLAY = "mostrar";
    PVPLOG.DING = "ding";
    PVPLOG.MOUSEOVER = "mouseover";
    PVPLOG.NOSPAM = "nospam";
    PVPLOG.DMG = "da\195\177o";
    PVPLOG.ST = "estad\195\173sticas";
    PVPLOG.NOTIFYKILL = "notificar asesinato"; -- "Aviso de Asesinatos"
    PVPLOG.NOTIFYKILLTEXT = "texto asesinato";
    PVPLOG.NOTIFYDEATH = "notificar muerte"; -- "Aviso de Muertes"
    PVPLOG.NOTIFYDEATHTEXT = "texto muerte";
    PVPLOG.UI_CONFIG = "configuraci\195\179n";
    PVPLOG.KEEP = "keep";

    -- Other needed phrases
    PVPLOG.TO = " a ";
    PVPLOG.ON = "Encendido";
    PVPLOG.OFF = "Apagado";
    PVPLOG.NONE = "Ninguno";
    PVPLOG.CONFIRM = "Confirmar";
    PVPLOG.VER = "Versi\195\179n";
    PVPLOG.VEN = "Vendedor";
    PVPLOG.USAGE = "Uso";
    
    PVPLOG.STATS = "Estad\195\173sticas";
    PVPLOG.RECORDS = "Records";
    PVPLOG.COMP = "Completamente";
    
    PVPLOG.SELF = "M\195\173";
    PVPLOG.SAY = "Say"; --translation needed
    PVPLOG.PARTY = "Grupo";
    PVPLOG.GUILD = "Hermandad";
    PVPLOG.RAID = "Banda";
    PVPLOG.RACE = "Raza";
    PVPLOG.CLASS = "Clase";
    PVPLOG.ENEMY = "Enemigo";
    PVPLOG.BG = "Campo de Batalla";
    
--  PVPLOG.AB = "Cuenca de Arathi";
--  PVPLOG.AV = "Valle de Alterac";
--  PVPLOG.WSG = "Garganta Grito de Guerra";
    
    PVPLOG.WIN = "gana";
    PVPLOG.LOSS = "pierde";
    PVPLOG.WINS = "Victorias";
    PVPLOG.LOSSES = "Derrotas";
    
    PVPLOG.PLAYER = "Jugador";
    PVPLOG.RECENT = "Reciente";
    PVPLOG.TARGET = "Target";
    PVPLOG.DUEL = "Duelo";
    PVPLOG.TOTAL = "Total";
    PVPLOG.ALD = "Diferencia de Nivel";
    
    PVPLOG.DLKB = "Muerte grabada, asesinado por: ";
    PVPLOG.KL = "Asesinato grabado: ";
    PVPLOG.DWLA = "Victoria en duelo grabada contra: ";
    PVPLOG.DLLA = "Derrota en duelo grabada contra: ";
    
    -- Default display text for notify
    PVPLOG.DEFAULT_KILL_TEXT = "He asesinado a %n (Nivel %l %r %c) en [%x,%y] en %z (%w).";
    PVPLOG.DEFAULT_DEATH_TEXT = "%n (Nivel %l %r %c) me ha asesinado en [%x,%y] en %z (%w).";
       
    PVPLOG.UI_OPEN = "Abrir";
    PVPLOG.UI_CLOSE = "Cerrar";
    PVPLOG.UI_NOTIFY_KILLS = "Notificar asesinatos a:";
    PVPLOG.UI_NOTIFY_DEATHS = "Notificar muertes a:";
    PVPLOG.UI_CUSTOM = "Personalizar";
    PVPLOG.UI_ENABLE = "Activar PvPLog";
    PVPLOG.UI_MOUSEOVER = "Efectos Mouseover";
    PVPLOG.UI_DING = "Utilizar Audio";
    PVPLOG.UI_DISPLAY = "Mensajes Emergentes";
    PVPLOG.UI_NOTIFY_NONE = "Nadie";
    PVPLOG.UI_DING_TIP = "Cuando pases el rat\195\179n sobre un jugador contra \nquien hayas luchado sonar\195\161 una se\195\177al.";
    PVPLOG.UI_PVP = "JcJ";
    PVPLOG.UI_NAME = "Nombre";
    PVPLOG.UI_RACE = "Race";
    PVPLOG.UI_CLASS = "Class";
    PVPLOG.UI_LDIFF = "L Diff"
    PVPLOG.UI_LEVEL = "Level"
    PVPLOG.UI_WINS = "Victorias";
    PVPLOG.UI_LOSSES = "Derrotas";
    PVPLOG.UI_FLAGS = "Flags";
    PVPLOG.UI_RIGHT_CLICK = "Clic derecho: ";
    PVPLOG.UI_LEFT_CLICK = "Clic izquierdo: ";
    PVPLOG.UI_TOGGLE = "Muestra/oculta " .. PVPLOG.UI_CONFIG;
    PVPLOG.UI_TOGGLE2 = "Muestra/oculta " .. PVPLOG.STATS;
    PVPLOG.UI_MINIMAP_BUTTON = "Bot\195\179n de Minimapa";
    PVPLOG.UI_RECORD_BG = "Historial en Campos de Batalla";
    PVPLOG.UI_RECORD_DUEL = "Historial de Duelos";
    PVPLOG.UI_NOTIFY_BG = "Notificar en Campos de Batalla";
    PVPLOG.UI_NOTIFY_DUEL = "Notificar Duelos";

    PVPLOG.TT_LEVEL = "Level "
    PVPLOG.TT_PLAYER = "Level ([%d%?]+) (%w+%s*%w*) (%w+) %(Player%)" 
    PVPLOG.TT_PET = "'s Pet"
    PVPLOG.TT_MINION = "'s Minion"
    PVPLOG.TT_CREATION = "'s Creation"
    PVPLOG.TT_LEVEL2 = "Level ([%d%?]+)"

end
