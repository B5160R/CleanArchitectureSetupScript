# CleanArchitectureSetupScript
Linux bash script for setting up a service in Clean Architecture.

Simple script for adding a service/feature using Clean Architecture in a .NET application.

- Sets up folders
- Creates project files
- Adds references to created projects
- Creates a simple domain model entity class (including properties if given)
- Creates xunit project
- Creates repository interface and respository class
- Creates project files for Context and Migration using EntityFrameworkCore
- Adds packages Microsoft.EntityFrameworkCore, Microsoft.EntityFrameworkCore.Sqlit and Microsoft.EntityFrameworkCore.Tools version 6.0.8 to Context and Migration projects
- Creates context class for service/feature
