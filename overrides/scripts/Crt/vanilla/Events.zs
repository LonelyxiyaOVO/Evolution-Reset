#
import crafttweaker.events.IEventManager;
import crafttweaker.event.CommandEvent;
import crafttweaker.player.IPlayer;
import crafttweaker.event.PlayerRespawnEvent;
import crafttweaker.event.PlayerLoggedInEvent;
import crafttweaker.data.IData;
import crafttweaker.command.ICommandManager;
import crafttweaker.text.ITextComponent;
import crafttweaker.event.PlayerSleepInBedEvent;
import crafttweaker.event.BlockBreakEvent;
import crafttweaker.block.IBlockDefinition;
import crafttweaker.block.IBlock;
import crafttweaker.oredict.IOreDictEntry;
import crafttweaker.world.IWorld;
import crafttweaker.world.IWorldInfo;
import crafttweaker.event.PlayerInteractBlockEvent;
import crafttweaker.event.PlayerAdvancementEvent;
import crafttweaker.event.PortalSpawnEvent;
import crafttweaker.event.PlayerBonemealEvent;
import crafttweaker.event.EntityJoinWorldEvent;
import crafttweaker.entity.IEntityDefinition;
import crafttweaker.event.EntityLivingDeathDropsEvent;
import crafttweaker.entity.IEntityItem;
import crafttweaker.entity.IEntityMob;
import crafttweaker.event.PlayerInteractEntityEvent;

events.onPlayerInteractBlock(function(event as PlayerInteractBlockEvent) {
var player = event.player;
var id = event.block.definition.id;
    if ((id == "minecraft:furnace") || (id == "minecraft:crafting_table")) {
        if (!event.world.isRemote()) {
            player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.broken"));
        }
        event.cancel();
    }
});

events.onPlayerBonemeal(function(event as PlayerBonemealEvent) {
    event.cancel();
});

events.onPlayerInteractEntity(function(event as PlayerInteractEntityEvent) {
    if(event.target.nbt.asString().contains("minecraft:smith")) {
        event.cancel();
    }
});

events.onEntityLivingDeathDrops(function(event as EntityLivingDeathDropsEvent) {
    if(event.entity instanceof IPlayer) return;
    for drop in event.drops {
        var itemdrop = drop.item.definition.name;
        for item in <ore:banitems>.items {
	        if(itemdrop == item.definition.name) {
		        event.cancel();
		    }
        }
    }
});

events.onPlayerRespawn(function(event as PlayerRespawnEvent) {
    val player as IPlayer = event.player;
    player.addPotionEffect(<potion:minecraft:invisibility>.makePotionEffect(12000, 5));
	player.addPotionEffect(<potion:minecraft:night_vision>.makePotionEffect(6000, 5));
    player.addPotionEffect(<potion:minecraft:hunger>.makePotionEffect(400, 1));
});

events.onPlayerAdvancement(function(event as PlayerAdvancementEvent) {
    val player as IPlayer = event.player;
    player.xp += 5;
});

var mobsone = [
"Witch",
"Zombie",
"ZombieVillager",
"Husk",
"Slime",
"ZombieHorse",
"SkeletonHorse",
"tconstruct.blueslime",
"pyrotech.mud",
"LavaSlime",
"PigZombie",
"WitherSkeleton",
"Spider",
"Skeleton",
"Stray",
"Creeper",
"Enderman",
"CaveSpider",
"Ghast"
] as string[];


var mobstwo = [
"mutantbeasts.body_part",
"mutantbeasts.chemical_x",
"mutantbeasts.creeper_minion",
"mutantbeasts.creeper_minion_egg",
"mutantbeasts.endersoul_clone",
"mutantbeasts.endersoul_fragment",
"mutantbeasts.mutant_arrow",
"mutantbeasts.mutant_creeper",
"mutantbeasts.mutant_enderman",
"mutantbeasts.mutant_skeleton",
"mutantbeasts.mutant_snow_golem",
"mutantbeasts.mutant_zombie",
"mutantbeasts.skull_spirit",
"mutantbeasts.spider_pig",
"mutantbeasts.throwable_block"
] as string[];

events.onEntityJoinWorld(function(event as EntityJoinWorldEvent) {
    val entity = event.entity;
    val time = event.world.getWorldInfo().getWorldTotalTime();
    if(!entity instanceof IEntityMob) return;
    for mobone in mobsone {
        if(entity.definition.name == mobone) {
            if(time < 552000) {
                event.cancel();
            }
        }
    }
    for mobtwo in mobstwo {
        if(entity.definition.id == mobtwo) {
            if(time < 768000) {
                event.cancel();
            }
        }
    }
});

events.onPlayerLoggedIn(function(event as PlayerLoggedInEvent) {
    var player = event.player as IPlayer;
    var ser = server.commandManager as ICommandManager;
    val time = player.world.getWorldInfo().getWorldTotalTime();
    if(time < 552000) {
        if(!isNull(player.data.wasGivenTip1)) return;
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.login.tip1"));
        player.update({wasGivenTip1: true});
    } else if(time < 768000) {
        if(!isNull(player.data.wasGivenTip2)) return;
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.login.tip2"));
        player.update({wasGivenTip2: true});
    } else if(isNull(player.data.wasGivenTip3)) {
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.login.tip3"));
        player.update({wasGivenTip3: true});
    }
    if (forcegamemode == true) {
        ser.executeCommand(server, "gamemode survival " + player.name);
    }
});

events.onPlayerSleepInBed(function(event as PlayerSleepInBedEvent) {
    val player as IPlayer = event.player;
	player.addPotionEffect(<potion:minecraft:hunger>.makePotionEffect(200, 2));
});

if (disablecommand == true) {
events.onCommand(function(event as CommandEvent) {
   val command = event.command;
   if((command.name == "backup") || (command.name == "ct") || (command.name == "crafttweaker") || (command.name == "team")) {
       return;
   }
   else if (event.commandSender instanceof IPlayer) {
   val player as IPlayer = event.commandSender;
   player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.command.tip"));
   event.cancel(); 
   }
});
}

events.onBlockBreak(function(event as BlockBreakEvent) {
if((event.world.remote) || (!event.isPlayer)) return;
if(!event.player.creative) {
	val player as IPlayer = event.player;
    val block as IBlock = event.block;
    val info = event.world.getWorldInfo();
    if(block.definition.hardness >= 0.6) {
        if(isNull(player.currentItem)) {
            event.cancel();
        } else {
        for item in <ore:banitems>.items {
            var toolname = item.definition.name;
	        if(player.currentItem.definition.name == toolname) {
		        event.cancel();
		    }
        }
        if(player.currentItem.definition.name.contains("axe")) return;
        if(player.currentItem.definition.name.contains("pickaxe")) return;
        if(player.currentItem.definition.name.contains("shovel")) return;
        if(player.currentItem.definition.name.contains("swo