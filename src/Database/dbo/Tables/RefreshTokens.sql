CREATE TABLE [dbo].[RefreshTokens] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [UserId]          INT            NOT NULL,
    [Token]           NVARCHAR (500) NOT NULL,
    [ExpiresAt]       DATETIME2 (7)  NOT NULL,
    [CreatedAt]       DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [RevokedAt]       DATETIME2 (7)  NULL,
    [ReplacedByToken] NVARCHAR (500) NULL,
    [IsRevoked]       BIT            DEFAULT ((0)) NOT NULL,
    [CreatedByIp]     NVARCHAR (50)  NULL,
    [RevokedByIp]     NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RefreshTokens_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE,
    UNIQUE NONCLUSTERED ([Token] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RefreshTokens_Token]
    ON [dbo].[RefreshTokens]([Token] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RefreshTokens_UserId]
    ON [dbo].[RefreshTokens]([UserId] ASC);

