using CandleApi.Models;
using CandleApi.Services;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CandleApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly IPasswordService _passwordService;
        private readonly ITokenService _tokenService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IConfiguration configuration, 
            IPasswordService passwordService, 
            ITokenService tokenService,
            ILogger<AuthController> logger)
        {
            _configuration = configuration;
            _passwordService = passwordService;
            _tokenService = tokenService;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Registration attempt started for email: {Email}", timestamp, dto.Email);

            try
            {
                using var connection = CreateConnection();
                
                // Check if user exists
                _logger.LogDebug("[{Timestamp}] Checking if user exists: {Email}", DateTime.UtcNow, dto.Email);
                var existingUser = await connection.QueryFirstOrDefaultAsync<User>("SELECT * FROM Users WHERE Email = @Email", new { dto.Email });
                
                if (existingUser != null)
                {
                    _logger.LogWarning("[{Timestamp}] Registration failed - User already exists: {Email}", DateTime.UtcNow, dto.Email);
                    return BadRequest("User already exists.");
                }

                _logger.LogDebug("[{Timestamp}] Hashing password for user: {Email}", DateTime.UtcNow, dto.Email);
                var passwordHash = _passwordService.HashPassword(dto.Password);
                
                _logger.LogDebug("[{Timestamp}] Inserting new user into database: {Email}", DateTime.UtcNow, dto.Email);
                var sql = "INSERT INTO Users (Name, Email, PasswordHash, Role) VALUES (@Name, @Email, @PasswordHash, 'User'); SELECT CAST(SCOPE_IDENTITY() as int)";
                var id = await connection.ExecuteScalarAsync<int>(sql, new { dto.Name, dto.Email, PasswordHash = passwordHash });

                _logger.LogInformation("[{Timestamp}] ✅ User registered successfully - ID: {UserId}, Email: {Email}, Name: {Name}", 
                    DateTime.UtcNow, id, dto.Email, dto.Name);

                return Ok(new { Id = id, Message = "User registered successfully." });
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error during registration for email: {Email}. Error: {ErrorMessage}", 
                    DateTime.UtcNow, dto.Email, ex.Message);
                return StatusCode(500, "An error occurred while registering the user.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error during registration for email: {Email}. Error: {ErrorMessage}", 
                    DateTime.UtcNow, dto.Email, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Login attempt started for email: {Email}", timestamp, dto.Email);

            try
            {
                using var connection = CreateConnection();

                _logger.LogDebug("[{Timestamp}] Fetching user from database: {Email}", DateTime.UtcNow, dto.Email);
                var user = await connection.QueryFirstOrDefaultAsync<User>("SELECT * FROM Users WHERE Email = @Email", new { dto.Email });
                
                if (user == null)
                {
                    _logger.LogWarning("[{Timestamp}] Login failed - User not found: {Email}", DateTime.UtcNow, dto.Email);
                    return Unauthorized("Invalid credentials.");
                }

                _logger.LogDebug("[{Timestamp}] Verifying password for user: {Email}", DateTime.UtcNow, dto.Email);
                if (!_passwordService.VerifyPassword(dto.Password, user.PasswordHash))
                {
                    _logger.LogWarning("[{Timestamp}] Login failed - Invalid password for user: {Email}", DateTime.UtcNow, dto.Email);
                    return Unauthorized("Invalid credentials.");
                }

                _logger.LogDebug("[{Timestamp}] Generating JWT token for user: {Email}", DateTime.UtcNow, dto.Email);
                var token = _tokenService.GenerateToken(user);

                _logger.LogInformation("[{Timestamp}] ✅ User logged in successfully - ID: {UserId}, Email: {Email}, Role: {Role}", 
                    DateTime.UtcNow, user.Id, user.Email, user.Role);

                return Ok(new { Token = token, User = new { user.Id, user.Name, user.Email, user.Role } });
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error during login for email: {Email}. Error: {ErrorMessage}", 
                    DateTime.UtcNow, dto.Email, ex.Message);
                return StatusCode(500, "An error occurred while logging in.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error during login for email: {Email}. Error: {ErrorMessage}", 
                    DateTime.UtcNow, dto.Email, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }
    }
}
