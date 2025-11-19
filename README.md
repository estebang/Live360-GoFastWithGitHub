# TailspinToys

A modern ASP.NET Core web application for managing fundraising campaigns built with .NET 8 and Entity Framework Core.

## 📋 Overview

TailspinToys is a web application that allows users to create and manage fundraising campaigns. The application provides a clean interface for tracking campaign goals, current amounts, and campaign details.

## 🚀 Features

- **Campaign Management**: Create and view fundraising campaigns
- **Goal Tracking**: Monitor progress towards fundraising goals
- **Responsive Design**: Built with ASP.NET Core Razor Pages
- **In-Memory Database**: Uses Entity Framework Core with in-memory database for development
- **Clean Architecture**: Organized project structure with separation of concerns

## 🛠 Tech Stack

- **Framework**: ASP.NET Core 9.0
- **UI**: Razor Pages
- **Database**: Entity Framework Core (In-Memory Database)
- **Testing**: xUnit
- **Language**: C# with nullable reference types enabled

## 📁 Project Structure

```
TailspinToys/
├── src/
│   └── TailspinToys.Web/           # Main web application
│       ├── Data/                   # Database context and seed data
│       ├── Models/                 # Domain models
│       ├── Pages/                  # Razor Pages
│       └── Program.cs              # Application entry point
├── tests/
│   └── TailspinToys.Web.Tests/     # Unit tests
└── TailspinToys.sln               # Solution file
```

## 🏃‍♂️ Getting Started

### Prerequisites

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) or later
- [Git](https://git-scm.com/)
- Code editor (Visual Studio, VS Code, or JetBrains Rider)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd TailspinToys
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Build the solution**
   ```bash
   dotnet build
   ```

4. **Run the application**
   ```bash
   cd src/TailspinToys.Web
   dotnet run
   ```

5. **Open your browser**
   Navigate to `https://localhost:5001` or `http://localhost:5000` (URLs will be displayed in the console)

### Running Tests

Run all tests from the solution root:
```bash
dotnet test
```

Run tests with detailed output:
```bash
dotnet test --verbosity normal
```

## 🔧 Development

### Database

The application uses Entity Framework Core with an in-memory database for development. The database is automatically seeded with sample data on application startup through the `SeedData.Initialize()` method.

### Adding New Features

1. **Models**: Add domain models in `src/TailspinToys.Web/Models/`
2. **Database**: Update `TailspinContext` in `src/TailspinToys.Web/Data/`
3. **Pages**: Add Razor Pages in `src/TailspinToys.Web/Pages/`
4. **Tests**: Add corresponding tests in `tests/TailspinToys.Web.Tests/`

### Code Style

- The project uses C# nullable reference types
- Implicit usings are enabled
- Follow standard .NET naming conventions

## 🧪 Testing

The project uses xUnit for testing. Test files are located in the `tests/TailspinToys.Web.Tests/` directory.

### Test Structure
- Unit tests for models and business logic
- Integration tests for web functionality (add as needed)

## 📦 Build and Deployment

### Local Development
```bash
# Build the solution
dotnet build --configuration Release

# Run the application
cd src/TailspinToys.Web
dotnet run

# Publishing for deployment
dotnet publish --configuration Release --output ./publish
```

### CI/CD Pipeline
This project includes a comprehensive CI/CD pipeline using GitHub Actions with:

- ✅ **Automated deployments** to Azure App Service
- ✅ **Multi-environment support** (development, staging, production) 
- ✅ **PR preview environments** for testing changes
- ✅ **Security scanning** and code quality checks
- ✅ **Azure OIDC authentication** (no long-lived secrets)
- ✅ **Hotfix deployment** capability for urgent fixes

**📚 [Complete CI/CD Documentation](docs/README.md)**
**🚀 [15-Minute Setup Guide](docs/quick-setup.md)**

#### Quick Pipeline Status
- **Development**: Auto-deploy from `develop` branch
- **Staging**: Auto-deploy from `main` branch  
- **Production**: Manual approval required from `main` branch
- **PR Previews**: Automatic deployment slots for pull requests

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Write tests for new functionality
- Follow existing code patterns and conventions
- Update documentation for significant changes
- Ensure all tests pass before submitting PR

## 📝 Configuration

The application uses standard ASP.NET Core configuration:
- `appsettings.json` for base configuration
- `appsettings.Development.json` for development overrides
- Environment variables for production settings

## 🐛 Troubleshooting

### Common Issues

**Application won't start**
- Ensure .NET 8.0 SDK is installed
- Check that ports 5000/5001 are available
- Verify all dependencies are restored (`dotnet restore`)

**Tests failing**
- Clean and rebuild the solution (`dotnet clean && dotnet build`)
- Check test output for specific error details

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋‍♂️ Support

For questions or issues:
- Create an issue in this repository
- Check existing documentation
- Review test cases for usage examples

---

*Built with ❤️ using ASP.NET Core*