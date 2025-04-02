# Local Setup Guide for CK-X Simulator

## Quick Setup

1. Clone the repository:
```bash
git clone https://github.com/nishanb/ck-x.git
cd ck-x
```

2. Run the deployment script:
```bash
./scripts/compose-deploy.sh
```

The script will deploy all services locally and open the application in your browser.

After making any changes to the code, you can redeploy with:
```bash
docker compose up -d
```

This setup has been tested on Mac and Linux environments. 