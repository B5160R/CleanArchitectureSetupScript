#! /bin/bash

#*****************************************************************
# Clean Architecture Template Script                             *
#		                                    		 *
# Author: Mike Frederiksen                                       *
# Github: https://github.com/B5160R/CleanArchitectureSetupScript *                                   *
#*****************************************************************

#-------------------------------------
#         User Input Settings         |
#-------------------------------------

# Path to the folder containing Services
echo Set path to Service folder from current location:
read DIR

# Name of the Service to be created
echo Set name of Service:
read NAME

# Set properties for Entity
echo "Set properties for Domain Model? (y/n)"
read SETUPPROP

if [ "$SETUPPROP" = y ]; then
	echo "Enter list of proporties. Type first followed by name:"
	read -a PROPERTIES
fi

# Setup SqlMigration and SqlContext
echo "Create SqlMigration and SqlContext projects? (y/n)"
read SQLMCP

if [ "$SQLMCP" = y ]; then
	echo "Do you wish to create individual DB connection for service in question? (y/n)"
	read SQLINDIVIDUAL
else
	echo "Do you wish to connect service in question to existing SqlMigration and SqlContext projects? (y/n)"
	read SQLCONNECT
fi

if [ "$SQLCONNECT" = y ]; then
	echo "Set path to exisiting SqlMigration project:"
	read SQLMIGRATIONPATH
	echo "Set path from current location to existing SqlContext project:"
	read SQLCONTEXT
	echo "Set full name of SqlContext project (fx SqlContext.csproj):"
	read SQLCONTEXTNAME
fi

cd $DIR
mkdir $NAME
cd $NAME


#-------------------------------------
#         Sets up Domain layer        |
#-------------------------------------

dotnet new classlib -n $NAME.Domain

cd $NAME.Domain
rm Class1.cs

mkdir Model
cd Model


# Creates Entity Class .cs file with properties if set

touch $NAME"Entity.cs"

echo -e "namespace $NAME.Domain.Model;\n public class $NAME"Entity"\n{\n" > $NAME"Entity.cs"

if [ "$SETUPPROP" = y ]; then
	count=0
	while [ "${PROPERTIES[$count]}" != "" ]; do
		echo -e "	${PROPERTIES[$count]} ${PROPERTIES[$((count+1))]} { get; set; }\n" >> $NAME"Entity.cs"
		((count++))
		((count++))
	done
fi

echo -e "	public $NAME"Entity"()\n	{\n	}\n}" >> $NAME"Entity.cs"

cd ../..


#-------------------------------------
#      Sets up Application layer      |
#-------------------------------------

dotnet new classlib -n $NAME.Application

cd $NAME.Application

rm Class1.cs

dotnet add $NAME.Application.csproj reference "../$NAME.Domain/$NAME.Domain.csproj"

mkdir Commands
cd Commands
mkdir Implementations
mkdir RequestDto
cd ..
mkdir Queries
cd Queries
mkdir Implementation
cd ..
mkdir Repositories
cd Repositories


# Creates IRepository interface .cs file

touch "I"$NAME"Repository.cs"

echo -e "using $NAME.Domain.Model;\n\nnamespace $NAME.Application.Repository;\npublic interface IRepository\n{\n}" >> "I"$NAME"Repository.cs"

cd ../..

#--------------------------------------
#      Sets up Infrastructure layer    |
#--------------------------------------


dotnet new classlib -n $NAME.Infrastructure

cd $NAME.Infrastructure

rm Class1.cs

dotnet add $NAME.Infrastructure.csproj reference "../$NAME.Domain/$NAME.Domain.csproj"
dotnet add $NAME.Infrastructure.csproj reference "../$NAME.Application/$NAME.Application.csproj"

mkdir Repositories
cd Repositories

# Creates Respository class .cs file

touch $NAME"Repository.cs"

echo -e "using $NAME.Application.Repository\nusing $NAME.Domain.Model\n\nnamespace $NAME.Infrastructure;\npublic class Repository : IRepository\n{\n	private readonly Context _db;\n	public Repository(Context db)\n	{\n	_db = db;\n}\n}" >> $NAME"Repository.cs"

cd ../..

#---------------------------------------------
#      Sets up SqlMigration and SqlContext    |
#---------------------------------------------

