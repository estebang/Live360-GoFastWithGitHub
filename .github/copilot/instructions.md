# TailspinToys Copilot Instructions

## Project Overview

TailspinToys is an ASP.NET Core 9.0 web application for managing fundraising campaigns. The application uses Entity Framework Core with an in-memory database and follows clean architecture principles.

## Technology Stack

- **Framework**: ASP.NET Core 9.0
- **UI**: Razor Pages
- **Database**: Entity Framework Core 9.0 with InMemory provider
- **Testing**: xUnit
- **Language**: C# with nullable reference types enabled
- **Build System**: .NET CLI / MSBuild

## Project Structure

- `src/TailspinToys.Web/` - Main web application
  - `Data/` - Database context and seed data
  - `Models/` - Domain models (Campaign, etc.)
  - `Pages/` - Razor Pages for UI
  - `Program.cs` - Application entry point and configuration
- `tests/TailspinToys.Web.Tests/` - Unit tests using xUnit
- `TailspinToys.sln` - Solution file

## Code Standards and Conventions

### General Guidelines
- Use nullable reference types consistently
- Follow standard .NET naming conventions (PascalCase for classes, camelCase for variables)
- Prefer explicit usings over implicit where clarity is needed
- Write unit tests for new functionality
- Keep controllers and pages lightweight, move business logic to services when appropriate

### File Organization
- Models should be simple POCOs in `Models/` directory
- Database-related code goes in `Data/` directory
- Each Razor Page should have a corresponding `.cshtml` and `.cshtml.cs` file
- Test files should mirror the structure of the main project

### Entity Framework Patterns
- Use the repository pattern sparingly - EF Core DbContext already implements it
- Configure entities using the fluent API in `TailspinContext`
- Use async methods for database operations (`ToListAsync`, `FirstOrDefaultAsync`, etc.)
- Seed data should be managed in `SeedData.cs`

### Razor Pages Guidelines
- Use page models (`.cshtml.cs`) for page logic
- Keep view markup clean and semantic
- Use tag helpers where appropriate
- Handle form validation using data annotations and model state

### Testing Approach
- Write unit tests for business logic and models
- Use descriptive test method names that explain the scenario
- Arrange, Act, Assert pattern for test structure
- Mock external dependencies when needed

## Common Tasks and Patterns

### Adding a New Model
1. Create the model class in `Models/` directory
2. Add a DbSet property to `TailspinContext`
3. Update seed data if needed
4. Create corresponding tests

### Adding a New Page
1. Create `.cshtml` and `.cshtml.cs` files in `Pages/` directory
2. Use page model for handling requests
3. Follow existing patterns for form handling and validation
4. Add navigation links where appropriate

### Database Operations
- Always use async methods for database operations
- Handle DbUpdateException and other EF exceptions appropriately
- Use transactions for complex operations that modify multiple entities

## Dependencies and Packages

### Current Packages
- `Microsoft.EntityFrameworkCore` (9.0.0)
- `Microsoft.EntityFrameworkCore.InMemory` (9.0.0)
- `xunit` (2.5.0) - for testing
- `Microsoft.NET.Test.Sdk` (17.6.0) - for test runner

### Adding New Dependencies
- Prefer well-maintained, popular packages
- Keep package versions compatible with .NET 9.0
- Update both main and test projects when adding shared dependencies
- Document any new external dependencies in README

## Build and Development Workflow

### Common Commands
- `dotnet build` - Build the solution
- `dotnet test` - Run all tests
- `dotnet run --project src/TailspinToys.Web` - Run the web application
- `dotnet watch --project src/TailspinToys.Web` - Run with hot reload

### Development Environment
- Application runs on `http://localhost:5000` by default
- Uses in-memory database (data resets on app restart)
- Static files served from `wwwroot/` (create if needed)

## Error Handling and Logging

- Use built-in ASP.NET Core logging framework
- Handle exceptions gracefully with appropriate user feedback
- Log important events and errors for debugging
- Use structured logging with proper log levels

## Security Considerations

- Input validation on all user inputs
- Use HTTPS in production (configured by default)
- Sanitize output to prevent XSS attacks
- Follow OWASP guidelines for web application security

## Performance Guidelines

- Use async/await for I/O operations
- Implement proper caching strategies where appropriate
- Optimize database queries (avoid N+1 problems)
- Use efficient LINQ operations

## Code Generation Preferences

When generating code:
- Follow existing patterns in the codebase
- Include appropriate error handling
- Add XML documentation for public APIs
- Include relevant unit tests
- Use meaningful variable and method names
- Follow the established project structure