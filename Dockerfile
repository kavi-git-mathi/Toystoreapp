#Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ToyStoreApp.csproj", "."]
RUN dotnet restore "./ToyStoreApp.csproj"
COPY . .
RUN dotnet publish "ToyStoreApp.csproj" -c Release -o /app/build

#Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/build .
ENTRYPOINT ["dotnet", "ToyStoreApp.dll"]
EXPOSE 80
