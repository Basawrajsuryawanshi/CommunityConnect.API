CREATE TABLE [dbo].[LoginAttempts] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Email]         NVARCHAR (255) NOT NULL,
    [IpAddress]     NVARCHAR (50)  NOT NULL,
    [Success]       BIT            NOT NULL,
    [FailureReason] NVARCHAR (255) NULL,
    [AttemptedAt]   DATETIME2 (7)  DEFAULT (getutcdate()) NULL,
    [UserAgent]     NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_LoginAttempts_Email]
    ON [dbo].[LoginAttempts]([Email] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LoginAttempts_IpAddress]
    ON [dbo].[LoginAttempts]([IpAddress] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LoginAttempts_AttemptedAt]
    ON [dbo].[LoginAttempts]([AttemptedAt] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_LoginAttempts_Success]
    ON [dbo].[LoginAttempts]([Success] ASC);

