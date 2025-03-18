
## Features:
* This repo is small, the LH-Stinger repo is more thn 2.5GB
* You can fork this repo and enable github actions if your security conscious
* This repo uses Github Actions to keep this "fork" up-to-date with the [Stinger Pico MMU Klipper](https://github.com/lhndo/LH-Stinger/tree/main/User_Mods/MMU/Stinger%20Pico%20MMU%20-%20%40LH/Klipper) config files.

## Installation:

The cleanest and easiest way to get started is to use Moonraker's Update Manager utility. This will allow you to easily install and helps to provide future updates when more features are rolled out!

1. `ssh` into your Klipper device and execute the following commands:
   ```bash
    cd
    
    git clone https://github.com/dblevin1/Pico-MMU-Klipper.git
    
    ln -s ~/Pico-MMU-Klipper/sp_mmu_code.cfg printer_data/config/sp_mmu_code.cfg
    ln -s ~/Pico-MMU-Klipper/sp_mmu.cfg printer_data/config/sp_mmu_CONFIG_TEMPLATE.cfg
    ```
    > **Note:**
    > This will change to the home directory, clone this, create a symbolic link of the code and config file. You may have to save the config template as sp_mmu.cfg if you haven't created one yet.
    >
    > When updated if sp_mmu_code.cfg needs a new version of sp_mmu.cfg you will have to manually combine your sp_mmu.cfg and the new sp_mmu_CONFIG_TEMPLATE.cfg
    > 
    > It is also possible that with older setups of klipper or moonraker that your config path will be different. Be sure to use the correct config path for your machine when making the symbolic link.

2. Open your `moonraker.conf` file and add this configuration:
   ```yaml
   [update_manager Pico-MMU-Klipper]
   type: git_repo
   channel: dev
   path: ~/Pico-MMU-Klipper
   origin: https://github.com/dblevin1/Pico-MMU-Klipper.git
   managed_services: klipper
   primary_branch: main
    ```

    > **Note:**
    > Whenever Moonraker configurations are changed, it must be restarted for changes to take effect.

3. Make sure you've added `[include sp_mmu.cfg]` in your printer.cfg.
