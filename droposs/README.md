# Drop OSS
Self-hosted open-source game distribution platform (alternative to Steam for DRM-free games)

## Requirements
- Postgres 15 from [alexbelgium's repository](https://github.com/alexbelgium/hassio-addons)
- (Optional) External Drive for games

## Setup

### Addon Setup
1. **Postgres 15 Setup**
    - Set *POSTGRES_USER*, *POSTGRES_PASSWORD* and *POSTGRES_DB* to `drop`
2. **Drop Setup:**
    - If you set up the Database like in the previous step, don't touch *DATABASE_URL*
    - Set *EXTERNAL_URL* to either your `http://<your-ip>:3000` or `http://homeassistant.local:3000`
3. **Run the addon!**
    - After a while you'll see something like this in the logs:
    `Open http://homeassistant.local:3000/setup?token=<token> in a browser to get started with Drop.`

### (Optional) Mounting USB/External Drives

> [!IMPORTANT]
> You need to disable "Protection Mode" if you want the addon to access your drives

Configure the `localdisks` option with either:
- **Disk label**: `GamesDrive` (the name/label of your disk)
- **Device path**: `/dev/sda1`
- **Multiple disks**: `GamesDrive, /dev/sdb1` (comma-separated)

**To find your disk:**
1. Go to **Settings → System → Hardware** and look for your USB drive's name/label
2. Or SSH into Home Assistant and run `lsblk -o NAME,SIZE,LABEL`

**Example:**
- Disk labeled "GamesDrive" -> use `GamesDrive`
- Will mount to `/mnt/GamesDrive`
- Configure Drop to use: `/mnt/GamesDrive/games`