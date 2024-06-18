#
import crafttweaker.events.IEventManager;
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
import crafttweaker.event.BlockHarvestDropsEvent;
import crafttweaker.event.ItemTossEvent;
import crafttweaker.event.PlayerInteractEvent;
import crafttweaker.event.PlayerBreakSpeedEvent;
import crafttweaker.event.BlockPlaceEvent;
import crafttweaker.world.IBlockAccess;
import crafttweaker.world.IBlockPos;
import crafttweaker.world.IFacing;

events.onPlayerInteractBlock(function(event as PlayerInteractBlockEvent) {
var id = event.block.definition.id;
if (!event.player.world.isRemote()) {
    if ((id == "minecraft:furnace") || (id == "minecraft:crafting_table") || (id == "minecraft:lit_furnace")) {
        if(!isNull(player.data.wasGivenTip1)) return;
        event.player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.broken"));
        event.player.update({wasGivenTip1: true});
        event.cancel();
    } else if(id == "immersiveengineering:wooden_device0") {
        var current = event.player.currentItem;
        if (isNull(current)) {
            event.player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.locked"));
            event.cancel();
        } else if(!current.definition.id.contains("key")) {
            event.player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.locked"));
            event.cancel();
        } else if(current.definition.id != "locks:master_key") {
            event.player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.failed"));
            event.cancel();
        }
    }
}});

events.onItemToss(function(event as ItemTossEvent) {
    var itemdrop = event.item.item;
    if(itemdrop in <ore:banItems>) {
        event.cancel();
    }
});

events.onPlayerBonemeal(function(event as PlayerBonemealEvent) {
    event.cancel();
});

events.onPlayerInteract(function(event as PlayerInteractEvent) {
    val player = event.player;
    if(isNull(player.currentItem)) return;
    if(player.currentItem in <ore:banItems>) {
        player.dropItem(true);
    } else if(player.currentItem.name == "item.glassBottle") {
        event.player.dropItem(true);
    }
});

events.onEntityLivingDeathDrops(function(event as EntityLivingDeathDropsEvent) {
    if(event.entity instanceof IPlayer) return;
    for drop in event.drops {
        if(drop in <ore:banItems>.itemArray) {
            event.cancel();
        }
    }
});

events.onPlayerRespawn(function(event as PlayerRespawnEvent) {
    val player as IPlayer = event.player;
    player.addPotionEffect(<potion:minecraft:hunger>.makePotionEffect(312, 1));
    player.addPotionEffect(<potion:minecraft:weakness>.makePotionEffect(312, 1));
    player.xp = 0;
});

var mobs = [
"Witch",
"Slime",
"tconstruct.blueslime",
"pyrotech.mud",
"Spider",
"Stray",
"Creeper",
"Enderman",
"CaveSpider",
"babycreeper",
"babyenderman",
"babyguardian",
"babyirongolem",
"babyocelot",
"babyshulker",
"babyshulkerbullet",
"babysnowman",
"babyspider",
"babysquid",
"babywitch",
"babywither",
"Skeleton",
"Zombie",
"Husk",
"ZombieVillager",
"ZombieHorse",
"SkeletonHorse",
"zombiechicken",
"zombiepig",
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
"mutantbeasts.throwable_block",
"babyskeleton",
"babyzombie"
] as string[];

events.onEntityJoinWorld(function(event as EntityJoinWorldEvent) {
    val entity = event.entity;
    if(!entity instanceof IEntityMob) return;
    val time = event.world.getWorldInfo().getWorldTotalTime();
    if(time < 603021) {
        if(entity.definition.name in mobs) {
           event.cancel();
        }
    }
});

events.onPlayerLoggedIn(function(event as PlayerLoggedInEvent) {
    var player = event.player as IPlayer;
    var ser = server.commandManager as ICommandManager;
    val time = player.world.getWorldInfo().getWorldTotalTime();
    if(time < 603021) {
        if(!isNull(player.data.wasGivenTip1)) return;
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.login.tip1"));
        player.update({wasGivenTip1: true});
    } else {
        if(!isNull(player.data.wasGivenTip2)) return;
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.login.tip2"));
        player.update({wasGivenTip2: true});
    }
});

events.onBlockBreak(function(event as BlockBreakEvent) {
if((event.world.remote) || (!event.isPlayer)) return;
if(!event.player.creative) {
	val player as IPlayer = event.player;
    val block as IBlock = event.block;
    val info = event.world.getWorldInfo();
    if(block.definition.hardness > 0.6) {
        if(isNull(player.currentItem)) {
            event.cancel();
            player.addPotionEffect(<potion:tconstruct:dot>.makePotionEffect(20, 1));
            player.addPotionEffect(<potion:minecraft:mining_fatigue>.makePotionEffect(200, 1));
        } else {
        if(player.currentItem.definition.name.contains("axe")) return;
        if(player.currentItem.definition.name.contains("pickaxe")) return;
        if(player.currentItem.definition.name.contains("shovel")) return;
        if(player.currentItem.definition.name.contains("sword")) return;
        if(player.currentItem.definition.name.contains("hoe")) return;
            event.cancel();
        }
    }
    if(!info.difficultyLocked) {
        event.cancel();
        player.sendRichTextMessage(ITextComponent.fromTranslation("crafttweaker.message.difficulty"));
    }
}});

events.onBlockPlace(function(event as BlockPlaceEvent) {
var id = event.block.definition.id;
var player = event.player;
for name in names {
    if (id.contains("hopper")) {
        var down = event.world.getBlockState(event.position.getOffset(IFacing.down(), 1)).block;
        var up = event.world.getBlockState(event.position.getOffset(IFacing.up(), 1)).block;
        if(down.definition.id.contains("furnace") || up.definition.id.contains("furnace")) {
            event.cancel();
        }
    }
}});