# Creates and sets up connection to individual service database
if [[ "$SQLMCP" = y && "$SQLINDIVIDUAL" = y ]]; then

	echo "## INSERT CREATE INDIVIDUAL SCRIPT"

	# Creates and sets up individual SqlContext project

	dotnet new classlib -n $NAME.SqlContext

	cd $NAME.SqlContext

	rm Class1.cs

	dotnet add $NAME.SqlContext.csproj package Microsoft.EntityFrameworkCore -v 6.0.8
	dotnet add $NAME.SqlContext.csproj package Microsoft.EntityFrameworkCore.Sqlite -v 6.0.8
	dotnet add $NAME.SqlContext.csproj package Microsoft.EntityFrameworkCore.Tools -v 6.0.8 

	dotnet add $NAME.SqlContext.csproj reference "../$NAME.Domain/$NAME.Domain.csproj"

	# Creates Context class

	touch $NAME"Context.cs"

	echo -e "using $NAME.Domain.Model;\nusing Microsoft.Entity.FrameworkCore;\n\nnamespace $NAME.SqlContext;\npublic class $NAME"Context" : DbContext\n{\n	public $NAME"Context"(DbContextOptions<$NAME"Context"> options) : base(options)\n	{\n	}\n\n	Dbset<$NAME"Entity"> $NAME"Entities" { get; set; }\n}" >> $NAME"Context.cs"

	cd ..
	mkdir $NAME.Data
	cd $NAME.Data
	touch $NAME.database.db

	cd ..


	# Creates and sets up individual SqlMigrations project
	 
	dotnet new classlib -n $NAME.SqlMigrations

	cd $NAME.SqlMigrations

	rm Class1.cs

	dotnet add $NAME.SqlMigrations.csproj package Microsoft.EntityFrameworkCore -v 6.0.8
	dotnet add $NAME.SqlMigrations.csproj package Microsoft.EntityFrameworkCore.Tools -v 6.0.8 
	dotnet add $NAME.SqlMigrations.csproj package Microsoft.EntityFrameworkCore.Sqlite -v 6.0.8

	dotnet add $NAME.SqlMigrations.csproj reference "../$NAME.SqlContext/$NAME.SqlContext.csproj"

	cd ..

# Creates and sets up connection to generel database

elif [[ "$SQLMCP" = y && "$SQLINDIVIDUAL" = n ]]; then

	cd ../..

	# Creates and sets up generel SqlContext project
	dotnet new classlib -n SqlContext

	cd SqlContext

	rm Class1.cs

	dotnet add SqlContext.csproj package Microsoft.EntityFrameworkCore -v 6.0.8
	dotnet add SqlContext.csproj package Microsoft.EntityFrameworkCore.Sqlite -v 6.0.8
	dotnet add SqlContext.csproj package Microsoft.EntityFrameworkCore.Tools -v 6.0.8 

	dotnet add SqlContext.csproj reference "../$DIR/$NAME/$NAME.Domain/$NAME.Domain.csproj"

	# Creates Context class

	touch Context.cs

	echo -e "using $NAME.Domain.Model;\nusing Microsoft.Entity.FrameworkCore;\n\nnamespace $SqlContext;\npublic class Context : DbContext\n{\n	public Context(DbContextOptions<Context> options) : base(options)\n	{\n	}\n\n	Dbset<$NAME"Entity"> $NAME"Entities" { get; set; }\n}" > $NAME"Context.cs"

	cd ..
	mkdir Data
	cd Data
	touch Database.db

	cd ..

	# Creates and sets up general SqlMigrations project
	 
	dotnet new classlib -n SqlMigrations

	cd SqlMigrations

	rm Class1.cs

	dotnet add SqlMigrations.csproj package Microsoft.EntityFrameworkCore -v 6.0.8
	dotnet add SqlMigrations.csproj package Microsoft.EntityFrameworkCore.Sqlite -v 6.0.8
	dotnet add SqlMigrations.csproj package Microsoft.EntityFrameworkCore.Tools -v 6.0.8 

	dotnet add SqlMigrations.csproj reference "../SqlContext/SqlContext.csproj"

	cd ..

# Connects to existing SqlMigration, SqlContext projects and database 
elif [[ "$SQLMCP" = n && "$SQLCONNECT" = y ]]; then

	cd SQLCONTEXT

	dotnet add $SQLCONTEXTNAME reference "../$DIR/$NAME/$NAME.Domain/$NAME.Domain.csproj"

	# *** Todo ***
	# Create script that edits existing context class to include created service

fi
