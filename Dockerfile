# CoreBanking.API Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
# EXPOSE 443

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["src/CoreBanking.API/CoreBanking.API.csproj", "src/CoreBanking.API/"]
RUN dotnet restore "src/CoreBanking.API/CoreBanking.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/src/CoreBanking.API"
RUN dotnet build "CoreBanking.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CoreBanking.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

ENTRYPOINT ["dotnet", "CoreBanking.API.dll"]