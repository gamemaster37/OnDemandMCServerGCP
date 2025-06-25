package com.example.lobby;

import net.minestom.server.MinecraftServer;
import net.minestom.server.entity.Player;
import net.minestom.server.event.GlobalEventHandler;
import net.minestom.server.event.player.AsyncPlayerConfigurationEvent;
import net.minestom.server.instance.*;
import net.minestom.server.instance.block.Block;
import net.minestom.server.coordinate.Pos;
import net.minestom.server.event.player.PlayerSpawnEvent;
import net.minestom.server.coordinate.Vec;
import net.minestom.server.timer.TaskSchedule;
import java.util.concurrent.ThreadLocalRandom;

public class LobbyServer {

    public static void main(String[] args) {
        MinecraftServer minecraftServer = MinecraftServer.init();

        InstanceManager instanceManager = MinecraftServer.getInstanceManager();

        InstanceContainer instanceContainer = instanceManager.createInstanceContainer();
        instanceContainer.setGenerator(unit -> unit.modifier().fillHeight(0, 40, Block.GRASS_BLOCK));
        instanceContainer.setChunkSupplier(LightingChunk::new);

        GlobalEventHandler globalEventHandler = MinecraftServer.getGlobalEventHandler();

        globalEventHandler.addListener(AsyncPlayerConfigurationEvent.class, event -> {
            final Player player = event.getPlayer();
            event.setSpawningInstance(instanceContainer);
            player.setRespawnPoint(new Pos(0, 42, 0));
        });

        globalEventHandler.addListener(PlayerSpawnEvent.class, event -> {
            final Player player = event.getPlayer();
            player.sendMessage("Welcome to the lobby!");
            player.sendMessage("Main server is starting up...");
            //player.setNoGravity(true);

            player.scheduler()
                .buildTask(() -> {
                    double randX = ThreadLocalRandom.current().nextDouble(-100, 100);
                    double randY = ThreadLocalRandom.current().nextDouble(-100, 100);
                    double randZ = ThreadLocalRandom.current().nextDouble(-100, 100);
                    Vec velocity = new Vec(randX, randY, randZ);

                    player.setVelocity(velocity);
                    String direction = getDirection(velocity);

                    player.sendMessage(player.getUsername() + " moves " + direction);
                })
                .delay(TaskSchedule.seconds(30))
                .repeat(TaskSchedule.tick(5))
                .schedule();
        });

        minecraftServer.start("0.0.0.0", 25565);
        System.out.println("Minestom lobby server started on port 25565");
    }

    private static String getDirection(Vec velocity) {
        double x = velocity.x();
        double y = velocity.y();
        double z = velocity.z();

        StringBuilder direction = new StringBuilder();

        if (y > 0.05) {
            direction.append("Up ");
        } else if (y < -0.05) {
            direction.append("Down ");
        }

        if (z > 0.05) {
            direction.append("South ");
        } else if (z < -0.05) {
            direction.append("North ");
        }

        if (x > 0.05) {
            direction.append("East ");
        } else if (x < -0.05) {
            direction.append("West ");
        }

        if (direction.length() == 0) {
            return "Stationary";
        }
        return direction.toString().trim();
    }
}