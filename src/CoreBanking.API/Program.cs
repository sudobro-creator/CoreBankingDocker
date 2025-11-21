var builder = WebApplication.CreateBuilder(args);

// Add controller support
builder.Services.AddControllers();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure Kestrel to listen on port 80 (recommended for Docker)
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(80); // Listen on port 80 on all interfaces
});

var app = builder.Build();

var appName = builder.Configuration.GetValue<string>("Application:Name") ?? "CoreBanking.API";
app.Logger.LogInformation("Starting {appName}...", appName);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

// Health endpoint
app.MapGet("/health", () =>
    Results.Ok(new { status = "healthy", app = appName }))
    .WithName("HealthCheck");

// Root endpoint
app.MapGet("/", () =>
    Results.Ok($"{appName} running"));

app.Run();
