## GitHub Actions Workflow

Repository ini sudah dilengkapi dengan GitHub Actions workflow untuk automated building:

### Trigger Events

1. **Push ke branch main/development** - Auto build
2. **Pull Request** - Build test
3. **Manual trigger** - Via GitHub UI
4. **Schedule** - Weekly build every Sunday

### Manual Build via GitHub UI

1. Go to "Actions" tab
2. Select "Build BatAxeKernel"
3. Click "Run workflow"
4. Choose branch and options:
   - Branch: main, development, master, staging
   - Clean build: true/false
   - Skip install: true/false

### Artifacts

Setiap build akan menghasilkan:
- Kernel binaries
- System.map
- .config file
- Build log

### Matrix Build

Workflow mendukung multi-architecture build:
- x86_64
- arm64