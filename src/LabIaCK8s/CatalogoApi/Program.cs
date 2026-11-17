using CatalogoApi;
using CatalogoApi.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

var migrateOnly = args.Contains("--migrate");
var builder = WebApplication.CreateBuilder(
    args.Where(a => a != "--migrate").ToArray());
var config = builder.Configuration;
var connection = new SqlConnectionStringBuilder
{
    DataSource = config["Db:Server"] ?? "sqlserver,1433",
    InitialCatalog = config["Db:Name"] ?? "Catalogo",
    UserID = config["Db:User"] ?? "sa",
    Password = config["Db:Password"]
        ?? throw new InvalidOperationException("Configure Db__Password."),
    Encrypt = true,
    TrustServerCertificate = true, // Apenas para o cluster local didatico.
    ConnectTimeout = 5
}.ConnectionString;

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connection, sql => sql.EnableRetryOnFailure(3)));
var app = builder.Build();

if (migrateOnly)
{
    await Migrator.RunAsync(app.Services);
    return;
}

app.MapGet("/", () => new
{
    aplicacao = "Catalogo tutorialk8s", versao = "1.1",
    pod = Environment.GetEnvironmentVariable("HOSTNAME") ?? "local"
});
app.MapGet("/health/live", () => Results.Ok(new { status = "vivo" }));
app.MapGet("/health/ready", async (AppDbContext db, CancellationToken token) =>
{
    using var timeout = CancellationTokenSource.CreateLinkedTokenSource(token);
    timeout.CancelAfter(TimeSpan.FromSeconds(2));
    try
    {
        return await db.Database.CanConnectAsync(timeout.Token)
            ? Results.Ok(new { status = "pronto" })
            : Results.StatusCode(503);
    }
    catch
    {
        return Results.StatusCode(503);
    }
});
app.MapProdutos();
app.Run();
