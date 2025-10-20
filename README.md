# Donk Blips - Admin Management System

A FiveM blip management script with full admin controls using ox_lib menus and database storage. Compatible with both **QBCore** and **ESX** frameworks.

## Features

- **Framework Agnostic**: Works with both QBCore and ESX
- **Database Storage**: All blips stored in MySQL database
- **Admin Menu System**: Beautiful ox_lib menus for managing blips
- **Real-time Updates**: All players see changes instantly
- **Easy Management**: Add, view, delete, and teleport to blips
- **Permission Based**: Configurable admin permissions

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- QBCore **OR** ESX framework

## Installation

1. **Download and Install Dependencies**
   - Make sure you have `ox_lib` and `oxmysql` installed and started in your server.cfg

2. **Install the Resource**
   - Place `donk_blips` folder in your server's `resources` directory

3. **Database Setup**
   - The table will be created automatically when the resource starts
   - OR manually run the `install.sql` file in your database

4. **Configure Settings**
   - Open `config.lua` and adjust settings:
     - `Config.AdminCommand` - Command to open admin menu (default: `/blipsadmin`)
     - `Config.AdminPermission` - QBCore permission level (default: `god`)
     - `Config.AdminGroups` - ESX admin groups (default: `admin`, `superadmin`)

5. **Start the Resource**
   - Add `ensure donk_blips` to your server.cfg
   - Restart your server or run `refresh` then `ensure donk_blips`

## Usage

### Admin Commands

- `/blipsadmin` - Opens the blip management menu (admins only)

### Admin Menu Options

**Main Menu:**
- **Add New Blip** - Create a blip at your current location
- **Manage Blips** - View and manage existing blips

**When Adding a Blip:**
- Blip Name - Display name for the blip
- Sprite ID - Icon ID (see [Blip Sprite List](https://docs.fivem.net/docs/game-references/blips/))
- Color ID - Color ID (see [Blip Color List](https://docs.fivem.net/docs/game-references/blips/))
- Scale - Size of the blip (0.1 - 2.0)

**When Managing a Blip:**
- **View Location** - Set GPS waypoint to blip
- **Teleport to Blip** - Teleport to blip location
- **Delete Blip** - Permanently remove the blip

### Common Blip Sprites

- 1 - Default marker
- 51 - Medical cross
- 52 - Police badge
- 56 - Car
- 84 - House
- 315 - Race flag
- 739 - Recycling
- 817 - Store

### Common Blip Colors

- 0 - White
- 1 - Red
- 2 - Green
- 3 - Blue
- 5 - Yellow
- 26 - Light Blue
- 47 - Purple

## Configuration

### For QBCore Servers

Edit in `config.lua`:
```lua
Config.AdminPermission = 'god' -- or 'admin'
```

Permissions use QBCore's built-in permission system.

### For ESX Servers

Edit in `config.lua`:
```lua
Config.AdminGroups = {
    'admin',
    'superadmin'
}
```

Add or remove groups as needed based on your ESX setup.

## Support

For issues or feature requests, please open an issue on GitHub.

## Credits

- **Author**: donk
- **Version**: 2.0
- **Framework Support**: QBCore & ESX
- **UI Library**: ox_lib

## License

This resource is open source and free to use.
