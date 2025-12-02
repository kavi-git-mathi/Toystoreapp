# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ToyStoreApp.csproj", "."]
RUN dotnet restore "./ToyStoreApp.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "ToyStoreApp.csproj" -c Release -o /app/build
RUN dotnet publish "ToyStoreApp.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8000 
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ToyStoreApp.dll", "--urls", "http://0.0.0.0:8000"]