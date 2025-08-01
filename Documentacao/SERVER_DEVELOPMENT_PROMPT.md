# OliAcesso Remoto - Server Development Prompt

## Project Overview - OliAcesso Remoto

**Current Status**: WPF Client Application (C# .NET 9.0)
- **Framework**: WPF with .NET 9.0-windows
- **Architecture**: Desktop client for remote access connections
- **Current Features**: Connection management, server hosting simulation, settings configuration

### Existing Client Features
- **Connection Tab**: Connect to remote computers using ID format (XXX XXX XXX)
- **Server Tab**: Allow remote access to local computer with ID sharing
- **Settings Tab**: Network configuration, display quality, security settings
- **Recent Connections**: Save and manage connection history
- **UI**: Modern Material Design-inspired interface with tabs

### Current Implementation Status
- ✅ UI/UX complete with modern styling
- ✅ Basic connection simulation
- ✅ ID generation and validation
- ✅ Settings management interface
- ❌ **Missing**: Actual networking implementation
- ❌ **Missing**: Real remote desktop functionality
- ❌ **Missing**: Server-side infrastructure

---

## Prompt for Creating Server Version (OnliDek Server)

Create a comprehensive server application for the OliAcesso Remoto ecosystem with the following specifications:

### Core Server Requirements

**1. Technology Stack**
- **Backend**: ASP.NET Core 8.0+ Web API
- **Real-time Communication**: SignalR for client-server messaging
- **Database**: Entity Framework Core with SQL Server/PostgreSQL
- **Authentication**: JWT tokens with role-based access
- **Logging**: Serilog with structured logging
- **Configuration**: appsettings.json with environment-specific configs

**2. Server Architecture**
```
OnliDekServer/
├── Controllers/          # API endpoints
├── Hubs/                # SignalR hubs for real-time communication
├── Models/              # Data models and DTOs
├── Services/            # Business logic services
├── Data/                # Entity Framework context and migrations
├── Middleware/          # Custom middleware
└── Configuration/       # Server configuration classes
```

**3. Core Functionalities**

**Connection Management**
- Generate unique 9-digit IDs (XXX XXX XXX format) for clients
- Maintain active client registry with connection status
- Handle client authentication and session management
- Route connection requests between clients
- Implement connection timeouts and cleanup

**Real-time Communication Hub**
```csharp
public class RemoteAccessHub : Hub
{
    // Client registration with generated ID
    Task RegisterClient(string clientInfo);
    
    // Connection request handling
    Task RequestConnection(string targetId, string requesterId);
    
    // Connection approval/denial
    Task RespondToConnection(string requesterId, bool approved);
    
    // Screen sharing data transmission
    Task SendScreenData(string targetId, byte[] screenData);
    
    // Input event forwarding (mouse, keyboard)
    Task SendInputEvent(string targetId, InputEventDto inputEvent);
}
```

**4. Database Schema**
```sql
-- Clients table
CREATE TABLE Clients (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    ClientId NVARCHAR(11) UNIQUE, -- XXX XXX XXX format
    Name NVARCHAR(255),
    LastSeen DATETIME2,
    IsOnline BIT,
    ConnectionInfo NVARCHAR(MAX) -- JSON with IP, version, etc.
);

-- Active Sessions table
CREATE TABLE ActiveSessions (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    ControllerClientId NVARCHAR(11),
    TargetClientId NVARCHAR(11),
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status NVARCHAR(50) -- Active, Ended, Failed
);

-- Connection Logs table
CREATE TABLE ConnectionLogs (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    ClientId NVARCHAR(11),
    Action NVARCHAR(100),
    Timestamp DATETIME2,
    Details NVARCHAR(MAX)
);
```

**5. API Endpoints**
```csharp
[ApiController]
[Route("api/[controller]")]
public class ClientController : ControllerBase
{
    [HttpPost("register")]
    Task<ClientRegistrationResponse> RegisterClient(ClientRegistrationRequest request);
    
    [HttpGet("status/{clientId}")]
    Task<ClientStatusResponse> GetClientStatus(string clientId);
    
    [HttpPost("connection/request")]
    Task<ConnectionResponse> RequestConnection(ConnectionRequest request);
    
    [HttpGet("clients/online")]
    Task<List<OnlineClientDto>> GetOnlineClients();
}
```

**6. Security Implementation**
- **Client Authentication**: Generate secure tokens for each client session
- **Connection Authorization**: Implement password-based access control
- **Data Encryption**: Encrypt all screen sharing and input data
- **Rate Limiting**: Prevent abuse with connection attempt limits
- **Audit Logging**: Log all connection attempts and activities

**7. Performance Optimization**
- **Screen Compression**: Implement efficient image compression for screen sharing
- **Delta Updates**: Send only changed screen regions
- **Connection Pooling**: Optimize database connections
- **Caching**: Redis cache for active client status
- **Load Balancing**: Support for horizontal scaling

**8. Configuration Management**
```json
{
  "ServerSettings": {
    "MaxConcurrentConnections": 1000,
    "ClientTimeoutMinutes": 30,
    "ScreenUpdateIntervalMs": 100,
    "CompressionLevel": "Medium"
  },
  "Security": {
    "RequireClientAuthentication": true,
    "AllowAnonymousConnections": false,
    "MaxConnectionAttemptsPerHour": 10
  }
}
```

**9. Integration with Existing Client**
- Update `MainWindow.xaml.cs` to connect to real server endpoints
- Replace simulation code with actual SignalR client implementation
- Implement screen capture and input forwarding in client
- Add proper error handling and reconnection logic

**10. Deployment Requirements**
- **Docker**: Containerized deployment with docker-compose
- **Health Checks**: Implement health check endpoints
- **Monitoring**: Integration with Application Insights or similar
- **Backup Strategy**: Database backup and recovery procedures

**11. Additional Features to Implement**
- **File Transfer**: Secure file sharing between connected clients
- **Chat System**: Text communication during remote sessions
- **Session Recording**: Optional session recording for audit purposes
- **Multi-Monitor Support**: Handle multiple displays on target machines
- **Mobile Client Support**: API design to support future mobile clients

## Implementation Priority

### Phase 1: Core Infrastructure
1. Create ASP.NET Core Web API project
2. Implement SignalR hub for real-time communication
3. Set up Entity Framework with basic models
4. Create client registration and ID generation system

### Phase 2: Connection Management
1. Implement connection request/response flow
2. Add client status tracking
3. Create session management
4. Add basic security and authentication

### Phase 3: Remote Desktop Functionality
1. Implement screen capture and transmission
2. Add input event forwarding
3. Optimize performance with compression
4. Add error handling and reconnection logic

### Phase 4: Advanced Features
1. File transfer system
2. Chat functionality
3. Session recording
4. Multi-monitor support

Create a complete, production-ready server implementation that can handle the existing WPF client and provide a robust foundation for the remote access functionality currently simulated in the client application.